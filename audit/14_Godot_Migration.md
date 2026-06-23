# Godot 3.x → 4.x Migration — Analysis

## 1. Текущее состояние

| Параметр | Значение |
|---------|----------|
| Текущий движок | Godot 3.6 (config_version=4) |
| Godot 4.x | Вышел март 2023, активно развивается |
| Godot 3.x статус | **End of Life** — не получает обновлений |
| GDScript версия | 1.0 (Godot 3.x) |
| Рендерер | GLES3 / OpenGL |
| HTML5 экспорт | **Deprecated** в Godot 3.x |

## 2. Масштаб проекта для миграции

| Метрика | Значение | Влияние на миграцию |
|---------|---------|-------------------|
| .gd файлов | 3,184 | Каждый может потребовать правок |
| .tscn сцен | 644 | Формат сцен изменился |
| .tres ресурсов | 73 | Формат ресурсов изменился |
| Классов в project.godot | 389 | `_global_script_classes` удалён |
| Шейдеров | 5 | Syntax changes |
| Аддонов | 2 | Нужны совместимые версии |

## 3. Ключевые изменения Godot 4.x

### 3.1 GDScript 2.0

```gdscript
# Godot 3.x
onready var node = $Node
export var value = 10
func _process(delta):
    pass

# Godot 4.x
@onready var node = $Node
@export var value = 10
func _process(delta: float) -> void:
    pass
```

### 3.2 Class hierarchy

```gdscript
# Godot 3.x
extends Reference  # Старое имя
class_name MyClass

# Godot 4.x
extends RefCounted  # Новое имя
class_name MyClass
```

### 3.3 API изменения

| Godot 3.x | Godot 4.x |
|-----------|-----------|
| `Directory` | `DirAccess` |
| `File` | `FileAccess` |
| `PoolStringArray` | `PackedStringArray` |
| `PoolByteArray` | `PackedByteArray` |
| `instance()` | `instantiate()` |
| `connect("signal", obj, "method")` | `signal.connect(callable)` |
| `yield()` | `await` |
| `rand_range()` | `randf_range()` |
| `stepify()` | `snapped()` |
| `var2str()` / `str2var()` | `var_to_str()` / `str_to_var()` |

### 3.4 _global_script_classes

```gdscript
# Godot 3.x — в project.godot (389 элементов!)
_global_script_classes=[{ "base": "Reference", "class": "Attack", ... }]

# Godot 4.x — автоматически определяется из class_name
# УДАЛЕНО — не нужно вручную поддерживать
```

### 3.5 Шейдеры

```glsl
// Godot 3.x
shader_type canvas_item;
void fragment() {
    COLOR = texture(TEXTURE, UV);
}

// Godot 4.x
shader_type canvas_item;
void fragment() {
    COLOR = texture(TEXTURE, UV);
}
// Почти идентично, но some built-in variables renamed
```

## 4. Влияние на конкретные системы

### 4.1 GlobalRegistry (3018 строк)

- **389 `_global_script_classes`** — будут автоматически определены
- Но все string-based ID могут сломаться если class_name изменится
- `load()` API: `load("res://path.gd")` → без изменений
- `Directory` → `DirAccess` во всех registerFolder функциях (52 штуки)

### 4.2 MainScene (2375 строк)

- `onready` → `@onready`
- `export` → `@export`
- Signal connection syntax
- `yield()` → `await` (если используется)

### 4.3 SexEngine (1854 строки)

- `has_method()` + `call()` — без изменений
- String-based state machine — без изменений
- `RNG.randi_range()` → `RNG.randi_range()` (без изменений)

### 4.4 CrotchCode (11,143 строки)

- `has_method()` + `call()` — без изменений
- Движок интерпретатора — minimal changes
- UI ноды: Control API mostly stable

### 4.5 Doll3D (963 строки)

- `set_bone_custom_pose()` → `set_bone_pose()` + `set_bone_rest()`
- `ImmediateGeometry` → `ImmediateMesh`
- Skeleton API changes

