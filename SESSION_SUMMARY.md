# Session Summary: Миграция BDCC на Godot 4.x

## Goal

Миграция репозитория BDCC (Broken Dreams Correctional Center) — текстовый RPG с Godot 3.x — на Godot 4.x с полным рефактором архитектуры. Включает:
1. Создание нового фундамента (EventBus, ServiceLocator, ECS)
2. Перенос реальной игровой логики из 3000+ файлов старого кода
3. Исправление всех каскадных ошибок Godot 3→4
4. Установка Godot 4.4.1 и MCP инструментов

## Instructions

- Строго следовать инструкциям в файлах Phase 0.md — Phase 5.md
- После каждого изменения — подробный коммит
- Миграция должна быть **реальной** (1:1 перенос формул), не каркасом
- После миграции — проверка запуска через `godot --headless`
- Исправление всех каскадных ошибок начиная с autoload скриптов

## Discoveries

- **Каскадные ошибки**: Godot 4 загружает скрипты по порядку зависимостей. Один сломанный autoload ломает все зависящие скрипты
- **Log/Util/ContentType** не найдены из-за каскада — их скрипты не загружаются потому что依赖ные скрипты не компилируются
- **GlobalRegistry.gd** — главный источник ошибок (221 ошибка), содержит 110 обращений к Log
- **File.new()** → **FileAccess.open()** (не просто FileAccess!)
- **Directory.new()** → **DirAccess.open()** (нужен путь, не пустая строка)
- **sort_custom(self, "method")** → **sort_custom(Callable(self, "method"))**
- **OS.get_ticks_usec** → **Time.get_ticks_usec** (отдельный singleton)
- **Color.red** → **Color.RED** (заглавные буквы)
- **.shader** → **.gdshader** (расширение файлов)
- **get_stylebox()** → **get_theme_stylebox()**
- **.filename** → **.scene_file_path**
- **.invert()** → **.reverse()**
- **OS.get_name() == "HTML5"** → **OS.get_name() == "Web"**
- **set_screen_stretch()** удалён из SceneTree в Godot 4
- **VIDEO_DRIVER_GLES2** удалён в Godot 4
- **396 ошибок** → **349 ошибок** после исправлений (остаток — каскад от autoload'ов)
- **Context7 MCP** установлен через npm, но требует перезапуска сессии для использования
- **Godot MCP** установлен как addon в проекте (`addons/godot_mcp/`)

## Accomplished

### Фаза 0: Фундамент ✅
- EventBus.gd (80+ сигналов), ServiceLocator.gd, RegistryManager.gd
- Component.gd, Entity.gd, HealthComponent.gd (321 строк с реальными формулами)

### Фаза 1: Doll3D 2.0 ✅
- DeformModifier3D, JiggleModifier3D (SkeletonModifier3D)
- DollPartManager, Doll3D.gd (479 строк с ВСЕМИ state mappings)

### Фаза 2: C# Simulation ✅
- NpcData.cs, SimulationEngine.cs (Parallel.For), RoomGraph.gd
- SimulationBridge.gd (428 строк с time-slicing, pawn needs)

### Фаза 3: SexEngine ✅
- SexEngineManager (280 строк), SexState, SexAction
- IdleState, ActivityState, ThrustAction, SpankAction, KissAction

### Фаза 4: CrotchCode 2.0 ✅
- CrotchScriptBase, CrotchTranspiler (280 строк, все типы блоков)
- CrotchCompiler, CrotchGraphEditor

### Фаза 5: Контент и DevOps ✅
- QuestData, DialogueData, ContentMigrator, AiPromptGenerator
- CI/CD (gdformat.yml)

### Реальная миграция логики ✅
- **HealthComponent**: 321 строк — все формулы боя, armor 50/(50+armor), defocus perk
- **Doll3D**: 479 строк — ВСЕ state mappings, chains, particles
- **SimulationBridge**: 428 строк — time-slicing, pawn needs, affection scoring
- **SexEngineManager**: 280 строк — goal generation, activity processing
- **BaseCharacter**: 800 строк — migrated with all formulas preserved
- **MainScene**: 500 строк — save/load, flags, time management

### Godot 3→4 синтаксис ✅ (3,215 файлов)
- `extends Reference` → `extends RefCounted`
- `.empty()` → `.is_empty()`
- `.instance()` → `.instantiate()`
- `.remove()` → `.remove_at()`
- `onready` → `@onready` (1,117 occurrences)
- `export()` → `@export` (71 occurrences)
- `yield()` → `await` (101 occurrences)
- `connect("signal", self, "method")` → `signal.connect(method)` (227 occurrences)
- `emit_signal()` → `signal.emit()` (229 occurrences)
- `margin_*` → `offset_*` (185 файлов)
- `Color.red` → `Color.RED` (100 файлов)
- `File.new()` → `FileAccess.open()` (21 файлов)
- `Directory.new()` → `DirAccess` (11 файлов)
- `JSON.parse()` → `JSON.parse_string()` (18 файлов)
- `.shader` → `.gdshader` (5 файлов)

### Установка инструментов ✅
- Godot 4.4.1 в `~/.local/bin/godot`
- Context7 MCP в `config.toml`
- Godot MCP addon в проекте

### Осталось (349 ошибок запуска)
- Каскадные ошибки от autoload скриптов (Log, Util, ContentType не загружаются)
- GlobalRegistry.gd: 110 обращений к Log (не найден)
- modsFolder scope issue в GlobalRegistry.gd
- Остальные P1/P2/P3 файлы (~3,140 файлов, ~196,000 строк)

## Relevant files / directories

### Созданные файлы (новая архитектура)
- `/home/borm/VibeCoding/BDCC/Autoloads/EventBus.gd`
- `/home/borm/VibeCoding/BDCC/Core/ServiceLocator.gd`
- `/home/borm/VibeCoding/BDCC/Core/RegistryManager.gd`
- `/home/borm/VibeCoding/BDCC/Components/Component.gd`
- `/home/borm/VibeCoding/BDCC/Components/Entity.gd`
- `/home/borm/VibeCoding/BDCC/Components/HealthComponent.gd`
- `/home/borm/VibeCoding/BDCC/Components/DollPartManager.gd`
- `/home/borm/VibeCoding/BDCC/Components/PawnComponent.gd`
- `/home/borm/VibeCoding/BDCC/Components/SexReactionComponent.gd`
- `/home/borm/VibeCoding/BDCC/Visuals/Doll3D.gd`
- `/home/borm/VibeCoding/BDCC/Visuals/SkeletonModifiers/DeformModifier3D.gd`
- `/home/borm/VibeCoding/BDCC/Visuals/SkeletonModifiers/JiggleModifier3D.gd`
- `/home/borm/VibeCoding/BDCC/Simulation/SimulationBridge.gd`
- `/home/borm/VibeCoding/BDCC/Simulation/SimulationEngine.cs`
- `/home/borm/VibeCoding/BDCC/Simulation/NpcData.cs`
- `/home/borm/VibeCoding/BDCC/Simulation/RoomGraph.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/SexEngineManager.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/SexState.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/SexAction.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/States/IdleState.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/States/ActivityState.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/Actions/ThrustAction.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/Actions/SpankAction.gd`
- `/home/borm/VibeCoding/BDCC/Systems/SexEngine/Actions/KissAction.gd`
- `/home/borm/VibeCoding/BDCC/Systems/CrotchCode/CrotchScriptBase.gd`
- `/home/borm/VibeCoding/BDCC/Systems/CrotchCode/CrotchTranspiler.gd`
- `/home/borm/VibeCoding/BDCC/Systems/CrotchCode/CrotchCompiler.gd`
- `/home/borm/VibeCoding/BDCC/Systems/CrotchCode/CrotchGraphEditor.gd`
- `/home/borm/VibeCoding/BDCC/Resources/ItemData.gd`
- `/home/borm/VibeCoding/BDCC/Resources/QuestData.gd`
- `/home/borm/VibeCoding/BDCC/Resources/DialogueData.gd`
- `/home/borm/VibeCoding/BDCC/Tools/ContentMigrator.gd`
- `/home/borm/VibeCoding/BDCC/Tools/AiPromptGenerator.gd`

### Мигрированные файлы (реальная логика)
- `/home/borm/VibeCoding/BDCC/Game/BaseCharacter.gd` (800 строк, все формулы)
- `/home/borm/VibeCoding/BDCC/Game/MainScene.gd` (500 строк, save/load/flags)
- `/home/borm/VibeCoding/BDCC/Game/GM.gd` (58 строк, ServiceLocator registration)
- `/home/borm/VibeCoding/BDCC/Game/Options/GlobalOptions.gd` (600 строк)
- `/home/borm/VibeCoding/BDCC/Game/Options/ContentType.gd` (unchanged)
- `/home/borm/VibeCoding/BDCC/Game/World/World.gd` (300 строк)
- `/home/borm/VibeCoding/BDCC/Scenes/SceneBase.gd` (300 строк)
- `/home/borm/VibeCoding/BDCC/Util/Util.gd` (250 строк)
- `/home/borm/VibeCoding/BDCC/Util/RNG.gd` (120 строк)
- `/home/borm/VibeCoding/BDCC/Util/GameParser.gd` (100 строк)
- `/home/borm/VibeCoding/BDCC/Util/SayParser.gd` (180 строк)

### Конфигурация
- `/home/borm/VibeCoding/BDCC/project.godot` (config_version=5, autoloads добавлены)
- `/home/borm/.codex/config.toml` (MCP servers: context7, godot-mcp)
- `/home/borm/VibeCoding/BDCC/addons/godot_mcp/` (Godot MCP addon)

### Документация
- `/home/borm/VibeCoding/BDCC/TECHNICAL_AUDIT.md`
- `/home/borm/VibeCoding/BDCC/audit/` (14 отчётов по системам)
- `/home/borm/VibeCoding/BDCC/MIGRATION_CHECKLIST.md`
- `/home/borm/VibeCoding/BDCC/Phase 0.md` — `Phase 5.md` (инструкции)

### Ключевые старые файлы (требуют миграции P1-P2)
- `/home/borm/VibeCoding/BDCC/Game/SexEngine/` (152 файла, 32,219 строк)
- `/home/borm/VibeCoding/BDCC/Game/InteractionSystem/` (69 файлов, 11,401 строка)
- `/home/borm/VibeCoding/BDCC/Game/NpcSlavery/` (113 файлов, 11,949 строк)
- `/home/borm/VibeCoding/BDCC/Modules/` (870 файлов, 30,000+ строк)
- `/home/borm/VibeCoding/BDCC/Game/ModularDialogue/` (24 файла, 14,037 строк)
- `/home/borm/VibeCoding/BDCC/Player/` (449 файлов, 24,715 строк)
- `/home/borm/VibeCoding/BDCC/Inventory/` (263 файла, 8,900 строк)
