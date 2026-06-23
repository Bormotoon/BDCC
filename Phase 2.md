Переходим к **Фазе 2: Симуляция жизни (Interaction System 2.0)**. 

В старой игре `InteractionSystem.gd` был бутылочным горлышком. Он обрабатывал 70+ NPC, каждый из которых был тяжёлым объектом, и пересчитывал всё в одном потоке, вызывая лаги.
В `BDCC: Reforged` мы меняем парадигму на **Data-Oriented Design (DOD)**. Мы выносим тяжёлую симуляцию в массивы структур (Structs) и используем мощь **C#** для многопоточности (`Parallel.For`), а `GDScript` оставляем только как мост для общения с `EventBus`.

*(Примечание: Для работы C# скриптов потребуется Godot 4 .NET версия. Агент просто создаст файлы, компилировать их будет уже движок).

***

# TODO.md — BDCC: Reforged (Фаза 2: C# Симуляция Жизни)

## Контекст для агента

Твоя задача — заложить фундамент новой многопоточной системы симуляции тюрьмы (Interaction System). Старая система тормозила из-за того, что каждый NPC был тяжелым объектом, а расчеты велись в главном потоке.

Мы переходим на **Data-Oriented Design (DOD)**:

1. Данные NPC хранятся в плоском массиве (C# `struct`).
2. Логика ИИ обрабатывается асинхронно через `Parallel.For` (C#).
3. Общение с остальной игрой (которая написана на GDScript) идет через класс-мост (Bridge) и `EventBus`.

Строго создай указанные файлы по указанным путям. Не меняй имена классов и не добавляй лишних методов.

---

## ШАГ 1: Структура данных NPC (C# Struct)

*Используем `struct` вместо `class`, чтобы данные хранились в кэше процессора (Data Locality). Это ускорит перебор сотен NPC в сотни раз.*

1. Создай папку `Simulation/`.
2. Создай файл `Simulation/NpcData.cs`:

```csharp
// Simulation/NpcData.cs
using Godot;

public struct NpcData
{
    public StringName Id;
    public StringName CurrentRoom;
    public float Health;
    public float Lust;
    public float AffectionToPlayer;
    public int CurrentActionId;
    public bool IsActive;
}
```

---

## ШАГ 2: Многопоточный движок симуляции (C# Node)

*Этот класс будет висеть в памяти и раз в тик пересчитывать логику всех NPC параллельно, не блокируя основной FPS игры.*

1. Создай файл `Simulation/SimulationEngine.cs`:

```csharp
// Simulation/SimulationEngine.cs
using Godot;
using System.Threading.Tasks;

public partial class SimulationEngine : Node
{
    // Плоский массив для максимальной скорости (DOD)
    public NpcData[] Npcs;
    private int _npcCount = 0;
    private readonly object _lockObj = new object();

    public override void _Ready()
    {
        // Выделяем память заранее (максимум 1000 NPC)
        Npcs = new NpcData[1000];
    }

    // Вызывается из GDScript
    public void AddNpc(StringName id, StringName startingRoom)
    {
        lock (_lockObj)
        {
            if (_npcCount >= Npcs.Length) return;

            Npcs[_npcCount] = new NpcData 
            { 
                Id = id, 
                CurrentRoom = startingRoom, 
                Health = 100f, 
                IsActive = true 
            };
            _npcCount++;
        }
    }

    // Главный метод симуляции, вызываемый при перемотке времени
    public void ProcessSimulationTick(float deltaMinutes)
    {
        if (_npcCount == 0) return;

        // Многопоточный проход по всем NPC
        Parallel.For(0, _npcCount, i =>
        {
            if (!Npcs[i].IsActive) return;

            // Базовая симуляция потребностей
            Npcs[i].Lust += deltaMinutes * 0.1f;

            // Защита от переполнения
            if (Npcs[i].Lust > 100f) Npcs[i].Lust = 100f;

            // Здесь в будущем будет логика поиска пути в RoomGraph
            // и выбор действий (Деревья поведения)
        });
    }
}
```

---

## ШАГ 3: Абстрактный граф комнат (Room Graph)

*NPC больше не должны использовать 3D-поиск пути (NavigationMesh), если они не в одной комнате с игроком. Они просто перемещаются по логическому графу.*

1. Создай файл `Simulation/RoomGraph.gd`:

```gdscript
# Simulation/RoomGraph.gd
class_name RoomGraph extends RefCounted

## Логический граф тюрьмы для быстрого перемещения NPC за кадром.
## Хранит связи: откуда -> куда можно пройти.

var _connections: Dictionary = {} # StringName -> Array[StringName]

## Добавляет двустороннюю связь между комнатами
func add_connection(room_a: StringName, room_b: StringName) -> void:
    if not _connections.has(room_a):
        _connections[room_a] = [] as Array[StringName]
    if not _connections.has(room_b):
        _connections[room_b] = [] as Array[StringName]

    if not _connections[room_a].has(room_b):
        _connections[room_a].append(room_b)
    if not _connections[room_b].has(room_a):
        _connections[room_b].append(room_a)

## Проверяет, можно ли пройти напрямую
func are_connected(room_a: StringName, room_b: StringName) -> bool:
    if _connections.has(room_a):
        return _connections[room_a].has(room_b)
    return false
```

---

## ШАГ 4: GDScript Мост (Bridge)

*Этот скрипт связывает мир Godot (EventBus) и быструю симуляцию на C#.*

1. Создай файл `Simulation/SimulationBridge.gd`:

```gdscript
# Simulation/SimulationBridge.gd
class_name SimulationBridge extends Node

## Мост между GDScript событиями и C# движком симуляции.
## Инициализирует C# ноду и прокидывает ей сигналы.

var csharp_engine: Node
var room_graph: RoomGraph

func _ready() -> void:
    # Загружаем C# скрипт. В Godot 4 это делается прозрачно.
    var CSharpScript = load("res://Simulation/SimulationEngine.cs")
    csharp_engine = CSharpScript.new()
    add_child(csharp_engine)

    room_graph = RoomGraph.new()

    # Регистрируем в нашем DI-контейнере
    ServiceLocator.register_service(&"SimulationBridge", self)

    # Подписываемся на глобальные события времени и спавна
    EventBus.time_advanced.connect(_on_time_advanced)
    EventBus.npc_spawned.connect(_on_npc_spawned)

func _on_time_advanced(minutes: int) -> void:
    # Прокидываем тик в C#
    if csharp_engine and csharp_engine.has_method("ProcessSimulationTick"):
        csharp_engine.ProcessSimulationTick(float(minutes))

func _on_npc_spawned(npc_id: StringName, room_id: StringName) -> void:
    # Регистрируем NPC в C# массиве
    if csharp_engine and csharp_engine.has_method("AddNpc"):
        csharp_engine.AddNpc(npc_id, room_id)
```

---

## Критерии приемки (Проверь себя перед завершением):

1. [ ] Создана папка `Simulation/`.
2. [ ] Созданы C# файлы `NpcData.cs` и `SimulationEngine.cs` (используется `using Godot;` и `Parallel.For`).
3. [ ] Созданы GDScript файлы `RoomGraph.gd` и `SimulationBridge.gd`.
4. [ ] `SimulationBridge.gd` подписывается на сигналы `EventBus` и регистрирует себя в `ServiceLocator`.
5. [ ] Нет использования 3D-узлов внутри C# симуляции (только чистые данные и StringName).
