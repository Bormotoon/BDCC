# Module System — Architecture Analysis

> Базовый класс: `Modules/Module.gd` — 191 строк
> 22 модуля, 870 .gd файлов суммарно

## 1. Обзор

Модульная система контента. Каждый модуль — автономная единица, регистрирующая свои сущности в `GlobalRegistry`. Модули содержат персонажей, локации, квесты, предметы и игровую логику.

## 2. Полный список модулей

| Модуль | Строк | Категории | Назначение |
|--------|-------|-----------|-----------|
| TaviModule | 468 | scenes, characters, events, quests, worldEdits, computers | Маршрут Tavi + система коррупции |
| HypnokinkModule | 176 | attacks, computers, scenes, characters, items, events, quests, skills, perks, fetishes, sexGoals, stageScenes, speechModifiers, statusEffects | Гипноз-система |
| DrugDenModule | 109 | scenes, characters, events, quests | Рогалик-данжон |
| NpcSlaveryModule | 174 | scenes, events | NPC рабство (business logic) |
| CellblockModule | 61 | scenes, characters, events | Блок камер |
| ArticaModule | ~400 | scenes, characters, items, quests | Маршрут Artica |
| AlexRynardModule | ~350 | scenes, characters, items, quests | Маршрут Alex |
| JackiModule | ~300 | scenes, characters, items, quests | Маршрут Jacki |
| SocketModule | ~250 | scenes, characters, items, quests | Маршрут Socket |
| KaitModule | ~200 | scenes, characters, items, quests | Маршрут Kait |
| NovaModule | ~150 | scenes, characters, items | Маршрут Nova |
| RahiModule | ~300 | scenes, characters, items, quests | Маршрут Rahi |
| FightClubModule | ~100 | scenes, events | Бойцовский клуб |
| GymModule | ~80 | scenes, events | Спортзал |
| MedicalModule | ~100 | scenes, events | Медицинское крыло |
| PunishmentsModule | ~80 | scenes, events | Система наказаний |
| PortalPantiesModule | ~120 | scenes, characters, items | Портальные трусики |
| SlaveAuctionModule | ~200 | scenes, characters, events | Торги рабами |
| PlayerSlaveryModule | ~150 | scenes, events | Рабство игрока |
| ElizaModule | ~200 | scenes, characters, items | Маршрут Eliza |
| AcePregExpac | ~100 | scenes, events | Расширение беременности |
| SongJoHairsModule | ~30 | characters | Причёски |

## 3. Как модуль объявляет контент

Каждый модуль переопределяет `Module.gd` внутри своей папки. Устанавливает `id` и `author` в `_init()`, затем заполняет типизированные массивы (scenes, characters, items, events, quests, attacks и т.д.) путями к скриптам:

```gdscript
# DrugDenModule (109 строк)
func _init():
    id = "DrugDenModule"
    author = "Rahi"
    scenes = ["res://Modules/DrugDenModule/DrugDen/DrugDenStartScene.gd", ...]
    characters = ["res://Modules/DrugDenModule/DrugDen/DrugDenStash.gd", ...]
    events = ["res://Modules/DrugDenModule/DrugDen/DrugDenStartEvent.gd", ...]
    quests = ["res://Modules/DrugDenModule/Kidlat/KidlatQuest.gd"]
```

Базовый класс определяет **30+ категорий массивов** — от `scenes` и `characters` до `slaveBreakTasks` и `sexReactionHandlers`.

## 4. Жизненный цикл

### 4.1 Загрузка

```
1. preinitModulesHooks — сканирует PreInit.gd
2. preinitModulesFolder — сканирует Module.gd, создаёт экземпляр
3. registerModules — итерирует модули, вызывает module.register()
4. postInitModules — вызывает module.postInit()
```

### 4.2 Ежедневный сброс

```gdscript
Flags.resetFlagsOnNewDay() → module.resetFlagsOnNewDay()
```

### 4.3 Выгрузка

Нет явной выгрузки — модули загружаются однократно и живут всю сессию.

## 5. Межмодульные зависимости

Зависимости **неявные** (runtime flag reads), не объявленные:

```gdscript
# AlexRynardModule читает флаг CellblockModule
GM.main.getModuleFlag("CellblockModule", "Cellblock_GreenhouseLooted")

# PunishmentsModule читает флаги RahiModule и TaviModule
GM.main.getModuleFlag("RahiModule", "Rahi_Introduced")
GM.main.getModuleFlag("TaviModule", "Tavi_IntroducedTo")
```

**Нет графа зависимостей** и порядка загрузки — модули загружаются по алфавиту.

## 6. Module-scoped флаги

Модули объявляют флаги через `getFlags()`:

```gdscript
# TaviModule
"Tavi_IntroducedTo": flag(FlagType.Bool)

# Доступ из любого места:
GM.main.getModuleFlag("TaviModule", "Tavi_IntroducedTo")
GM.main.setModuleFlag("TaviModule", "Tavi_IntroducedTo", true)

# Shorthand изнутри модуля:
getFlag("Tavi_IntroducedTo")  # автоматически scoped через "ModuleId.FlagName"
```

Внутренне `MainScene.getFlag()` разделяет по `.` для маршрутизации в `getModuleFlag()`.

## 7. Паттерн регистрации

Базовый `register()` — batch loop: для каждой категории массива итерирует и вызывает `GlobalRegistry.registerXxx()`:

```gdscript
func register():
    for scene in scenes:
        GlobalRegistry.registerScene(scene)
    for character in characters:
        GlobalRegistry.registerCharacter(character)
    for item in items:
        GlobalRegistry.registerItem(item)
    # ... 30+ категорий
```

Модули регистрируют **30 типов сущностей** декларативно через массивы. Нет ручных вызовов регистрации в подклассах.

## 8. Сильные стороны

1. **Чистая автономность** — каждый модуль самодостаточен
2. **Декларативная регистрация** — заполняешь массивы, модуль сам регистрирует
3. **Module-scoped флаги** — нет коллизий имён между модулями
4. **Простота добавления нового контента** — создай папку, заполни Module.gd

## 9. Слабые стороны

1. **Неявные зависимости** — нет объявления межмодульных связей
2. **Нет порядка загрузки** — только алфавитный
3. **Нет выгрузки** — модули нельзя отключить во время игры
4. **30+ массивов** в базовом классе — SRP для Module.gd
5. **Нет валидации** — опечатка в пути к скрипту = silent fail

## 10. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Добавить declare dependencies в Module.gd |
| **Высокий** | Добавить валидацию путей при регистрации |
| **Средний** | Поддержать hot-unload модулей |
| **Низкий** | Ограничить количество категорий в базовом классе |
