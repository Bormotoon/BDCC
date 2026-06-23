# SexEngine — Architecture Analysis

> Директория: `Game/SexEngine/` — 152 .gd файла, 32,219 строк суммарно

## 1. Обзор

Самая сложная подсистема игры. Реализует процедурный секс-движок с дом/sub ролями, AI-принятием решений, динамическими joiner'ами (тройнички), системой фетишей, чувствительностью и анимациями.

## 2. Ключевые файлы

| Файл | Строк | Назначение |
|------|-------|-----------|
| `SexEngine.gd` | 1,854 | Главный оркестратор |
| `SexActivityBase.gd` | ~800 | Базовый класс активностей |
| `SexDomInfo.gd` | ~300 | AI цели доминанта |
| `SexSubInfo.gd` | ~250 | Состояние подчинённого |
| `SexGoal.gd` / `SexGoalBase.gd` | ~400 | Система целей |
| `SexType.gd` / `SexTypeBase.gd` | ~300 | Типы секса |
| `FetishHolder.gd` | ~200 | Фетиши |
| `FetishBase.gd` | ~150 | Базовый фетиш |
| `SexReactionHandler.gd` | ~200 | Реакции |
| `SexEvent/` | ~500 | Sex events |

## 3. Архитектура — Goal-Directed Activity Pattern

### 3.1 Основной цикл

```gdscript
# SexEngine.gd:630-663
func processTurn():
    removeEndedActivities()
    for domID in doms:
        domInfo.getChar().processSexTurnContex({sexEngine=self,isDom=true})
        domInfo.processTurn()           # AI决策
    for subID in subs:
        subInfo.getChar().processSexTurnContex({sexEngine=self,isDom=false})
        subInfo.processTurn()           # AI决策
    for activity in activities:
        activity.processTurnFinal()     # Выполнение активности
    checkExtra()
    checkIfDomsNeedMoreGoals()
    removeEndedActivities()
```

`doFullTurn()` цепляет: AI dom actions → process turn → AI sub actions → dynamic joiner check.

### 3.2 Конечный автомат активностей

Каждая активность использует **строковый префикс состояния** для диспатча методов:

```gdscript
# SexActivityBase.gd:1200-1203
func processTurnFinal():
    if(has_method(getStatePrefix()+"_processTurn")):
        call(getStatePrefix()+"_processTurn")
    processTurn()
```

Пример из `DomOralSexOnSub`: состояния `"blowjob"`, `"lickingcock"`, `"licking"`, `"grinding"` — каждое имеет свой `_processTurn` и `_getActions`.

**Проблема**: Добавление состояния требует написания нескольких prefixed-методов и ручного управления `setState()` переходами, разбросанными по action handlers.

## 4. Система целей

### 4.1 Генерация целей

Цели генерируются на основе фетишей. `generateGoalsFor()` запрашивает `FetishHolder.getGoals()` для совместимых целей sub:

```gdscript
# SexEngine.gd:338-395
var goalsToAdd = dom.getFetishHolder().getGoals(self, sub, _minFetishValue)
for goal in goalsToAdd:
    if(sexGoal.isPossible(...) && !sexGoal.isCompleted(...)):
        possibleGoals.append(goalObject)
# Breeding goals получают гарантированные слоты
if(breedingGoalsAmount > 0):
    for _i in range(0, breedingGoalsAmount):
        personDomInfo.goals.append(breedingGoals[i])
```

### 4.2 Sub-goals

Цели содержат sub-goals (например, `SubUndressSub`, `SubOptionalCondomOnSub`), которые активности проверяют перед выполнением.

### 4.3 Fallback

При `_minFetishValue = -0.26` доминанты всегда имеют **что-то** для выполнения.

## 5. Динамические joiner'ы (тройнички)

NPC-доминанты присоединяются из ближайних pawns. Шанс зависит от personality, affection и anger:

```gdscript
# SexEngine.gd:1618-1643
func getChanceForDynamicJoiner(_charID:String) -> float:
    result += theMean*20.0 + theDom*30.0
    for subID in subs:
        affection = GM.main.RS.getAffection(subID, _charID)
        if(affection > 0.80): return 0.0  # лучшие друзья не присоединяются
        result -= affection * 50.0
```

Joiner'ы автоматически уходят после выполнения целей. `participatedDoms` предотвращает повторное присоединение.

## 6. Выбор анимации

`getBestAnimation()` находит анимацию с максимальным приоритетом для текущей цели PC, проверяя согласие всех участников:

```gdscript
# SexEngine.gd:1394-1408
for activity in activities:
    for theOtherInfo in activity.subs:
        if(activity != getActivityWithMaxAnimPriorityFor(theOtherInfo.getCharID())):
            canUseThis = false
```

Fallback: `sexType.getDefaultAnimation()` (обычно `SexStart`).

## 7. Система чувствительности

Зоны — это `SensitiveZone` объекты на частях тела. `stimulateArousalZone()` применяет модификаторы с diminishing returns:

```gdscript
# SexInfoBase.gd:183-215
func stimulateArousalZone(howmuch, bodypartSlot, stimulation):
    sensitiveZone.stimulate(stimulation)
    howMuchActually = sensitiveZone.getArousalGainModifier()
    howMuchActually *= max((1.0 - min(theArousal, 0.5)*0.1 - theArousal*0.25), 0.01)
    addArousalSex(howmuch * howMuchActually)
```

Overstimulation (`isZoneOverstimulated`) halves stimulation. Denial mechanics отслеживает `turnsLastStim` и запускает frustration через `onDenyTick()`.

## 8. Интеграция с секс-игрушками

Минимальная на уровне движка — `SexToyManager.sendTrigger()` вызывается при событиях:

```gdscript
# SexSubInfo.gd:109-110
if(isCon && charID == "pc" && getConsciousness() <= 0.0):
    SexToyManager.sendTrigger(SexToyTrigger.OnLoseConsciousness)
```

## 9. Сильные стороны

1. **Goal-driven AI элегантен** — активности оцениваются по совпадению с целями, поведение NPC эмергентное
2. **Фетиш-система глубоко интегрирована** — каждый тип стимуляции обратно связан с ростом персонажа
3. **Tag-based conflict resolution** (`SexActivityTag`) предотвращает невозможные состояния
4. **Комprehensive save/load** на каждом уровне

## 10. Слабые стороны

1. **God Object**: `SexEngine.gd` (1,854 строк) — AI, анимации, joiner'ы, вывод, предметы, управление сценами
2. **String-based state machine** через `has_method()` — опечатка в имени состояния = silent fail
3. **Дублирование кода** в `SexActivityBase.gd` — методы стимуляции (`stimulateLick`, `stimulateSex`, `stimulateSexRide`, ...) повторяют fetish-affect, overstimulation, restraint, unconscious checks
4. **PC target management** (`getPCTarget`/`switchPCTarget`/`reconsiderPCTarget`) запутано связано с движком
5. **Magic numbers** повсюду (0.26, 0.80, 0.5, 1000) — нет именованных констант

## 11. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Заменить строковый state machine на enum-based |
| **Высокий** | Вынести `SexEngine.gd` AI logic в `SexAI` |
| **Высокий** | Устранить дублирование в stimulation методах |
| **Средний** | Добавить именованные константы для magic numbers |
| **Средний** | Вынести PC target management |
| **Низкий** | Добавить typed state transitions вместо `has_method()` |
