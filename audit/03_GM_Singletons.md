# GM.* Singleton Pattern — Analysis

> Определение: `Game/GM.gd` — 29 строк (autoload singleton)

## 1. Определение GM

```gdscript
# Game/GM.gd — autoload singleton
extends Node
var ui: GameUI
var main: MainScene
var pc: Player
var world: GameWorld
var ES: EventSystem
var QS: QuestSystem
var CS: ChildSystem
var GES: GameExtenderSystem
var PROFILE: MyProfilerBase
```

**9 свойств** на самом autoload. Но `GM.main` (MainScene) держит ещё **8 подсистем**:

```gdscript
# Game/MainScene.gd, строки 29-37
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

**Итого: ~18 уникальных ссылок на подсистемы** через двухуровневую косвенность.

## 2. Масштаб использования

| Метрика | Значение |
|---|---|
| `.gd` файлов, ссылающихся на `GM.` | **904** |
| Сайтов доступа `GM.*` | **8,369** |
| Уникальных токенов `GM.*` | **10** |

### Распределение по токенам

| Токен | Обращений | Доля | Назначение |
|---|---|---|---|
| `GM.pc` | 6,128 | 73% | Игрок |
| `GM.main` | 2,195 | 26% | MainScene |
| `GM.world` | 197 | 2% | Мир |
| `GM.ui` | 195 | 2% | Интерфейс |
| `GM.ES` | 158 | 2% | EventSystem |
| `GM.PROFILE` | 42 | <1% | Профайлер |
| `GM.CS` | 42 | <1% | ChildSystem |
| `GM.QS` | 30 | <1% | QuestSystem |
| `GM.GES` | 15 | <1% | GameExtenderSystem |

### Двухуровневые цепочки (502 обращения)

| Цепочка | Обращений |
|---|---|
| `GM.main.IS.*` | ~200 |
| `GM.main.RS.*` | ~150 |
| `GM.main.PSH.*` | ~80 |
| `GM.main.SCI.*` | ~50 |
| `GM.main.WHS.*` | ~22 |

## 3. Худшие примеры связанности

### 3.1 WorldScene.gd — 5 систем в одном методе

```gdscript
# Scenes/WorldScene.gd
GM.ES.triggerRun(Trigger.EnteringRoom, [GM.pc.location])      # EventSystem
var thePawn = GM.main.IS.spawnPawnIfNeeded(someNPC)            # InteractionSystem
GM.main.RS.startSpecialRelantionship("SoftSlavery", someNPC)   # RelationshipSystem
var pawn = GM.main.IS.getPawn("pc")                            # InteractionSystem
GM.main.IS.decideNextAction(interaction, {scene=self})         # InteractionSystem
```

### 3.2 PawnInteractionBase.gd — цепочки из 5+ систем

```gdscript
# Game/InteractionSystem/PawnInteractionBase.gd
GM.main.IS.stopInteractionsForPawnID(pawn.charID)              # InteractionSystem
GM.main.WHS.addEvent(WHEvent.WonFight, ...)                    # WorldHistory
GM.main.RS.sendSocialEvent(domPawn.charID, subPawn.charID, ...) # RelationshipSystem
GM.main.IS.getPawn(pawnID)                                     # InteractionSystem
GM.world.calculatePath(getLocation(), cachedTarget)             # World
```

### 3.3 Файлы с 4+ уникальными токенами GM

| Уникальных токенов | Файл |
|---|---|
| **8** | `Game/MainScene.gd` |
| **6** | `Scenes/EncountersMenuScene.gd` |
| **5** | `Scenes/WorldScene.gd`, `Player/Player.gd`, `PSShaftMinerGameplayScene.gd` |
| **4** | `Scenes/SceneBase.gd`, `Scenes/MeScene.gd`, `SexEngine.gd`, `PawnInteractionBase.gd` |

## 4. Рейтинг связанности подсистем

| # | Подсистема | Внешних обращений | Роль |
|---|-----------|-------------------|------|
| 1 | `GM.pc` | 6,128 | Единственный доступ ко всему состоянию игрока |
| 2 | `GM.main` | 2,195 + 502 (цепочки) | Оркестратор + service locator |
| 3 | `GM.world` | 197 | Навигация, pathfinding, видимость |
| 4 | `GM.ui` | 195 | Все сцены используют GM.ui.say/addButton |
| 5 | `GM.main.RS` + `GM.main.IS` | 502 (цепочки) | Связанность через MainScene |

## 5. Существующие альтернативные паттерны

### Сигналы (узко)
MainScene объявляет `signal time_passed` и `signal saveLoadingFinished`. Player подключает `levelChanged`, `skillLevelChanged` и т.д. Но это **уведомления UI→оркестратор**, а не DI.

### Нет DI-контейнера
Нет service locatorBeyond autoload, нет interface-based decoupling.

### `GM.main.IS` / `GM.main.RS` — это manual service locator
Но вызывающие код всегда идут через `GM.main`, а не получают зависимости через конструктор/аргументы методов.

## 6. Проблемы

1. **God Object через посредника** — GM это не просто синглтон, а service locator с двухуровневой косвенностью
2. **73% обращений** — `GM.pc` используется везде, нет абстракции над состоянием игрока
3. **Неявные зависимости** — вызывающий код не знает, какие системы он затрагивает
4. **Невозможно тестировать** — без DI каждый тест требует полной инициализации GM
5. **Невозможно подменить** — никакая подсистема не может быть замокирована

## 7. Рекомендации

### 7.1 Короткий путь (минимальные изменения)
Оставить GM как service locator, но:
- Вынести `IS`, `RS`, `SCI`, `PSH`, `WHS` на верхний уровень GM
- Ввести интерфейсы для ключевых подсистем
- Добавить setter-методы для тестирования

### 7.2 Средний путь
Создать `GM.register("InteractionSystem", IS)` — service locator с generic API:
```gdscript
# Вместо GM.main.IS.someMethod()
GM.get_service("InteractionSystem").someMethod()
```

### 7.3 Длинный путь
DI-контейнер + constructor injection для каждой подсистемы. Самый чистый, но требует рефакторинга 904 файлов.
