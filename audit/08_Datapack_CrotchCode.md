# Datapack System & CrotchCode — Architecture Analysis

> `Game/Datapacks/` — ~40 .gd файла
> `Game/Datapacks/UI/CrotchCode/` — 287 файлов, ~11,143 строк

## 1. Обзор

Система пользовательского контента. Позволяет создавать персонажей, скины, сцены, квесты **без GDScript** через визуальный редактор (CrotchCode — drag-and-drop блоки,类似 Scratch).

## 2. Структура Datapack

`Datapack.gd` (348 строк) — корневой контейнер. Датапаки — **не JSON**, а Godot `.res` ресурсы со словарями:

```gdscript
var characters:Dictionary = {}  # DatapackCharacter экземпляры
var skins:Dictionary = {}       # DatapackSkin экземпляры
var scenes:Dictionary = {}      # DatapackScene экземпляры
var quests:Dictionary = {}      # DatapackQuest экземпляры
var flags:Dictionary = {}       # Типизированные определения флагов
```

### 2.1 DatapackCharacter (502 строки)

~40 полей: stats, bodyparts, equipped items, loot tables, fetishes, portraits (PNG byte arrays), flags `excludeEncounters`, `disableBirth`.

### 2.2 DatapackScene

Содержит **состояния**, каждое с `CrotchSlotCalls` (цепочка блоков). Также объявляет переменные (`vars`), алиасы персонажей (`chars`), триггеры и изображения.

### 2.3 DatapackQuest

Минимальная обёртка: имя, флаг `isMain`, число приоритета и `SlotCalls` цепочка блоков.

## 3. CrotchCode — визуальный язык программирования

### 3.1 Исполнительный движок

`CodeContex.gd` (727 строк) — tree-walking интерпретатор с:

- **Типизированные переменные** — scene-local vars и persistent flags с типами `BOOL`/`STRING`/`NUMBER`
- **Обработка ошибок** — `throwError()` ставит `errored = true`, исполнение останавливается через `shouldReturn()`
- **Run vs React режимы** — блоки могут требовать `makeSureRunMode()` или `makeSureReactMode()`

Исполнение начинается с `CodeContex.execute(slotCalls)`:

```gdscript
# SlotCalls.gd line 22
func execute(_contex:CodeContex):
    for block in blocks:
        block.execute(_contex)
        if(_contex.hadAnError()):
            _contex.resetErrored()
        if(_contex.shouldReturn()):
            return
```

### 3.2 Типы блоков

`CrotchBlocks.gd` определяет **4 типа**: `CALL` (выражения), `VALUE` (значения), `LOGIC` (условия), `RETURNCALL`. Статический метод `getAll()` регистрирует **~170 блоков** в 14 категориях:

| Категория | Примеры блоков |
|-----------|---------------|
| **Logic** | `FlowIf`, `FlowIfElse`, `LogicAnd/Or/Not` |
| **Math** | `MathPlus`, `MathMinus`, `MathMult`, `MathDivide` |
| **Scene** | `SceneSay`, `SceneButton`, `SceneCharAdd`, `ScenePlayAnim` |
| **Quest** | `QuestStage`, `QuestMarkAsVisible`, `QuestMarkAsCompleted` |
| **Game** | `GameProcessTime`, `GameGetDays`, `GameGetTime`, `GameAddLog` |
| **Inventory** | `InvAddItemID`, `InvRemoveItemID`, `InvForceEquipItemID` |
| **NPC** | `NpcSetPersStat`, `NpcSetBreastSize`, `NpcEncountersExclude` |
| **Lewd** | `LewdFuck`, `LewdCumInside`, `LewdGiveBirth`, `LewdMilk` |
| **TF** | `TFCanHas`, `TFStartTF`, `TFProgress`, `TFDoUnlock` |
| **Flags/Vars** | `FlagGet`, `FlagSet`, `VarGet`, `VarSet`, `FlagGlobGet`, `FlagGlobSet` |
| **Strings** | `StringConcat`, `StringHas`, `StringReplace`, `StringSubstr` |
| **RNG** | `RNGChance`, `RNGFloat`, `RNGInt` |

### 3.3 Пример выполнения блока

```gdscript
# FlowIf
func execute(_contex:CodeContex):
    var ifValue = conditionSlot.getValue(_contex)
    if(ifValue):
        return thenSlot.execute(_contex)
    return false
```

Слоты композитные: `CrotchSlotVar` хранит raw-значение или вложенный блок (expression trees). `CrotchSlotCalls` — упорядоченные списки блоков.

### 3.4 UI редактора

- Block picker windows
- Animation pickers
- Map location pickers
- Flag editors
- Visual slot system для вложенных вызовов
- Spell checker
- Preview запуска
- Undo/Redo

## 4. Ограничения

### 4.1 Нет While loop

`FlowWhile` существует как имя, но не зарегистрирован в `getAll()` — возможно, незавершён или удалён. `shouldBreak()`/`shouldContinue()` **всегда возвращают false** (строки 105-109).

### 4.2 Синхронное исполнение

Движок полностью синхронный — нет async/await. Сложные ветвления с взаимодействием игрока требуют разбиения на состояния.

### 4.3 Обработка ошибок per-statement

Ошибки сбрасываются и исполнение продолжается — может маскировать каскадные сбои.

### 4.4 Контекст

Vars не очищаются по умолчанию (закомментировано на строке 122), но флаги сбрасываются.

## 5. Сильные стороны

1. **Нулевой порог входа** — моддеры создают контент без кода
2. **170+ блоков** — покрывают все аспекты игры
3. **Встроенный редактор** — не нужен Godot Editor
4. **In-game preview** — одна кнопка для тестирования
5. **Spell checker** — встроенный

## 6. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Добавить While loop и break/continue |
| **Высокий** | Исправить каскадную обработку ошибок |
| **Средний** | Добавить функции (function call блоки) |
| **Средний** | Добавить async callback для player input |
| **Низкий** | Добавить debugger с breakpoint'ами |
