# InteractionSystem — Architecture Analysis

> Директория: `Game/InteractionSystem/` — 63 .gd файла, ~11,401 строк

## 1. Обзор

Система имитации жизни NPC в тюрьме. Pawns (NPC-сущности) перемещаются по карте, взаимодействуют друг с другом, выполняют задачи. Игрок — один из pawns.

## 2. Структура

| Директория | Файлов | Назначение |
|-----------|--------|-----------|
| `AloneGoals/` | 20 | Цели для одиноких pawns |
| `GlobalTasks/` | 10 | Глобальные задачи (еда, душ, работа) |
| `Interactions/` | 17 | Типы взаимодействий (fight, sex, flirt, talk) |
| `PawnTypes/` | 4 | Типы pawns (inmate, guard, nurse, engineer) |
| `Relationship/` | 6 | Система отношений |

## 3. Управление Pawn'ами

`InteractionSystem` (extends `Reference`) — центральный координатор. Pawns живут в двух словарях:

```gdscript
var pawns:Dictionary = {}       # charID -> CharacterPawn
var pawnsByLoc:Dictionary = {}  # location -> {charID: true}
```

### 3.1 Утренняя волна

Спавнит 70-90% от максимального количества pawns, распределяя пропорционально по весам типов:

```gdscript
func spawnMorningWave():
    var howManyToSpawn:int = int(getMaxPawnCount() * RNG.randf_range(0.7, 0.9))
    for charType in pawnDistribution:
        var share:float = float(pawnDistribution[charType]) / totalDistAm
        for _i in int(round(share * howManyToSpawn)):
            trySpawnPawn(charType)
    processAllPawnsNoInteractions(60*RNG.randi_range(150,170))
```

### 3.2 Инкрементальный спавн

```gdscript
var chanceToAddNew:float = (1.0 - fullness) * 10.0  # Больше шанс при малом количестве
```

Не спавнит после 19:00 или в подземельях.

## 4. Time-Slicing

Система делит симуляционное время на 60-секундные тики, ограниченные 10 за кадр:

```gdscript
while(_timeCopy > 0 && didSimulations < 10):
    var timeslice:int = Util.mini(60, _timeCopy)
    _timeCopy -= timeslice
    didSimulations += 1
    processBusyAllInteractions(timeslice)
```

### 4.1 Распределение interactions по тикам

С N interactions делятся на 1-5 "tick groups" (batch ~40), каждая обрабатывается в чередующихся тиках:

```gdscript
var howManyTicks:int = clamp(ceil(float(interactions.size()) / 40.0), 1, 5)
var howManyToProcess:int = ceil(float(interactions.size()) / float(howManyTicks))
for _i in howManyToProcess:
    var _indx:int = _i * howManyTicks + internalTick
```

**Проблема**: Interactions в поздних batch'ах получают `finalHowManySeconds = howManySeconds * howManyTicks` — умноженное время, что приводит к непоследовательной скорости симуляции.

## 5. Триггеринг и разрешение взаимодействий

### 5.1 Триггеринг

Interactions триггерятся при движении pawn'а: `onPawnMoved()` → `onMeetWith()` → `checkOnMeetInteractions()`. Каждый зарегистрированный тип interaction проверяется через `shouldRunOnMeet()`. Если ни один не подходит — `PawnReactions.doReact()` с cooldown'ом.

### 5.2 Выбор действия

Используется взвешенная оценка. Монолитный `getScoreTypeValueGenericInternal()` (~500 строк) вычисляет оценки для ~20 типов действий:

```gdscript
var minScore:float = maxScore * 0.1
for action in actions:
    if(action["finalScore"] >= minScore):
        possibleActions.append([action, action["finalScore"]])
var selectedAction = RNG.pickWeightedPairs(possibleActions)
```

### 5.3 State machine

Диспатч методов через `has_method()`: `state + "_text"`, `state + "_actions"`, `state + "_do"`.

## 6. Goals

`InteractionGoalBase` оценивает, что делать одинокому pawn'у. `GlobalTask` ограничивает участие: `maxAssignedUnscaled * (pawnCount/30)`. Goals связаны с глобальными задачами через `goal.globalTask`. `assignedCached` даёт O(1) проверку назначений.

## 7. Связь с World.gd

`World.gd` связывает логику с визуалом. `updatePawns(IS)` итерирует все pawns, создаёт/перемещает `WorldPawn` инстансы как children of room floor nodes, устанавливает текстуру (masc/fem), цвет (по типу NPC), видимость ошейника.

## 8. Производительность

### Сильные стороны
- `pawnsByLoc` пространственный индекс — O(1) запросы по комнатам
- Встроенный профайлинг (`GM.PROFILE.start/finish`)
- Time-slicing ограничивает работу за кадр
- Распределение interactions по тикам

### Слабые стороны
- `interactions.duplicate()` вызывается **каждый тик** в `processBusyAllInteractions` — O(n) аллокация за кадр
- `stopInteractionsForPawnID()` также дублирует и линейно сканирует
- `recalculateAllAssignedGlobalTasks()` — O(pawns * interactions), автор называет "very slow"
- `pawnsByLoc` хранит `Dictionary` of `Dictionary` со значениями `true` вместо `Set` — расточительно
- 500-строчный score function пересчитывает personality lookups без кэширования
- Нет пространственной разбивки за пределами плоской локации; `getPawnsNear()` делает BFS через граф комнат при каждом вызове

## 9. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Убрать `interactions.duplicate()` — использовать immutable snapshot |
| **Высокий** | Кэшировать personality lookups в score function |
| **Высокий** | Заменить `Dictionary{charID: true}` на `Set` |
| **Средний** | Добавить кэш для `getPawnsNear()` |
| **Средний** | Сбалансировать time-slicing (убрать умножение времени) |
| **Низкий** | Разбить `getScoreTypeValueGenericInternal()` на отдельные scorer'ы |
