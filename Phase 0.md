Вот подробнейший `TODO.md` для агента MiMo-v2.5. Он написан в формате жестких императивных инструкций с точным указанием путей к файлам и готовым кодом, чтобы минимизировать галлюцинации ИИ.

Скопируй этот текст, сохрани как `PHASE0_TODO.md` и скорми агенту.

***

# TODO.md — BDCC: Reforged (Фаза 0: Фундамент)

## Контекст для агента

Твоя задача — создать фундамент ремейка игры BDCC на движке **Godot 4.x (GDScript 2.0 + C#)**. Старый проект был гигантским монолитом со спагетти-кодом (God Objects, 4000+ строк в файле). 
Мы используем **Паттерн Композиции**, **Dependency Injection (Service Locator)** и **Data-Driven подход (Custom Resources)**. 

Строго следуй инструкциям. Не придумывай лишней логики. Создавай только те файлы и папки, которые указаны ниже.

---

## ШАГ 1: Инициализация структуры проекта

Создай следующую иерархию папок в корне проекта:

- `Autoloads/` — для глобальных синглтонов.
- `Core/` — для базовых систем (ServiceLocator, Registry).
- `Resources/` — для Custom Resources (.tres).
- `Resources/Items/` — для данных о предметах.
- `Entities/` — для акторов (NPC, Игрок).
- `Components/` — для компонентов узлов (ECS).

---

## ШАГ 2: Создание Глобальной Шины Событий (EventBus)

*Убийца жесткой связности из старого `GM.main`.*

1. Создай файл `Autoloads/EventBus.gd`.
2. Вставь в него следующий код:

```gdscript
# Autoloads/EventBus.gd
extends Node

## Глобальная шина событий для развязки систем.
## Скрипты не должны обращаться друг к другу напрямую, они должны слушать и вызывать эти сигналы.

# Время и мир
signal time_advanced(minutes: int)
signal new_day_started(day_number: int)

# Взаимодействия и NPC
signal npc_relationship_changed(npc_a: StringName, npc_b: StringName, rel_type: StringName, amount: float)
signal npc_spawned(npc_id: StringName, room_id: StringName)

# Секс-движок (SexEngine)
signal sex_event_triggered(event_type: StringName, participants: Array[Node], location: StringName)

# Инвентарь и статы
signal item_added(entity: Node, item_id: StringName, amount: int)
signal stat_changed(entity: Node, stat_name: StringName, old_value: float, new_value: float)
```

---

## ШАГ 3: Создание Service Locator (Внедрение зависимостей)

*Убийца старого `GM.gd`. Позволяет получать доступ к менеджерам безопасно.*

1. Создай файл `Core/ServiceLocator.gd`.
2. Вставь в него следующий код:

```gdscript
# Core/ServiceLocator.gd
extends Node

## Простой DI-контейнер. Заменяет старый GM-монолит.
var _services: Dictionary = {}

## Регистрирует сервис (менеджер) в локаторе
func register_service(service_name: StringName, service_node: Node) -> void:
    if _services.has(service_name):
        push_warning("ServiceLocator: Перезапись сервиса %s" % service_name)
    _services[service_name] = service_node

## Получает сервис. Если его нет, бросает ошибку (помогает ловить баги на этапе загрузки)
func get_service(service_name: StringName) -> Node:
    assert(_services.has(service_name), "ServiceLocator: Критическая ошибка! Сервис %s не зарегистрирован!" % service_name)
    return _services[service_name]

## Удаляет сервис
func unregister_service(service_name: StringName) -> void:
    _services.erase(service_name)
```

**Инструкция для движка:** Обязательно добавь `EventBus.gd` и `ServiceLocator.gd` в список **Autoload** (Project Settings -> Globals) с именами `EventBus` и `ServiceLocator` соответственно.

---

## ШАГ 4: Переход на Custom Resources (Замена GlobalRegistry)

*Вместо гигантского `GlobalRegistry.gd` с тысячами строк парсинга строк, мы используем нативные ресурсы Godot 4.*

1. Создай базовый класс для предметов. Создай файл `Resources/ItemData.gd`:

```gdscript
# Resources/ItemData.gd
class_name ItemData extends Resource

@export var id: StringName = &"unknown_item"
@export var display_name: String = "Unknown Item"
@export_multiline var description: String = ""
@export var base_price: int = 0
@export var icon: Texture2D
@export var is_stackable: bool = true
@export var max_stack: int = 99
```

2. Создай менеджер реестра (он будет сканировать папки и грузить `.tres` в память). Создай файл `Core/RegistryManager.gd`:

```gdscript
# Core/RegistryManager.gd
class_name RegistryManager extends Node

var items: Dictionary = {} # StringName -> ItemData

func _ready() -> void:
    ServiceLocator.register_service(&"RegistryManager", self)
    _load_all_items("res://Resources/Items/")

func get_item(item_id: StringName) -> ItemData:
    if items.has(item_id):
        return items[item_id]
    push_error("RegistryManager: Предмет %s не найден!" % item_id)
    return null

func _load_all_items(path: String) -> void:
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if !dir.current_is_dir() and file_name.ends_with(".tres"):
                var res = load(path + file_name) as ItemData
                if res:
                    items[res.id] = res
            file_name = dir.get_next()
```

---

## ШАГ 5: Entity-Component System (Убийство BaseCharacter.gd)

*Старый `BaseCharacter.gd` содержал 3900 строк (секс, инвентарь, здоровье, ИИ). Мы разбиваем его на компоненты.*

1. Создай базовый класс компонента. Создай файл `Components/Component.gd`:

```gdscript
# Components/Component.gd
class_name Component extends Node

## Ссылка на родительскую сущность
var entity: Node

func _ready() -> void:
    # Ожидаем, что компонент всегда является дочерним узлом Entity
    entity = get_parent()
    assert(entity != null and entity.has_method("get_component"), "Компонент должен быть дочерним элементом Entity!")
```

2. Создай сущность (Entity). Создай файл `Entities/Entity.gd`:

```gdscript
# Entities/Entity.gd
class_name Entity extends Node3D

@export var entity_id: StringName = &"npc_unknown"

## Простой кэш компонентов для быстрого доступа (O(1))
var _components: Dictionary = {}

func _ready() -> void:
    # Автоматически регистрируем все дочерние узлы-компоненты
    for child in get_children():
        if child is Component:
            _components[child.name] = child

## Получает компонент по его имени узла.
func get_component(component_name: StringName) -> Component:
    if _components.has(component_name):
        return _components[component_name]
    return null

## Проверяет наличие компонента
func has_component(component_name: StringName) -> bool:
    return _components.has(component_name)
```

3. Создай первый практический компонент (Здоровье и Выносливость). Создай файл `Components/HealthComponent.gd`:

```gdscript
# Components/HealthComponent.gd
class_name HealthComponent extends Component

@export var max_stamina: float = 100.0
@export var pain_threshold: float = 100.0

var current_stamina: float = 100.0
var current_pain: float = 0.0

func add_pain(amount: float) -> void:
    var old_pain = current_pain
    current_pain = clampf(current_pain + amount, 0.0, pain_threshold)

    # Вместо прямого вызова UI, оповещаем шину событий!
    EventBus.stat_changed.emit(entity, &"pain", old_pain, current_pain)

    if current_pain >= pain_threshold:
        _pass_out()

func consume_stamina(amount: float) -> bool:
    if current_stamina >= amount:
        var old_stamina = current_stamina
        current_stamina -= amount
        EventBus.stat_changed.emit(entity, &"stamina", old_stamina, current_stamina)
        return true
    return false

func _pass_out() -> void:
    # Персонаж теряет сознание
    EventBus.sex_event_triggered.emit(&"passed_out", [entity], &"any")
```

---

## Критерии приемки (Проверь себя перед завершением):

1. [ ] Убедись, что все файлы созданы ровно по указанным путям.
2. [ ] Убедись, что используется синтаксис GDScript 2.0 (`-> void`, типизация).
3. [ ] Убедись, что `EventBus` и `ServiceLocator` добавлены в Autoload (через редактирование `project.godot` или средствами редактора, если есть доступ).
4. [ ] Проверь, что в `HealthComponent.gd` нет прямых вызовов других менеджеров, а используется только `EventBus`.

**Действуй! Приступай к созданию файлов и директорий по порядку.**
