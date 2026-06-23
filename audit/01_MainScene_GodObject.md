# MainScene.gd — God Object Analysis

> Файл: `Game/MainScene.gd` — 2375 строк

## 1. Обзор

`MainScene` — центральный объект игры, единственная точка входа для управления всеми подсистемами. Это **textbook God Object** с 15+ различными ответственностями.

## 2. Ответственности (15+)

| # | Ответственность | Строки | Описание |
|---|----------------|--------|----------|
| 1 | **Save/Load** | 485-655 | Сериализация/десериализация 20+ подсистем |
| 2 | **Флаги (3 пространства)** | 860-1066 | Глобальные, модульные, датапаковые (~207 строк) |
| 3 | **Управление временем** | 719-827 | Дни, недели, время суток, обработка тиков |
| 4 | **Стек сцен** | 289-403 | runScene, removeScene, pickOption |
| 5 | **Реестр статических NPC** | 131-215 | createStaticCharacters, getCharacter |
| 6 | **Жизненный цикл динамических NPC** | 131-215 | add/remove/update dynamic characters |
| 7 | **Пул персонажей** | 131-215 | addDynamicCharacterToPool и т.д. |
| 8 | **Загрузка датапаков** | 2178-2285 | loadDatapack, unloadDatapack, reloadDatapack |
| 9 | **Отладочный инструментарий** | 1233-1964 | getDebugActions + doDebugAction (~750 строк) |
| 10 | **Рабство игрока** | 2333-2364 | startPlayerSlavery, stopPlayerSlavery |
| 11 | **Применение World Edits** | 434-443 | applyAllWorldEdits, applyWorldEdit |
| 12 | **Отслеживание лута комнат** | varies | canLootRoom, markRoomAsLooted |
| 13 | **Система воспоминаний комнат** | varies | addRoomMemory, getRoomMemory, roomMemoriesProcessDay |
| 14 | **Оркестрация UI** | varies | setLocationName, aimCamera |
| 15 | **Воспроизведение анимаций** | varies | playAnimation, playAnimationForceReset |
| 16 | **Система логов/сообщений** | varies | addMessage, addLogMessage, showLog |
| 17 | **Override игрока (NPC possession)** | varies | overridePC, clearOverridePC |
| 18 | **Управление подземельями** | varies | isInDungeon, stopDungeonRun |
| 19 | **Настройки встреч** | varies | getEncounterSettings |
| 20 | **Регистрация консольных команд** | 249-254 | — |
| 21 | **Управление Rollbacker** | varies | делегирует в Rollbacker |
| 22 | **Проверка доп. сцен** | varies | checkTFs, checkLayEggs, checkExtraScenes |
| 23 | **NPC event queries** | varies | isCharacterInAnyNPCEvent, isCharacterInAnySexEngine |

## 3. Методы-монстры

### 3.1 `doDebugAction()` (строки 1690-1964) — 275 строк

Цепочка `if/elif` с **30+ ветками**, каждая обращается к完全不同ным подсистемам:

```gdscript
if(id == "giveItem"):
    GM.pc.getInventory().addItem(item)
elif(id == "healPC"):
    GM.pc.addPain(-GM.pc.painThreshold())
elif(id == "startSlavery"):
    runScene(...)
elif(id == "stuffEgg"):
    theMenstrualCycle.addTentacleEgg(...)
elif(id == "duplicateAndEnslave"):
    # 50 строк копирования инвентаря/экипировки/personality
```

### 3.2 `saveData()` (строки 485-526) — 40 строк

Знает внутренний формат сохранения **20+ подсистем**:

```gdscript
data["EventSystem"] = GM.ES.saveData()
data["ChildSystem"] = GM.CS.saveData()
data["world"] = GM.world.saveData()
data["interactionSystem"] = IS.saveData()
data["relationshipSystem"] = RS.saveData()
data["auctionBidders"] = SAB.saveData()
data["science"] = SCI.saveData()
data["playerSlaveryHolder"] = PSH.saveData()
data["drugDen"] = DrugDenRun.saveData() if DrugDenRun != null else null
```

### 3.3 `loadData()` (строки 528-615) — 88 строк

Зеркало saveData. Знает как реконструировать каждую систему из сериализованных словарей, включая восстановление стека сцен и условные null-проверки для опциональных систем.

## 4. Внутренние экземпляры подсистем

```gdscript
var IS:InteractionSystem = InteractionSystem.new()
var RS:RelationshipSystem = RelationshipSystem.new()
var WHS:WorldHistory = WorldHistory.new()
var SAB:SlaveAuctionBidders = SlaveAuctionBidders.new()
var SCI:Science = Science.new()
var DrugDenRun:DrugDen
var PS:PlayerSlaveryBase
var PSH:PlayerSlaveryHolder = PlayerSlaveryHolder.new()
var RCS:RecruitSystem = RecruitSystem.new()
```

Внешний код обращается к ним через `GM.main.IS`, `GM.main.RS` и т.д. — двухуровневая косвенность.

## 5. Зависимости

### Внешние синглтоны (доступ из MainScene)
- `GlobalRegistry`, `SAVE`, `OPTIONS`, `Console`, `Flag`, `FlagType`, `Log`, `Util`, `RNG`, `GlobalTooltip`

### Обратные зависимости (MainScene обращается к)
- `GM.main`, `GM.pc`, `GM.ui`, `GM.world`, `GM.ES`, `GM.CS`, `GM.GES`, `GM.PROFILE`

### Изолированные системы
- **Rollbacker** (88 строк) — единственная чистая, изолированная система. Один метод: снимок состояния + откат. Обратный пример MainScene.

## 6. Рекомендации по декомпозиции

| Новый класс | Ответственность |
|---|---|
| `FlagManager` | Все операции с флагами (3 пространства) |
| `TimeManager` | Время, дни, недели, processTime |
| `SceneManager` | Стек сцен, runScene, pickOption |
| `SaveManager` | Сериализация/десериализация всех подсистем |
| `DebugManager` | getDebugActions + doDebugAction |
| `DatapackManager` | loadDatapack, unloadDatapack, reloadDatapack |
| `DynamicCharacterManager` | add/remove/update/pool динамических NPC |

MainScene останется координатором, но будет **делегировать**, а не **делать**.

## 7. Ключевые проблемы

1. **SRP violation** — 15+ ответственностей в одном классе
2. **Two-tier coupling** — `GM.main.IS`, `GM.main.RS` делают зависимости невидимыми
3. **Строковая маршрутизация флагов** — `"ModuleID.FlagID"` через строковый парсинг
4. **Debug action chain** — 30+ веток if/elif без диспатча
5. **Нет абстракции для save/load** — каждая подсистема знает формат другой
