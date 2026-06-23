Переходим к **Фазе 1: Визуал и Физика (Doll3D 2.0)**. 

В Godot 3 старый класс `Doll3D` (963 строки) занимался всем: от загрузки текстур до расчёта Verlet-интеграции для физики груди и применения кастомных поз (`set_bone_custom_pose`) для симуляции беременности. В Godot 4 API скелетов изменилось кардинально. Теперь для этого используются узлы `SkeletonModifier3D`.

Скопируй приведенный ниже текст, сохрани его как `PHASE1_TODO.md` и отправь агенту.

***

# TODO.md — BDCC: Reforged (Фаза 1: Doll3D 2.0)

## Контекст для агента

Твоя задача — реализовать новую архитектуру 3D-куклы (Doll3D) для Godot 4.x. Старый код (Godot 3) использовал устаревшие методы `set_bone_custom_pose` и ручной расчет физики в монолитном скрипте. 

В Godot 4.x мы используем **SkeletonModifier3D** для любых деформаций костей (физика, беременность, размеры) и **ECS-компоненты** для управления слотами (части тела, одежда).

Строго следуй инструкциям. Не придумывай лишней логики. Создавай файлы по указанным путям с предоставленным кодом (GDScript 2.0).

---

## ШАГ 1: Создание модификатора деформации (Deformation Modifier)

*В Godot 4 `set_bone_custom_pose` удален. Вместо него применяются узлы `SkeletonModifier3D`, которые перехватывают процесс анимации.*

1. Создай папку `Visuals/SkeletonModifiers/`.
2. Создай файл `Visuals/SkeletonModifiers/DeformModifier3D.gd`:

```gdscript
# Visuals/SkeletonModifiers/DeformModifier3D.gd
@tool
class_name DeformModifier3D extends SkeletonModifier3D

## Модификатор для изменения размера и смещения костей (Беременность, размер груди/пениса).
## Должен быть дочерним узлом Skeleton3D.

@export var bone_name: StringName
@export var scale_factor: Vector3 = Vector3.ONE
@export var position_offset: Vector3 = Vector3.ZERO

var _bone_idx: int = -1

func _process_modification() -> void:
    var skel: Skeleton3D = get_skeleton()
    if not skel:
        return

    if _bone_idx == -1:
        _bone_idx = skel.find_bone(String(bone_name))

    if _bone_idx == -1:
        return

    # Получаем текущую позу (после анимации) и применяем наши деформации
    var pose: Transform3D = skel.get_bone_pose(_bone_idx)
    var custom_transform := Transform3D(Basis().scaled(scale_factor), position_offset)

    skel.set_bone_pose(_bone_idx, pose * custom_transform)
```

---

## ШАГ 2: Создание модификатора физики (Jiggle Physics)

*Замена старого `JiggleBone`. Работает через встроенный пайплайн модификаторов.*

1. Создай файл `Visuals/SkeletonModifiers/JiggleModifier3D.gd`:

```gdscript
# Visuals/SkeletonModifiers/JiggleModifier3D.gd
@tool
class_name JiggleModifier3D extends SkeletonModifier3D

## Verlet-интеграция для симуляции физики мягких тел (хвосты, грудь).
## Должен быть дочерним узлом Skeleton3D.

@export var bone_name: StringName
@export var stiffness: float = 0.1
@export var damping: float = 0.7
@export var gravity: Vector3 = Vector3(0, -0.05, 0)

var _bone_idx: int = -1
var _current_pos: Vector3
var _previous_pos: Vector3

func _ready() -> void:
    var skel = get_skeleton()
    if skel and bone_name:
        _bone_idx = skel.find_bone(String(bone_name))
        if _bone_idx != -1:
            var global_pose = skel.get_bone_global_pose(_bone_idx)
            _current_pos = global_pose.origin
            _previous_pos = _current_pos

func _process_modification() -> void:
    var skel: Skeleton3D = get_skeleton()
    if not skel or _bone_idx == -1:
        return

    # Простая Verlet-интеграция
    var velocity: Vector3 = (_current_pos - _previous_pos) * damping
    _previous_pos = _current_pos

    # Применяем гравитацию и жесткость (возврат к исходной позе кости)
    var target_pose = skel.get_bone_pose(_bone_idx).origin
    var force: Vector3 = gravity + (target_pose - _current_pos) * stiffness

    _current_pos += velocity + force

    # Применяем новую позицию в локальное пространство кости
    var pose: Transform3D = skel.get_bone_pose(_bone_idx)
    pose.origin = _current_pos
    skel.set_bone_pose(_bone_idx, pose)
```

