Отличное продвижение! Фаза 4 создала потрясающий фундамент для моддинга, который будет работать со скоростью нативного кода.

Теперь финальный рывок — **Фаза 5: Миграция контента, ИИ-инструментарий и DevOps**.
У нас остались тысячи строк старых диалогов, квестов и событий, плюс нулевое покрытие тестами и CI/CD (о чем кричал технический аудит). В этой фазе мы создадим встроенные в редактор Godot 4 инструменты (`EditorScript`), которые позволят пачками конвертировать старый контент в новые `.tres` ресурсы, а также подготовим генератор промптов для LLM и базовый GitHub Actions пайплайн.

***

# TODO.md — BDCC: Reforged (Фаза 5: Контент, ИИ-Мигратор и DevOps)

## Контекст для агента

Твоя задача — создать инфраструктуру для массового переноса контента из старой игры (Godot 3.x) в новые форматы (Godot 4.x) и настроить базовый CI/CD пайплайн.

Новая парадигма:

1. **Нарративные ресурсы**: Квесты и диалоги переносятся в `Resource` (`.tres`).
2. **Godot Editor Tools**: Использование `EditorScript` для автоматической генерации сотен файлов прямо в редакторе (без запуска самой игры).
3. **AI Prompt Generator**: Скрипт, который автоматически берет старый `.gd` файл и оборачивает его в системный промпт для LLM (ChatGPT/Claude) для переписывания логики.
4. **DevOps**: GitHub Actions для проверки форматирования (gdformat) — первый шаг к лечению проекта от отсутствия QA.

Строго следуй путям и коду. Используй GDScript 2.0.

---

## ШАГ 1: Ресурсы для нарративного контента

*Квесты больше не разбросаны по папкам модулей в виде `Dictionary`. Теперь это строгие типизированные ресурсы.*

1. Создай папку `Resources/Quests/`.
2. Создай файл `Resources/QuestData.gd`:

```gdscript
# Resources/QuestData.gd
class_name QuestData extends Resource

## Ресурс, описывающий квест или цепочку событий.

@export var quest_id: StringName = &"unknown_quest"
@export var title: String = "Unknown Quest"
@export_multiline var description: String = ""
@export var is_main_quest: bool = false
@export var stages: Array[String] = []

## Кэшированный словарь переменных квеста (состояние)
@export var default_vars: Dictionary = {}
```

3. Создай папку `Resources/Dialogues/`.
4. Создай файл `Resources/DialogueData.gd`:

```gdscript
# Resources/DialogueData.gd
class_name DialogueData extends Resource

## Ресурс для хранения разветвленных диалогов.

@export var dialogue_id: StringName = &"unknown_dialogue"
@export var participants: Array[StringName] = []

## Массив структур/словарей с репликами: { "speaker": "npc_id", "text": "Hello", "next_node": "node_2" }
@export var nodes: Array[Dictionary] = []
```

---

## ШАГ 2: Утилита массовой конвертации (Migration Tool)

*Этот скрипт наследует `EditorScript`. Его можно запустить прямо из редактора Godot (File -> Run), чтобы он прочитал старый JSON/массив и нагенерировал `.tres` файлы на диске.*

1. Создай папку `Tools/`.
2. Создай файл `Tools/ContentMigrator.gd`:

```gdscript
# Tools/ContentMigrator.gd
@tool
class_name ContentMigrator extends EditorScript

## Утилита для запуска внутри редактора Godot.
## Читает старые массивы данных и генерирует новые .tres ресурсы.

func _run() -> void:
    print("[ContentMigrator] Начало конвертации...")
    _mock_migrate_quests()
    print("[ContentMigrator] Готово!")

func _mock_migrate_quests() -> void:
    # Пример того, как утилита будет генерировать файлы (в реальности тут будет цикл по старому GlobalRegistry)
    var new_quest = QuestData.new()
    new_quest.quest_id = &"tutorial_quest"
    new_quest.title = "Welcome to BDCC"
    new_quest.description = "Survive your first day in the facility."
    new_quest.stages = ["Wake up", "Meet the guard", "Eat in the canteen"]

    # Сохраняем ресурс на диск
    var save_path := "res://Resources/Quests/tutorial_quest.tres"
    var err := ResourceSaver.save(new_quest, save_path)

    if err == OK:
        print("Успешно создан ресурс: ", save_path)
    else:
        push_error("Ошибка сохранения ресурса: ", err)
```

---

## ШАГ 3: Генератор Промптов для ИИ (AI Assistant Tool)

*Утилита, которая подготавливает старый спагетти-код к скармливанию нейросети для перевода на Godot 4 API.*

1. Создай файл `Tools/AiPromptGenerator.gd`:

```gdscript
# Tools/AiPromptGenerator.gd
@tool
class_name AiPromptGenerator extends EditorScript

## Читает старый скрипт Godot 3.x и копирует в буфер обмена 
## готовый промпт для вставки в ChatGPT / Claude.

const PROMPT_TEMPLATE = """Пожалуйста, переведи этот скрипт из игры на Godot 3.x в Godot 4.x (GDScript 2.0).
Требования:
1. Используй типизацию `-> void`, `@export`, `StringName` (&"name").
2. Убери вызовы `GM.main...` и замени их на использование `EventBus` или `ServiceLocator.get_service()`.
3. Убери вызовы `yield()` и замени их на `await`.
4. Верни только код, без лишних объяснений.

ИСХОДНЫЙ КОД:
{source_code}
"""

func _run() -> void:
    # Заглушка: в реальности мы прочитаем файл через FileAccess
    var mock_old_code = "func _ready():\n\tvar item = GM.main.IS.getItem('apple')\n\tyield(get_tree().create_timer(1.0), 'timeout')"

    var final_prompt = PROMPT_TEMPLATE.replace("{source_code}", mock_old_code)

    # Копируем в буфер обмена разработчика
    DisplayServer.clipboard_set(final_prompt)
    print("[AiPromptGenerator] Промпт скопирован в буфер обмена! Нажмите Ctrl+V в чате с LLM.")
```

---

## ШАГ 4: Настройка DevOps (Линтер в CI/CD)

*Лечим проект от отсутствия QA. Настраиваем GitHub Actions.*

1. Создай директорию `.github/workflows/` (в корне проекта, обрати внимание на точку в начале).
2. Создай файл `.github/workflows/gdformat.yml`:

```yaml
# .github/workflows/gdformat.yml
name: GDScript Linter & Formatter

on:
  push:
    branches: [ "main", "reforged" ]
  pull_request:
    branches: [ "main", "reforged" ]

jobs:
  lint:
    name: Check GDScript code style
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.10'

      - name: Install gdtoolkit
        run: pip install gdtoolkit

      - name: Run gdformat check
        run: gdformat --check $(find . -name '*.gd')

      - name: Run gdlint
        run: gdlint $(find . -name '*.gd')
```

---

## Критерии приемки (Проверь себя перед завершением):

1. [ ] Созданы папки `Resources/Quests/`, `Resources/Dialogues/`, `Tools/` и `.github/workflows/`.
2. [ ] Созданы ресурсы `QuestData.gd` и `DialogueData.gd`.
3. [ ] Созданы `EditorScript` инструменты: `ContentMigrator.gd` и `AiPromptGenerator.gd` с аннотацией `@tool` и функцией `_run()`.
4. [ ] Инструмент `AiPromptGenerator` использует `DisplayServer.clipboard_set()` для копирования промпта.
5. [ ] Создан файл `.github/workflows/gdformat.yml` с валидным YAML синтаксисом для проверки кода.