### 4.6 Shaders

- `canvas_item` shaders — minimal changes
- `textureLod()` → `textureLod()` (без изменений)
- Some built-in variables renamed

## 5. Оценка трудоёмкости

| Задача | Трудоёмкость | Описание |
|--------|-------------|----------|
| Глобальные замены (onready, export, yield) | Низкая | regex/search-replace по всем 3184 файлам |
| API замены (Directory, File, Pool*) | Средняя | ~200 вызовов Directory, ~50 File |
| Signal connection syntax | Средняя | ~500+ подключений сигналов |
| _global_script_classes removal | Низкая | Удалить из project.godot |
| Skeleton/bone API | Высокая | Doll3D + 70 stage scenes |
| ImmediateGeometry → ImmediateMesh | Средняя | CurveRenderer + шейдеры |
| Визуальная проверка | Очень высокая | 644 сцены, 70 stage scenes |
| Модульная совместимость | Высокая | 870 .gd в Modules |
| Datapack compatibility | Средняя | CrotchCode UI, load/save |

## 6. Риски миграции

### 6.1 Высокие риски
- **644 .tscn сцен** — формат сцен изменился, автоматическая конвертация может сломать связи
- **70 stage scenes** — сложная 3D анимация, костные деформации
- **389 классов** — любая ошибка в class_name = каскадные сбои
- **Модули** — 870 файлов, каждый может иметь уникальные API вызовы

### 6.2 Средние риски
- **CrotchCode UI** — Control API стабилен, но node paths могут измениться
- **Save/Load** — `var2str`/`str2var` → `var_to_str`/`str_to_var` ломает старые сохранения
- **Сигналы** — новый синтаксис, ~500+ мест подключения

### 6.3 Низкие риски
- **Глобальные замены** — automated search-replace
- **Шейдеры** — minimal changes
- **RNG/Util** — стабильный API

## 7. Стратегия миграции

### 7.1 Поэтапный подход (рекомендуется)

**Фаза 1: Подготовка (2-4 недели)**
- Внедрить тесты для критических систем
- Создать baseline screenshots
- Запустить Godot 4.x конвертер на копии проекта

**Фаза 2: Автоматическая конвертация (1-2 недели)**
- Запустить `--convert-project` флаг Godot 4.x
- Исправить глобальные замены (onready, export, yield)
- Исправить API замены (Directory, File, Pool*)

**Фаза 3: Ручная работа (4-8 недель)**
- Исправить skeleton/bone API в Doll3D
- Исправить ImmediateGeometry в CurveRenderer
- Проверить и исправить 644 сцены
- Проверить и исправить 70 stage scenes
- Проверить модули

**Фаза 4: Тестирование (2-4 недели)**
- Визуальная проверка всех сцен
- Проверка сохранений
- Проверка модов/датапаков
- Performance profiling

**Общая оценка: 3-5 месяцев** для активного проекта.

### 7.2 Параллельная поддержка (альтернатива)

Если миграция невозможна:
- Продолжить поддержку Godot 3.x
- Принять deprecated status HTML5 экспорта
- Использовать Godot 3.6 как финальную версию
- Риск: утрата совместимости с новыми платформами

## 8. Преимущества миграции

1. **GDScript 2.0** — типизация, await, лучший синтаксис
2. **Vulkan рендерер** — лучшая производительность
3. **GDExtension** — C++/Rust расширения
4. **Убрать _global_script_classes** — автоматическое определение
5. **Новые ноды** — BetterButton, RichTextLabel improvements
6. **Активная поддержка** — новые фичи, исправления
7. **HTML5 WebGL2** — modern web export

## 9. Рекомендации

| Приоритет | Действие |
|---|---|
| **P0** | Принять решение: миграция или frozen на Godot 3.x |
| **P0** | Если миграция — начать с тестовой инфраструктуры |
| **P1** | Создать prototype migration branch |
| **P1** | Оценить реальную трудоёмкость на prototype |
| **P2** | Составить detailed migration plan |
