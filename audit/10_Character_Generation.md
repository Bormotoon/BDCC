# Character Generation, Pregnancy & Transformation — Analysis

> `Characters/Dynamic/` — 51 .gd файл
> `Game/Pregnancy/` — 15 .gd файл
> `Game/Transformation/` — 8 .gd файл

## 1. Dynamic NPC Generation

### 1.1 Template Method Pattern

`CharacterGeneratorBase.gd` реализует классический **Template Method**:

```gdscript
func generate(_args = {}):
    var character = makeBase("dynamicnpc", _args)
    pickCharacterType(character, _args)
    pickGender(character, _args)
    pickBodyAttributes(character, _args)  # Зависит от gender
    pickName(character, _args)            # Зависит от gender
    pickSpecies(character, _args)         # Зависит от character type
    # ... ещё ~10 шагов с объявленными зависимостями
```

Каждый `pick*` использует weighted RNG (`RNG.pickWeightedPairs`) с encounter-settings фильтрами — настройки игрока влияют на генерацию NPC.

### 1.2 Генераторы

| Генератор | Назначение |
|-----------|-----------|
| `InmateGenerator` | Заключённые (переопределяет type, equipment, attacks) |
| `GuardGenerator` | Охрана |
| `NurseGenerator` | Медсёстры |
| `EngineerGenerator` | Инженеры |
| `NakedSlaveGenerator` | Голые рабы |
| `DrugDenJunkieGenerator` | Наркоманы данжона |

### 1.3 NpcGen — keyword argument system

```gdscript
# Ограничение генерации по параметрам
NpcGen.Gender, NpcGen.Species, NpcGen.Type
```

### 1.4 CharacterPool

Статический реестр pool IDs: Guards, Nurses, Inmates, Engineers, Slaves, MentalWard.

## 2. Pregnancy System

### 2.1 MenstrualCycle — ядро системы

Моделирует непрерывный 0.0-1.0 цикл с 4 стадиями:

| Стадия | Описание |
|--------|----------|
| Menstruation | Менструация |
| Follicular | Фолликулярная фаза |
| Ovulation | Овуляция — создаёт `EggCell` объекты |
| Luteal | Лютеиновая фаза |

### 2.2 Оплодотворение

```gdscript
func obsorbCum():
    # Выбирает случайное яйцо из целевого отверстия
    # Проверяет: fertility × virility × cross-species-compatibility × egg-count-multiplier
    # Бросает RNG.chance(finalChance)
```

### 2.3 Гестация

Отслеживается per-egg как float 0.0-1.0. Прогресс через `processTime(seconds * pregnancySpeed)`. При progress >= 1.0: `fetusReadyForBirth = true`.

### 2.4 Monozygotic splitting

9% шанс близнецов, резко убывающий до шестерняшек.

### 2.5 Big eggs (параллельный трек)

Tentacle/plant/latex яйца — отдельный жизненный цикл с яйцекладкой. `EggLaid` — промежуточный item-representation.

## 3. Transformation System

### 3.1 Layered Effect Composition

`TFHolder.gd` управляет **nested composition**:

- Каждая трансформация создаёт `TFEffect` (char-level или bodypart-level)
- Эффекты накапливаются в плоском массиве и **пересчитываются с нуля** при каждом `applyEffects()` — оригинальные данные снимают snapshot один раз, затем все эффекты применяются последовательно

### 3.2 Conflict Resolution

```gdscript
func canReplace():
    # Проверяет: id + tfID + slot
func optimizeEffects():
    # Дедупликация
```

### 3.3 Reversal

```gdscript
func undoTransformation():
    # Удаляет все эффекты для данного TF uniqueID
    # Пересчитывает оставшиеся

func makeAllTransformationsPermanent():
    # Очищает оригинальные снимки
```

### 3.4 Tag-based Exclusions

```gdscript
func canStartTransformation():
    # Проверяет перекрытие тегов между активными и кандидатными TF
    # Кроме случаев canTFStack() == true
```

Это effectively **command pattern с полным replay** — дорого, но гарантирует корректность.

## 4. Fetish Evolution

### 4.1 Dynamic Personality Coupling

```gdscript
func getFetishChangePersonalityMod(_personality:Personality) -> float:
    for personalityStat in dynamicChangesPersonalityAffectors:
        result += thePersWantValue * thePersValue
    return max(result, 0.5)
```

### 4.2 Пороги

- `getDynamicChangeThreshold()` (по умолчанию 5.0) — сколько секс-активности для сдвига фетиша
- Forced obedience перезаписывает fetish-based scoring в `scoreFetish()`

## 5. Notable Patterns

### 5.1 Serialization everywhere
Каждая система имеет hand-written `saveData()`/`loadData()` с defensive `SAVE.loadVar` defaults.

### 5.2 WeakRef references
`TFHolder`, `MenstrualCycle`, `FetishHolder` используют weakrefs для избежания circular ownership.

### 5.3 Species-driven behavior
Species объекты подключаются к генерации (`onDynamicNpcCreation`), количеству овуляции, типам яиц и cross-species compatibility — чистая extension point.

### 5.4 Option-driven pacing
Длительность беременности, длина цикла, время жизни яиц — всё настраивается через `OPTIONS`.

## 6. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Стандартизировать save/load — единый интерфейс Serializable |
| **Средний** | Кэшировать replay в TFHolder (пересчёт каждый кадр дорого) |
| **Средний** | Добавить валидацию тегов при старте TF |
| **Низкий** | Вынести cross-species compatibility в отдельный реестр |