---

## ШАГ 3: Компонент управления частями тела (DollPartManager)

*Убийца массива `parts` из старого `Doll3D`. Теперь это независимый ECS-компонент.*

1. Создай файл `Components/DollPartManager.gd`:

```gdscript
# Components/DollPartManager.gd
class_name DollPartManager extends Component

## Управляет прикрепляемыми моделями (слоты тела, броня) к 3D кукле.
## Должен висеть на Entity.

@export var target_skeleton: Skeleton3D

# Словарь активных прикрепленных узлов: SlotName (StringName) -> Node3D
var active_parts: Dictionary = {}

## Экипирует новую часть тела/одежду. Заменяет старую в том же слоте.
func equip_part(slot: StringName, part_scene_path: String) -> void:
    assert(target_skeleton != null, "DollPartManager: Skeleton3D не назначен!")

    # Если в слоте уже что-то есть, удаляем
    if active_parts.has(slot):
        var old_part: Node = active_parts[slot]
        target_skeleton.remove_child(old_part)
        old_part.queue_free()

    var packed_scene := load(part_scene_path) as PackedScene
    if not packed_scene:
        push_error("DollPartManager: Ошибка загрузки сцены %s" % part_scene_path)
        return

    var instance = packed_scene.instantiate() as Node3D
    target_skeleton.add_child(instance)
    active_parts[slot] = instance

    # Оповещаем другие системы (например, UI) об изменении внешности
    EventBus.emit_signal("item_added", entity, slot, 1)

## Очищает слот
func unequip_part(slot: StringName) -> void:
    if active_parts.has(slot):
        var part: Node = active_parts[slot]
        target_skeleton.remove_child(part)
        part.queue_free()
        active_parts.erase(slot)
```

---

## ШАГ 4: Корневой класс новой куклы (Doll3D 2.0)

*Теперь `Doll3D` — это просто оркестратор визуального узла, логика распределена по компонентам.*

1. Создай файл `Visuals/Doll3D.gd`:

```gdscript
# Visuals/Doll3D.gd
class_name Doll3D extends Node3D

## Корневой узел 3D-куклы персонажа. 
## В Godot 4 он максимально облегчен. Вся магия происходит в SkeletonModifier3D.

@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

# Ссылки на модификаторы для быстрого доступа
var _deform_modifiers: Dictionary = {} # StringName -> DeformModifier3D

func _ready() -> void:
    # Ищем все модификаторы деформации в скелете
    if skeleton:
        for child in skeleton.get_children():
            if child is DeformModifier3D:
                _deform_modifiers[child.bone_name] = child

## Настраивает параметр деформации (например, размер груди "DeformBreasts")
func set_deformation(bone_name: StringName, scale: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
    if _deform_modifiers.has(bone_name):
        var mod: DeformModifier3D = _deform_modifiers[bone_name]
        mod.scale_factor = scale
        mod.position_offset = offset
    else:
        push_warning("Doll3D: Модификатор для кости %s не найден!" % bone_name)

## Воспроизводит анимацию (инкапсулирует AnimationPlayer)
func play_animation(anim_name: StringName) -> void:
    if animation_player and animation_player.has_animation(anim_name):
        animation_player.play(String(anim_name))
```

---

## Критерии приемки (Проверь себя перед завершением):

1. [ ] Создана директория `Visuals/SkeletonModifiers/`.
2. [ ] Созданы скрипты модификаторов: `DeformModifier3D.gd` и `JiggleModifier3D.gd` (они наследуют Godot 4 класс `SkeletonModifier3D`).
3. [ ] Создан ECS компонент `DollPartManager.gd` в папке `Components/`. Убедись, что он наследует `Component`.
4. [ ] Создан корневой визуал `Doll3D.gd` в папке `Visuals/`.
5. [ ] Весь код использует GDScript 2.0 (типизация `-> void`, `@export`, `@tool`).
