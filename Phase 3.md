Теперь переходим к **Фазе 3: Ядро геймплея — SexEngine 2.0**.

Старый движок (`SexEngine.gd`) состоял из почти 2000 строк спагетти-кода. Он использовал опасный подход со строками (`if has_method(state + "_processTurn")`). Если где-то была опечатка, скрипт тихо ломался.
В `BDCC: Reforged` мы внедряем строгий **Паттерн Состояние (State Machine)** и **Паттерн Команда (Command Pattern)** для действий. А для реакции персонажей используем независимый компонент из нашего ECS.ы

***

# TODO.md — BDCC: Reforged (Фаза 3: SexEngine 2.0)

## Контекст для агента

Твоя задача — написать ядро нового движка взаимодействия (SexEngine) для Godot 4.x. Старый подход со строковым конечным автоматом (String-based State Machine) полностью удаляется. 

Новая архитектура:

1. **SexState (Состояние)**: Базовый класс для всех позиций/активностей (например, "Blowjob", "Missionary").
2. **SexAction (Действие)**: Данные о конкретном действии (Thrust, Spank, Kiss).
3. **SexEngine (Оркестратор)**: Менеджер, переключающий состояния и управляющий участниками.
4. **SexReactionComponent**: Компонент, висящий на сущностях, который слушает шину событий (`EventBus`) и изменяет статы (возбуждение, боль).

Строго следуй инструкциям. Используй GDScript 2.0 (строгая типизация).

---

## ШАГ 1: Базовый класс Состояния (State Pattern)

*Этот класс заменит гигантские методы-простыни старого движка. Каждая секс-позиция будет наследоваться от него.*

1. Создай папку `Systems/SexEngine/`.
2. Создай файл `Systems/SexEngine/SexState.gd`:

```gdscript
# Systems/SexEngine/SexState.gd
class_name SexState extends RefCounted

## Базовый класс для всех состояний/активностей в секс-движке.
## Каждая позиция (например, Missionary, Blowjob) наследует этот класс.

var id: StringName = &"base_state"

func enter(engine: Node) -> void:
    pass

func exit(engine: Node) -> void:
    pass

func process_turn(engine: Node) -> void:
    pass

## Возвращает список доступных действий (SexAction) для конкретного участника в этом состоянии
func get_available_actions(participant: Node) -> Array[Resource]:
    return []
```

---

## ШАГ 2: Ресурс Действия (Command Pattern)

*Действия теперь — это настраиваемые ресурсы, а не хардкод.*

1. Создай файл `Systems/SexEngine/SexAction.gd`:

```gdscript
# Systems/SexEngine/SexAction.gd
class_name SexAction extends Resource

## Ресурс, описывающий единичное действие (Thrust, Spank, Lick).

@export var action_id: StringName = &"unknown_action"
@export var name: String = "Unknown Action"
@export var base_pleasure: float = 10.0
@export var base_pain: float = 0.0
@export var is_dom_action: bool = true

## Выполняет действие и отправляет событие в шину
func execute(source: Node, target: Node, location: StringName) -> void:
    # Оповещаем весь мир о том, что действие произошло
    EventBus.sex_event_triggered.emit(action_id, [source, target], location)
```

---

## ШАГ 3: Оркестратор движка (Sex Engine)

*Сам движок становится максимально компактным, он лишь переключает состояния и хранит участников.*

1. Создай файл `Systems/SexEngine/SexEngineManager.gd`:

```gdscript
# Systems/SexEngine/SexEngineManager.gd
class_name SexEngineManager extends Node

## Главный координатор секс-сцен. Управляет участниками и текущим состоянием (SexState).

var current_state: SexState
var participants: Array[Node] = []
var location_id: StringName = &"unknown_room"

func _ready() -> void:
    ServiceLocator.register_service(&"SexEngine", self)

func start_scene(scene_participants: Array[Node], room_id: StringName, initial_state: SexState) -> void:
    participants = scene_participants
    location_id = room_id
    change_state(initial_state)

func change_state(new_state: SexState) -> void:
    if current_state:
        current_state.exit(self)

    current_state = new_state

    if current_state:
        current_state.enter(self)

func process_scene_turn() -> void:
    if current_state:
        # Логика принятия решений ИИ выносится в само состояние
        current_state.process_turn(self)

func end_scene() -> void:
    if current_state:
        current_state.exit(self)
    current_state = null
    participants.clear()
```

---

## ШАГ 4: Компонент Реакций (Развязка логики)

*В старой игре SexEngine напрямую лез в статы персонажа. Теперь персонаж сам реагирует на события секса через ECS.*

1. Создай файл `Components/SexReactionComponent.gd`:

```gdscript
# Components/SexReactionComponent.gd
class_name SexReactionComponent extends Component

## Компонент сущности. Слушает EventBus и применяет удовольствие/боль 
## на основе своих фетишей и характеристик.

@export var base_sensitivity: float = 1.0

var health_component: HealthComponent
var current_arousal: float = 0.0

func _ready() -> void:
    super._ready() # Вызов родительского инициализатора
    EventBus.sex_event_triggered.connect(_on_sex_event_triggered)

    # Пытаемся найти HealthComponent для нанесения боли
    if entity.has_method("get_component"):
        health_component = entity.get_component(&"HealthComponent")

func _on_sex_event_triggered(event_type: StringName, event_participants: Array, _location: StringName) -> void:
    # Если мы не участвуем в событии — игнорируем
    if not event_participants.has(entity):
        return

    var is_target = (event_participants.size() > 1 and event_participants[1] == entity)

    # Простейшая логика реакций (в будущем здесь будет работа с фетишами)
    if is_target:
        _handle_received_action(event_type)

func _handle_received_action(action_id: StringName) -> void:
    # Заглушка для обработки базовых действий
    var pleasure_gain = 0.0
    var pain_gain = 0.0

    match action_id:
        &"spank":
            pain_gain = 5.0
            pleasure_gain = 2.0 * base_sensitivity
        &"kiss":
            pleasure_gain = 10.0 * base_sensitivity

    current_arousal = clampf(current_arousal + pleasure_gain, 0.0, 100.0)

    if pain_gain > 0 and health_component:
        health_component.add_pain(pain_gain)
```

---

## Критерии приемки (Проверь себя перед завершением):

1. [ ] Создана директория `Systems/SexEngine/`.
2. [ ] Созданы скрипты `SexState.gd`, `SexAction.gd` и `SexEngineManager.gd` в папке систем.
3. [ ] Скрипт `SexReactionComponent.gd` создан в папке `Components/` и наследует `Component`.
4. [ ] `SexReactionComponent` подписывается на сигнал `EventBus.sex_event_triggered`.
5. [ ] Никаких строковых проверок `has_method` в движке нет. Используется полиморфизм и ООП.
