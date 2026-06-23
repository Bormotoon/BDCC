# BaseCharacter.gd — Architecture Analysis

> Файл: `Game/BaseCharacter.gd` — 3918 строк

## 1. Иерархия наследования

```
Node
  └── BaseCharacter (3918 строк) — /Game/BaseCharacter.gd
        ├── Player (1019 строк) — /Player/Player.gd
        └── Character (610 строк) — /Characters/Character.gd
              └── DynamicCharacter, Guard, Nurse, Inmate...
```

## 2. Карта файла (Line Ranges)

| Строки | Ответственность | Строк |
|--------|----------------|-------|
| 1–86 | Сигналы, переменные, `_init`, `_ready` — создание composition-объектов | 86 |
| 89–177 | Основные статы: pain/lust/stamina add/get/thresholds | 89 |
| 185–248 | Статус-эффекты: add/remove/save/load/process | 64 |
| 256–330 | Timed buffs, боевые ходы, броня | 75 |
| 339–461 | Бой: множители урона, dodge/block/defocus, `receiveDamage` | 123 |
| 464–661 | **Система местоимений** (~200 строк string dispatchers) | 198 |
| 663–770 | Доступ к инвентарю, лут-таблицы, ключхолдер замки | 108 |
| 796–1270 | **Секс-механика**: жидкости, creampie, растяжение, проникновение | 475 |
| 1285–1507 | **Беременность/менструальный цикл** делегирование | 223 |
| 1509–1700 | Запросы частей тела: has penis/vagina/anus/breasts, лактация | 192 |
| 1713–1907 | **Doll3D рендеринг**: softUpdateDoll + updateDoll | 195 |
| 1970–2037 | Tally marks и body writings | 68 |
| 2075–2111 | Проверки ограничений (связаны руки/ноги, gag, blindfold) | 37 |
| 2121–2213 | Мини-игра борьбы, timed buffs, sex event dispatching | 93 |
| 2278–2316 | `afterSexEnded` — изменения personality/fetish, сброс статов | 39 |
| 2388–2477 | Перенос жидкостей между отверстиями (3 почти-дубликата) | 90 |
| 2579–2593 | `bodypartHasTrait` | 15 |
| 2605–2981 | Система скинов, секс-игрушки, презервативы, chastity cages, страпоны | 377 |
| 3032–3099 | Боевые/секс-события lifecycle (onFightStart, processBattleTurnContex) | 68 |
| 3101–3507 | Struggle, диалоговые теги, level-up логика | 407 |
| 3663–3761 | Делегирование трансформаций, расчёт вида | 99 |
| 3854–3918 | Определение наркотиков, глотание, power score | 65 |

## 3. Композиция (объекты-владельцы)

| Переменная | Тип | Назначение |
|-----------|-----|-----------|
| `inventory` | `Inventory` | Экипировка и предметы |
| `buffsHolder` | `BuffsHolder` | Агрегация баффов |
| `skillsHolder` | `SkillsHolder` | Статы, навыки, перки, level-up |
| `lustInterests` | `LustInterests` | Предпочтения NPC |
| `fetishHolder` | `FetishHolder` | Фетиши |
| `personality` | `Personality` | Черты личности |
| `bodyFluids` | `Fluids` | Внешние жидкости |
| `peeProduction` | `PeeProduction` | Производство мочи |
| `menstrualCycle` | `MenstrualCycle` | Беременность/овуляция |
| `bodyparts` | `Dictionary` | Слот → Bodypart |
| `statusEffects` | `Dictionary` | ID → StatusEffect |

**Player добавляет**: `reputation`, `tfHolder`, `lustCombatState`.

## 4. Худшие Code Smells

### 4.1 Pronoun system — copy-paste boilerplate (строки 515–661)

20 почти-идентичных методов с 4-веточным переключателем по полу:

