# Testing Infrastructure & Code Quality — Analysis

## 1. Тестовый фреймворк: Отсутствует

**Нет тестового фреймворка.** 197 совпадений `assert`/`expect`/`test_` — это几乎 entirely:
- **Narrative content** (диалоги со словом "expect")
- **Runtime assertions** (91 вызов `assert()` как invariants, не тестовых assertion'ов)
- Нет GdUnit, Gut, WAT или любого другого тестового фреймворка

## 2. "Test" файлы: Все ручные/in-game

| Файл | Реальное назначение |
|------|-------------------|
| `SpellCheckerTest.gd` | Ручной UI инструмент для проверки орфографии через Reverso API |
| `SimpleStringInterpolatorTester.gd` | Ручной UI tester с кнопкой |
| `TestQuest.gd`, `TestCharacter.gd`, `TestFloor.gd`, `TestBuff.gd` | In-game placeholder/demo контент |
| `EmptyTest.gd`, `TestEvent.gd` | In-game контент |
| `ElizaDrugTest*Scene.gd` | Нарративные сцены о тестировании наркотиков |

**Нет ни одного автоматизированного теста.**

## 3. CI/CD: Только build

`.github/workflows/godot-ci.yml` — единственный workflow:

- Собирает экспорты для Windows, Linux, Web, Mac (Godot 3.6.2)
- Запускает каждый push
- Загружает артефакты
- Опционально уведомляет Discord

**Нет тестов, нет lint, нет code-quality gates.**

## 4. Профайлер: Минимальный

| Файл | Строк | Назначение |
|------|-------|-----------|
| `MyProfilerBase.gd` | 8 | Абстрактный base с пустыми `start()`/`finish()` |
| `MyProfiler.gd` | 33 | Stack-based micro-timer, логирует при опустошении стека |

Используется ad-hoc, не интегрирован в CI или тестовый harness.

## 5. TODO/FIXME/HACK/XXX: 7 штук (очень мало)

| Маркер | Кол-во | Файлы |
|--------|--------|-------|
| TODO | 3 | FetishHolder.gd, PlayerSlaveryHolder.gd, BaseCharacter.gd |
| FIXME | 3 | CurveEditor.gd (все 3) |
| XXX | 1 | Ch1s3Datapad.gd (нарратив, не код) |
| HACK | 0 | — |

**Впечатляюще мало** для 3,184 .gd файлов — либо дисциплинированная очистка, либо недокомментирование.

## 6. Линтеры: Отсутствуют

Нет `.gdlintrc`, нет конфигурации линтинга, нет статических анализаторов. Единственные конфиг-файлы — `export_presets.cfg` и два `plugin.cfg` addon'ов.

## 7. Игнорируемые ошибки

GDScript не имеет try/catch. Проект использует **91 `assert()` вызов** для runtime валидации (null-checks, size-checks, bad-state guards). Пустых error-обработчиков не найдено. **430 присваиваний `var _`** — намеренно отброшенные возвращаемые значения (GDScript convention).

## 8. Документация

| Файл | Назначение |
|------|-----------|
| `README.md` | Readme проекта |
| `CHANGELOG.md` | Release notes |
| `TECHNICAL_AUDIT.md` | Технический аудит (создан в рамках этого анализа) |
| `addons/godot-notes/README.md` | Документация addons |

**Нет API-документации**, нет dev guides, нет architecture diagrams.

## 9. Масштаб проблемы

| Метрика | Значение |
|---------|----------|
| Файлов .gd | 3,184 |
| Зарегистрированных классов | 389 |
| Автоматизированных тестов | **0** |
| Coverage | **0%** |
| CI quality gates | **Нет** |
| Линтеров | **Нет** |
| Статических анализаторов | **Нет** |

## 10. Рекомендации

### 10.1 P0: Внедрить тесты

| Приоритет | Действие |
|---|---|
| **P0** | Установить GdUnit или Gut |
| **P0** | Написать unit-тесты для GlobalRegistry (register/get/create) |
| **P0** | Написать unit-тесты для BaseCharacter (core stats, fluids) |
| **P0** | Написать unit-тесты для Datapack (load/save) |
| **P0** | Написать unit-тесты для CodeContex (CrotchCode execution) |

### 10.2 P1: CI/CD

| Приоритет | Действие |
|---|---|
| **P1** | Добавить тесты в CI pipeline |
| **P1** | Добавить GDScript линтер (gdtoolkit) |
| **P1** | Добавить type checking |

### 10.3 P2: Документация

| Приоритет | Действие |
|---|---|
| **P2** | Добавить ARCHITECTURE.md |
| **P2** | Добавить CONTRIBUTING.md |
| **P2** | Добавить API docs для ключевых систем |

## 11. Вывод

Проект имеет **нуль автоматизации качества**. Качество поддерживается только ручным ревью и дисциплиной автора. Для 3,184 файлов и 389 классов это критический риск. 7 TODO/FIXME маркеровuggest дисциплинированность, но отсутствие тестов —最大的 технический долг проекта.