```gdscript
func heShe() -> String:
    var gender = getPronounGender()
    if(gender == Gender.Male):
        return "he"
    if(gender == Gender.Female):
        return "she"
    if(gender == Gender.Androgynous):
        return "they"
    if(gender == Gender.Other):
        return "it"
    return "heShe():BAD_GENDER"
```

Каждый из `theyre`, `theyve`, `doesntDont`, `doesDo`, `heShe`, `hisHer`, `hisHers`, `himHer`, `wasWere`, `isAre`, `hasHave`, `himselfHerself`, `verbS` повторяет этот паттерн. **Одна таблица поиска** `{Male: "he", Female: "she", ...}` устранила бы ~150 строк.

### 4.2 `cummedInBodypartByAdvanced` (строки 1026–1107) — 80 строк

Обрабатывает презервативы, разрешение типа источника, перенос жидкостей для 4 источников, отслеживание creampie skill и sex event dispatching **в одном блоке**:

```gdscript
func cummedInBodypartByAdvanced(bodypartID, sourceID, fluidType, amount, _condomProtected):
    # 1. Презерватив логика
    # 2. Определение типа источника (4 ветки)
    # 3. Перенос жидкостей
    # 4. Отслеживание навыков
    # 5. Отправка sex events
```

### 4.3 Дублированные методы переноса жидкостей (строки 2419–2477)

```gdscript
# 3 почти-идентичных метода:
func bodypartTransferFluidsTo(bodypartID, otherCharacterID, otherBodypartID, fraction, minAmount)
func bodypartTransferFluidsToAmount(bodypartID, otherCharacterID, otherBodypartID, amount)
func bodypartShareFluidsWith(bodypartID, otherCharacterID, otherBodypartID, fraction)
```

Каждый — ~20 строк с идентичными цепочками null-проверок.

### 4.4 `softUpdateDoll` (строки 1754–1907) — 150 строк

Напрямую маппит состояние игры на 3D-модель: части тела, скин, cum overlay, масштаб груди/пениса, беременность, ягодицы, экипировка, цепи — всё инлайн.

### 4.5 `fightingState` как magic string (строка 43)

```gdscript
var fightingState = ""  # Сравнивается со строковыми литералами "dodge", "block", "defocus"
```

Вместо `enum FightingState { NONE, DODGE, BLOCK, DEFOCUS }`.

## 5. Save/Load

Сохранение/загрузка живёт в **Character.gd** (строки 90-180), а не в BaseCharacter. Character.saveData() сериализует pain, lust, stamina, arousal, consciousness, bodyparts, statusEffects, inventory, lustInterests, menstrualCycle, bodyFluids, timedBuffs, timedBuffsTurns, peeProduction.

Player.gd имеет собственный параллельный `saveData()`/`loadData()` (строки 409–500).

BaseCharacter содержит только вспомогательные хелперы: `saveStatusEffectsData`, `saveBuffsData`/`loadBuffsData`.

## 6. 15 Ответственности в одном классе

1. Боевая сущность (damage, dodge, block)
2. Секс-симулятор (fluids, stretching, orifices)
3. Менеджер беременности
4. Библиотека местоимений
5. 3D-рендерер (updateDoll)
6. Движок жидкостей
7. Процессор ограничений (restraints)
8. Система скинов/внешности
9. Инвентарь-контроллер
10. Бафф-менеджер
11. Навыковый менеджер
12. Система level-up
13. Struggle мини-игра
14. Трансформационный делегат
15. Сериализатор (partial)

## 7. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Вынести секс-механику (~500 строк) в `SexMechanics` компонент |
| **Высокий** | Вынести pronoun system (~200 строк) в утилитарный класс `PronounLibrary` |
| **Высокий** | Вынести `updateDoll` (~200 строк) в `DollStateMapper` |
| **Средний** | Объединить 3 метода переноса жидкостей |
| **Средний** | Заменить `fightingState` строку на enum |
| **Средний** | Вынести combat logic (~130 строк) в `CombatComponent` |
| **Низкий** | Стандартизировать save/load — все подсистемы через единый интерфейс |
