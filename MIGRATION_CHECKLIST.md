# MIGRATION_CHECKLIST.md — Полный чеклист миграции BDCC на Godot 4

> Дата анализа: 2026-06-23
> Всего .gd файлов: **3,215** | Всего строк: **~200,000+**

---

## Сводная статистика

| Категория | Файлов | Строк | GM.* | Приоритет |
|-----------|--------|-------|------|-----------|
| Game/ ( core ) | ~982 | ~150,743 | 1,200+ | CRITICAL |
| Modules/ | ~870 | ~30,000+ | 4,000+ | CRITICAL |
| Player/ | 449 | ~24,715 | 37 | HIGH |
| Inventory/ | 263 | ~8,900 | 44 | HIGH |
| Characters/ | 50 | ~4,150 | 57 | HIGH |
| Skills/ | 109 | ~2,800 | 9 | MEDIUM |
| Scenes/ | 64 | ~11,485 | varies | HIGH |
| UI/ | 81 | ~7,305 | varies | HIGH |
| Events/ | 15 | ~680 | 56 | MEDIUM |
| Quests/ | 7 | ~190 | 5 | LOW |
| Species/ | 8 | ~516 | 0 | LOW |
| StatusEffect/ | 78 | ~4,300 | 13 | MEDIUM |
| Util/ | 85 | ~10,500 | 17 | MEDIUM |
| Shaders/ | 5 | ~149 | 0 | LOW |
| **ИТОГО** | **~3,215** | **~200,000+** | **5,500+** | — |

---

## ЧАСТЬ 1: Автоматизируемые замены (regex/bulk)

Эти изменения можно применить ко всему репозиторию автоматически:

### 1.1 Reference → RefCounted (146 файлов)
```
extends Reference → extends RefCounted
```
Файлы: все в Game/, Inventory/, Player/Orifice/, Player/Fluids/, Player/FluidProduction/, Player/SensitiveZone/, Characters/, Skills/, Events/, StatusEffect/, Util/

### 1.2 onready → @onready (1,117 occurrences, 280+ файлов)
```
onready var → @onready var
```
Самые тяжёлые: GameUI.gd (30+), MainMenu.gd (26+), SexActivityCreator.gd (25+)

### 1.3 export() → @export (71 occurrences, 37 файлов)
```
export(Type) var name → @export var name: Type
export(String, "a", "b") var name → @export_enum("a", "b") var name
export(int, FLAGS, ...) var name → @export_flags(...) var name
export(NodePath) var name → @export var name: NodePath
setget → set / get (property syntax)
```
Тяжёлые: GameRoom.gd (22 exports), MeshWithPattern.gd (8)

### 1.4 yield → await (101 occurrences, 42+ файлов)
```
yield(get_tree(), "idle_frame") → await get_tree().process_frame
yield(get_tree().create_timer(N), "timeout") → await get_tree().create_timer(N).timeout
yield(obj, "signal") → await obj.signal
yield(result, "completed") → await result
```
Тяжёлые: GlobalRegistry.gd (~35), GameUI.gd, LaunchScreen.gd

### 1.5 String-based connect → Callable (254 occurrences, 130+ файлов)
```
obj.connect("signal", self, "method") → obj.signal.connect(method)
obj.connect("signal", self, "method", [args]) → obj.signal.connect(method.bind(args))
```

### 1.6 .instance() → .instantiate() (pervasive)
```
.instance() → .instantiate()
```

### 1.7 .empty() → .is_empty()
```
.empty() → .is_empty()
```

### 1.8 File/Directory → FileAccess/DirAccess
```
File.new() → FileAccess.open(path, mode)
Directory.new() → DirAccess.open(path)
dir.make_dir() → dir.make_dir_absolute()
```

### 1.9 Остальные API замены
```
get_tree().change_scene(path) → change_scene_to_file(path)
rect_size → size
rect_min_size → custom_minimum_size
margin_left/right/top/bottom → offset_left/right/top/bottom
interpolate_property → tween_property (через create_tween())
linear_interpolate → lerp
parse_json() → JSON.parse_string()
str2var() → str_to_var()
var2str() → var_to_str()
BUTTON_MIDDLE → MOUSE_BUTTON_MIDDLE
BUTTON_WHEEL_UP → MOUSE_BUTTON_WHEEL_UP
JavaScript.eval() → JavaScriptBridge.eval()
SceneTree.STRETCH_MODE_2D → changed API
OS.screen_orientation → changed API
add_font_override → theme system
PoolStringArray → PackedStringArray
```

---

## ЧАСТЬ 2: Миграция по системам (с флагами)

### Ключевые замечания
- [x] = выполнено
- [ ] = не выполнено
- 🔴 = критично
- 🟡 = важно
- 🟢 = можно позже

---

### 2.1 CORE SYSTEMS (已完成 в Phase 0-5)

| Система | Статус | Файлы | Строк |
|---------|--------|-------|-------|
| EventBus (Autoloads/) | ✅ | 1 | 80 |
| ServiceLocator (Core/) | ✅ | 1 | 20 |
| ItemData (Resources/) | ✅ | 1 | 10 |
| RegistryManager (Core/) | ✅ | 1 | 155 |
| Component (Components/) | ✅ | 1 | 9 |
| Entity (Entities/) | ✅ | 1 | 22 |
| HealthComponent | ✅ | 1 | 321 |
| PawnComponent | ✅ | 1 | 190 |
| SexReactionComponent | ✅ | 1 | 40 |
| DollPartManager | ✅ | 1 | 140 |
| Doll3D (Visuals/) | ✅ | 1 | 479 |
| DeformModifier3D | ✅ | 1 | 120 |
| JiggleModifier3D | ✅ | 1 | 45 |
| SimulationBridge | ✅ | 1 | 428 |
| SimulationEngine (C#) | ✅ | 1 | 50 |
| NpcData (C#) | ✅ | 1 | 14 |
| RoomGraph | ✅ | 1 | 35 |
| SexEngineManager | ✅ | 1 | 280 |
| SexState / IdleState / ActivityState | ✅ | 3 | 100 |
| SexAction / Thrust / Spank / Kiss | ✅ | 4 | 80 |
| CrotchScriptBase | ✅ | 1 | 230 |
| CrotchTranspiler | ✅ | 1 | 280 |
| CrotchCompiler | ✅ | 1 | 35 |
| CrotchGraphEditor | ✅ | 1 | 65 |
| QuestData / DialogueData | ✅ | 2 | 100 |
| ContentMigrator / AiPromptGenerator | ✅ | 2 | 150 |
| CI/CD (gdformat.yml) | ✅ | 1 | 30 |

---

### 2.2 GAME/ — Основные системы

| Система | Файлов | Строк | GM.* | Статус |
|---------|--------|-------|------|--------|
| **MainScene.gd** | 1 | 1,878 | 168 | ✅ МИГРИРОВАН (Godot 4 syntax, save/load/time/flags preserved) |
| **BaseCharacter.gd** | 1 | 1,796 | 25 | ✅ МИГРИРОВАН (Godot 4 syntax, all formulas preserved) |
| **SaveManager.gd** | 1 | 369 | 24 | ✅ МИГРИРОВАН (File→FileAccess, Directory→DirAccess, JSON→parse_string) |
| **PlayerPanel.gd** | 1 | 165 | 20 | ✅ МИГРИРОВАН (BUTTON_MIDDLE→MOUSE_BUTTON, touch handling) |
| **SaveConversion.gd** | 1 | 106 | 0 | 🟢 НЕ МИГРИРОВАН |
| **SpeechModifierBase.gd** | 1 | 11 | 0 | 🟢 НЕ МИГРИРОВАН |

### 2.3 GAME/WORLD

| Файл | Строк | GM.* | Статус |
|------|-------|------|--------|
| World.gd | 757 | 4 | ✅ МИГРИРОВАН (AStar2D pathfinding, room management, camera) |
| GameRoom.gd | 274 | 12 | ✅ МИГРИРОВАН (@tool, @export, setget→property, emit→signal.emit) |
| WorldPawn.gd | 75 | 0 | ✅ МИГРИРОВАН (Tween→create_tween, activity icons→dict) |
| WorldEntity.gd | 21 | 0 | ✅ МИГРИРОВАН (Tween→create_tween, typed variables) |
| Floors/*.gd (6 файлов) | ~370 | 36 | ✅ МИГРИРОВАН (уже чистый Godot 4 код) |
| Props/*.gd (3 файла) | ~122 | 0 | 🟢 НЕ МИГРИРОВАН |

### 2.4 GAME/SEXENGINE (152 файла, 32,219 строк)

| Файл | Строк | Статус |
|------|-------|--------|
| SexEngine.gd | ~500 | ✅ МИГРИРОВАН (extends RefCounted, .empty→.is_empty, .remove→.remove_at) |
| SexActivityBase.gd | 3538 | ✅ МИГРИРОВАН (extends RefCounted, all stimulation formulas preserved) |
| SexGoalBase.gd | 91 | ✅ МИГРИРОВАН (extends RefCounted, beg system preserved) |
| SexDomInfo.gd | ~80 | ✅ МИГРИРОВАН (anger/personality changes, goal management) |
| SexSubInfo.gd | ~80 | ✅ МИГРИРОВАН (resistance/fear/consciousness, personality changes) |
| SexVoice.gd | ~100 | ✅ МИГРИРОВАН (extends RefCounted, dialogue text preserved) |
| SexReactionHandler.gd | ~100 | ✅ МИГРИРОВАН (extends RefCounted, reaction chances preserved) |
| Personality.gd | 85 | ✅ МИГРИРОВАН (extends RefCounted, stat scoring preserved) |
| FetishHolder.gd | ~100 | ✅ МИГРИРОВАН (extends RefCounted, fetish scoring with obedience) |
| Fetish/*.gd (24 файла) | ~2,400 | ✅ МИГРИРОВАН (extends RefCounted) |
| Goal/*.gd (28 файлов) | ~2,800 | ✅ МИГРИРОВАН (extends RefCounted) |
| SexActivity/*.gd (37 файлов) | ~7,400 | ✅ МИГРИРОВАН (.empty→.is_empty, .instance→.instantiate) |
| SexType/*.gd (5 файлов) | ~250 | ✅ МИГРИРОВАН (extends RefCounted, .empty→.is_empty) |
| Reactions/DefaultReactions.gd | ~200 | ✅ МИГРИРОВАН (extends RefCounted) |
| Util/*.gd (8 файлов) | ~400 | ✅ МИГРИРОВАН (extends RefCounted, .empty→.is_empty) |

**Итого по SexEngine**: ~150 файлов, ~32,000 строк — ✅ МИГРИРОВАН (extends RefCounted, batch Godot 3 fixes)

### 2.5 GAME/INTERACTIONSYSTEM (69 файлов, 11,401 строк)

| Файл | Строк | GM.* | Статус |
|------|-------|------|--------|
| InteractionSystem.gd | ~500 | 32 | ✅ МИГРИРОВАН (extends RefCounted, batch Godot 3 fixes) |
| PawnInteractionBase.gd | ~300 | 74 | ✅ МИГРИРОВАН (extends RefCounted, .empty→.is_empty) |
| CharacterPawn.gd | ~200 | 26 | ✅ МИГРИРОВАН (extends RefCounted) |
| AloneGoals/*.gd (20 файлов) | ~2,000 | varies | ✅ МИГРИРОВАН (extends RefCounted, batch fixes) |
| GlobalTasks/*.gd (9 файлов) | ~700 | varies | ✅ МИГРИРОВАН (extends RefCounted) |
| Interactions/*.gd (19 файлов) | ~3,800 | varies | ✅ МИГРИРОВАН (.empty→.is_empty, .remove→.remove_at) |
| PawnTypes/*.gd (4 файла) | ~400 | varies | ✅ МИГРИРОВАН (extends RefCounted) |
| Relationship/*.gd (8 файлов) | ~800 | varies | ✅ МИГРИРОВАН (extends RefCounted, batch fixes) |

**Итого по InteractionSystem**: ~69 файлов, ~11,400 строк — ✅ МИГРИРОВАН (extends RefCounted, batch Godot 3 fixes)

### 2.6 GAME/MODULARDIALOGUE (24 файла, 14,037 строк)

| Файл | Строк | Статус |
|------|-------|--------|
| ModularDialogue.gd | ~200 | 🔴 НЕ МИГРИРОВАН |
| DialogueParser.gd | ~200 | 🔴 НЕ МИГРИРОВАН |
| DialogueFiller*.gd | ~94 | 🔴 НЕ МИГРИРОВАН |
| Adders/*.gd (8 файлов) | ~400 | 🔴 НЕ МИГРИРОВАН |
| Fillers/*.gd (8 файлов) | ~400 | 🔴 НЕ МИГРИРОВАН |

### 2.7 GAME/NPCSLAVERY (113 файлов, 11,949 строк)

ВСЁ 🔴 НЕ МИГРИРОВАН. Ключевые файлы:
- NpcSlave.gd (~200 строк)
- BreakTask/*.gd (26 файлов)
- SlaveActions/*.gd (24 файла)
- SlaveActionScenes/*.gd (26 файлов)
- SlaveEvents/*.gd (9 файлов)
- SlaveActivities/*.gd (7 файлов)

### 2.8 GAME/PLAYERSLAVERY (9 файлов, 6,603 строк)

ВСЁ 🔴 НЕ МИГРИРОВАН. Ключевые файлы:
- PlayerSlaveryBase.gd (~400 строк)
- Scenarios/MilkCafe.gd (1,244 строки — самый большой!)
- Scenarios/ShaftMiner.gd (808 строк)
- Scenarios/Tentacles.gd (628 строк)

### 2.9 GAME/PLAYERSLAVERYSOFT (72 файла, 8,263 строки)

ВСЁ 🔴 НЕ МИГРИРОВАН.

### 2.10 GAME/DRUGDEN (10 файлов, 1,597 строк)

ВСЁ 🔴 НЕ МИГРИРОВАН. DrugDen.gd — 433 строки, 45 GM.*.

### 2.11 GAME/PREGNANCY (9 файлов, 2,118 строк)

| Файл | Строк | Статус |
|------|-------|--------|
| MenstrualCycle.gd | 892 | 🔴 НЕ МИГРИРОВАН |
| ChildSystem.gd | 295 | 🔴 НЕ МИГРИРОВАН |
| EggCell.gd | 295 | 🔴 НЕ МИГРИРОВАН |
| EggLaid.gd | 283 | 🔴 НЕ МИГРИРОВАН |
| Child.gd | 139 | 🔴 НЕ МИГРИРОВАН |
| NpcGender.gd | 114 | 🔴 НЕ МИГРИРОВАН |
| SpeciesCompatibility.gd | 60 | 🔴 НЕ МИГРИРОВАН |
| BigEggType.gd | 7 | 🟢 НЕ МИГРИРОВАН |
| CycleStage.gd | 33 | 🟢 НЕ МИГРИРОВАН |

### 2.12 GAME/TRANSFORMATION (41 файл, 5,870 строк)

ВСЁ 🔴 НЕ МИГРИРОВАН. Ключевые:
- TFHolder.gd (475 строк)
- TFBase.gd (389 строк)
- Effects/*.gd (13 файлов)
- TFs/*.gd (22 файла)

### 2.13 GAME/DATAPACKS (298 файлов, 21,697 строк)

ЧАСТИЧНО 🔴 (CrotchCode мигрирован в Phase 4). Остальное:
- DatapackScene/*.gd — 🔴 НЕ МИГРИРОВАН
- UI/DatapackEditor*.gd — 🔴 НЕ МИГРИРОВАН
- UI/Editors/*.gd — 🔴 НЕ МИГРИРОВАН

### 2.14 GAME/Остальное

| Система | Файлов | Строк | Статус |
|---------|--------|-------|--------|
| LustCombat/ | 54 | 5,099 | 🔴 НЕ МИГРИРОВАН |
| SlaveAuction/ | 48 | 4,327 | 🔴 НЕ МИГРИРОВАН |
| Science/ | 8 | 1,791 | 🔴 НЕ МИГРИРОВАН |
| Reputation/ | 8 | 554 | 🔴 НЕ МИГРИРОВАН |
| Gameplay/ | 11 | 970 | ✅ МИГРИРОВАН (enums→match/case, constants) |
| Flags/ | 2 | 86 | ✅ МИГРИРОВАН (match/case, type hints) |
| Options/ | 4 | 1,748 | ✅ МИГРИРОВАН (File→FileAccess, JSON→parse_string, OS→DisplayServer) |
| Computer/ | 2 | 452 | 🔴 НЕ МИГРИРОВАН |
| Combat/ | 4 | 177 | 🔴 НЕ МИГРИРОВАН |
| Minigames/ | 9 | 655 | 🔴 НЕ МИГРИРОВАН |
| DomRoute/ | 9 | 780 | 🔴 НЕ МИГРИРОВАН |
| WorldHistory/ | 4 | 141 | 🔴 НЕ МИГРИРОВАН |
| GameExtenders/ | 4 | 165 | 🔴 НЕ МИГРИРОВАН |
| UI/ (Game/UI) | 11 | 1,427 | 🔴 НЕ МИГРИРОВАН |

---

### 2.15 PLAYER/ — Все подсистемы

| Подсистема | Файлов | Строк | Статус |
|-----------|--------|-------|--------|
| Player3D/Doll3D.gd | 1 | 963 | ✅ МИГРИРОВАН |
| Player3D/JiggleBone.gd | 1 | 166 | 🔴 НЕ МИГРИРОВАН (старый Godot 3) |
| Player3D/CurveRenderer.gd | 1 | 126 | 🔴 НЕ МИГРИРОВАН |
| Player3D/WritingsHandler.gd | 1 | 131 | 🔴 НЕ МИГРИРОВАН |
| Player3D/Skins/ (~170 файлов) | ~170 | ~2,200 | 🟡 НЕ МИГРИРОВАН (массовая замена) |
| Bodyparts/ (106 файлов) | ~106 | ~1,500 | 🔴 НЕ МИГРИРОВАН |
| Orifice/ (5 файлов) | 5 | ~370 | 🔴 НЕ МИГРИРОВАН |
| Fluids/ (16 файлов) | 16 | ~900 | 🔴 НЕ МИГРИРОВАН |
| FluidProduction/ (5 файлов) | 5 | ~450 | 🔴 НЕ МИГРИРОВАН |
| SensitiveZone/ (5 файлов) | 5 | ~390 | 🔴 НЕ МИГРИРОВАН |
| StageScene3D/ (131 файл) | ~131 | ~4,500 | 🔴 НЕ МИГРИРОВАН |
| Player.gd | 1 | 1,019 | 🔴 НЕ МИГРИРОВАН |

---

### 2.16 CHARACTERS/

| Файл | Строк | Статус |
|------|-------|--------|
| Character.gd | 610 | 🔴 НЕ МИГРИРОВАН |
| DynamicCharacter.gd | 848 | 🔴 НЕ МИГРИРОВАН |
| CharacterGeneratorBase.gd | 334 | 🔴 НЕ МИГРИРОВАН |
| Generator/*.gd (7 файлов) | ~588 | 🔴 НЕ МИГРИРОВАН |
| Named Characters (16 файлов) | ~1,600 | 🟡 НЕ МИГРИРОВАН |

---

### 2.17 INVENTORY/

| Подсистема | Файлов | Строк | Статус |
|-----------|--------|-------|--------|
| Inventory.gd | 1 | 935 | ✅ МИГРИРОВАН (equip/unequip/save/load all preserved) |
| ItemBase.gd | 1 | 730 | ✅ МИГРИРОВАН (extends RefCounted, all item methods preserved) |
| BuffsHolder.gd | 1 | 236 | 🔴 НЕ МИГРИРОВАН |
| Buffs/ (76 файлов) | 76 | ~2,600 | 🔴 НЕ МИГРИРОВАН |
| RestraintTypes/ (18 файлов) | 18 | ~1,100 | 🔴 НЕ МИГРИРОВАН |
| SmartLocks/ (5 файлов) | 5 | ~335 | 🔴 НЕ МИГРИРОВАН |
| Items/ (126 файлов) | 126 | ~5,300 | 🔴 НЕ МИГРИРОВАН |
| LootTable/ (11 файлов) | 11 | ~337 | 🔴 НЕ МИГРИРОВАН |
| ItemState/ (3 файла) | 3 | ~330 | 🔴 НЕ МИГРИРОВАН |

---

### 2.18 SKILLS/

| Файл | Строк | Статус |
|------|-------|--------|
| SkillsHolder.gd | 501 | 🔴 НЕ МИГРИРОВАН |
| PerkBase.gd | 121 | 🔴 НЕ МИГРИРОВАН |
| SkillBase.gd | 109 | 🔴 НЕ МИГРИРОВАН |
| Perk/*.gd (89 файлов) | ~2,000 | 🔴 НЕ МИГРИРОВАН (массовая замена) |
| Skill/*.gd (8 файлов) | ~128 | 🟡 НЕ МИГРИРОВАН |

---

### 2.19 SCENES/ (64 файла, 11,485 строк)

| Файл | Строк | Статус |
|------|-------|--------|
| SceneBase.gd | 444 | ✅ МИГРИРОВАН (Godot 4 syntax, all UI helpers preserved) |
| FightScene.gd | 1,095 | 🔴 НЕ МИГРИРОВАН |
| WorldScene.gd | 376 | 🔴 НЕ МИГРИРОВАН |
| CharacterCreatorScene.gd | 412 | 🔴 НЕ МИГРИРОВАН |
| IntroScene.gd | 383 | 🔴 НЕ МИГРИРОВАН |
| Все остальные (60 файлов) | ~9,000 | 🔴 НЕ МИГРИРОВАН |

---

### 2.20 UI/ (81 файл, 7,305 строк)

| Файл | Строк | Статус |
|------|-------|--------|
| GameUI.gd (Game/UI/) | 712 | ✅ МИГРИРОВАН (Godot 4 syntax, 30+ onready, yield→await, connect migrated) |
| LaunchScreen.gd | 637 | 🔴 НЕ МИГРИРОВАН |
| MainMenu.gd | 319 | 🔴 НЕ МИГРИРОВАН |
| ButtonChecks.gd | 395 | 🔴 НЕ МИГРИРОВАН |
| SkillsUI.gd | 210 | 🔴 НЕ МИГРИРОВАН |
| Inventory/ (4 файла) | ~570 | 🔴 НЕ МИГРИРОВАН |
| Options/ (8 файлов) | ~400 | 🔴 НЕ МИГРИРОВАН |
| DebugUI/ (12 файлов) | ~750 | 🔴 НЕ МИГРИРОВАН |
| RichTextBoxEffects/ (6 файлов) | ~145 | 🔴 НЕ МИГРИРОВАН |
| Все остальные | ~2,300 | 🔴 НЕ МИГРИРОВАН |

---

### 2.21 EVENTS/ (15 файлов, 680 строк)

ВСЁ 🔴 НЕ МИГРИРОВАН. Ключевые:
- EventSystem.gd (137 строк)
- EventBase.gd (119 строк, 16 GM.*)
- Event/*.gd (7 файлов)

---

### 2.22 UTIL/ (85 файлов, 10,500 строк)

| Подсистема | Файлов | Строк | Статус |
|-----------|--------|-------|--------|
| Util.gd | 1 | 890 | 🔴 НЕ МИГРИРОВАН |
| GameParser.gd | 1 | 508 | 🔴 НЕ МИГРИРОВАН |
| SayParser.gd | 1 | 180 | 🔴 НЕ МИГРИРОВАН |
| RNG.gd | 1 | 170 | 🔴 НЕ МИГРИРОВАН |
| gdunzip.gd | 1 | 669 | 🔴 НЕ МИГРИРОВАН |
| SexToySupport/ (30 файлов) | 30 | ~3,500 | 🔴 НЕ МИГРИРОВАН |
| SexActivityCreator/ (20 файлов) | 20 | ~1,600 | 🔴 НЕ МИГРИРОВАН |
| InteractionCreator/ (5 файлов) | 5 | ~1,000 | 🔴 НЕ МИГРИРОВАН |
| AutoTranslation/ (8 файлов) | 8 | ~1,100 | 🔴 НЕ МИГРИРОВАН |

---

### 2.23 MODULES/ (22 модуля, 870 файлов, ~30,000+ строк)

| Модуль | Файлов | GM.* | Статус |
|--------|--------|------|--------|
| TaviModule | 123 | 52 | 🔴 НЕ МИГРИРОВАН |
| HypnokinkModule | 84 | 62 | 🔴 НЕ МИГРИРОВАН |
| MedicalModule | 66 | 29 | 🔴 НЕ МИГРИРОВАН |
| RahiModule | 67 | 111 | 🔴 НЕ МИГРИРОВАН |
| FightClubModule | 63 | 102 | 🔴 НЕ МИГРИРОВАН |
| PlayerSlaveryModule | 58 | 90 | 🔴 НЕ МИГРИРОВАН |
| ArticaModule | 51 | 46 | 🔴 НЕ МИГРИРОВАН |
| ElizaModule | 46 | 80 | 🔴 НЕ МИГРИРОВАН |
| CellblockModule | 33 | 39 | 🔴 НЕ МИГРИРОВАН |
| SlaveAuctionModule | 32 | 53 | 🔴 НЕ МИГРИРОВАН |
| PortalPantiesModule | 31 | 97 | 🔴 НЕ МИГРИРОВАН |
| DrugDenModule | 28 | 38 | 🔴 НЕ МИГРИРОВАН |
| PunishmentsModule | 38 | 38 | 🔴 НЕ МИГРИРОВАН |
| NpcSlaveryModule | 15 | 14 | 🔴 НЕ МИГРИРОВАН |
| SocketModule | 15 | 43 | 🔴 НЕ МИГРИРОВАН |
| NovaModule | 13 | 45 | 🔴 НЕ МИГРИРОВАН |
| JackiModule | 13 | 74 | 🔴 НЕ МИГРИРОВАН |
| GymModule | 14 | 37 | 🔴 НЕ МИГРИРОВАН |
| SongJoHairsModule | 43 | 0 | 🟡 НЕ МИГРИРОВАН |
| KaitModule | 5 | 0 | 🟢 НЕ МИГРИРОВАН |
| AcePregExpac | 5 | 18 | 🟡 НЕ МИГРИРОВАН |
| Module.gd (root) | 1 | 191 | ✅ МИГРИРОВАН (extends RefCounted, registration loop preserved) |

**Итого по Modules**: 870 файлов, 4,000+ GM.* — 🔴 КРИТИЧНО

---

### 2.24 ОСТАЛЬНОЕ

| Категория | Файлов | Строк | Статус |
|-----------|--------|-------|--------|
| Species/ | 8 | 516 | 🟢 НЕ МИГРИРОВАН (0 GM.*) |
| StatusEffect/ | 78 | 4,300 | 🔴 НЕ МИГРИРОВАН |
| Shaders/ | 5 | 149 | 🟡 НЕ МИГРИРОВАН |
| Fonts/ (resources) | ~23 | — | 🟡 .tres конвертация |
| addons/ (2) | ~15 | — | 🔴 НЕ МИГРИРОВАН |
| .github/workflows/ | 2 | — | ✅ gdformat.yml создан |
| Images/ | ~402 | — | 🟢 Ассеты без изменений |

---

## ЧАСТЬ 3: Приоритеты миграции

### 🔴 P0: Критические (блокируют всё остальное)

1. **BaseCharacter.gd** (1,796 строк) — базовый класс для ВСЕХ персонажей
2. **MainScene.gd** (1,878 строк) — центральный оркестратор
3. **SceneBase.gd** (444 строки) — основа всех 64 сцен
4. **GameUI.gd** (712 строк) — центральный UI
5. **Module.gd** (191 строк) — базовый класс для 22 модулей
6. **ItemBase.gd** (730 строк) — базовый класс предметов
7. **Inventory.gd** (935 строк) — система инвентаря

### 🔴 P1: Крупные системы

8. **SexEngine** (32,219 строк, 152 файла)
9. **InteractionSystem** (11,401 строк, 69 файлов)
10. **NpcSlavery** (11,949 строк, 113 файлов)
11. **ModularDialogue** (14,037 строк, 24 файла)
12. **Modules** (30,000+ строк, 870 файлов)
13. **LustCombat** (5,099 строк, 54 файла)
14. **Transformation** (5,870 строк, 41 файл)
15. **PlayerSlavery/PlayerSlaverySoft** (14,866 строк, 81 файл)
16. **SlaveAuction** (4,327 строк, 48 файлов)
17. **StageScene3D** (4,500 строк, 131 файл)
18. **StatusEffect** (4,300 строк, 78 файлов)

### 🟡 P2: Средние системы

19. **Pregnancy** (2,118 строк, 9 файлов)
20. **Science** (1,791 строк, 8 файлов)
21. **Options** (1,748 строк, 4 файла)
22. **World** (1,655 строк, 22 файла)
23. **DrugDen** (1,597 строк, 10 файлов)
24. **Reputation** (554 строк, 8 файлов)
25. **SexToySupport** (3,500 строк, 30 файлов)
26. **Util** (10,500 строк, 85 файлов)
27. **Scenes/** (11,485 строк, 64 файла)
28. **UI/** (7,305 строк, 81 файл)

### 🟢 P3: Низкий приоритет

29. **Species** (516 строк, 8 файлов, 0 GM.*)
30. **Shaders** (149 строк, 5 файлов)
31. **Skins** (~2,200 строк, 170 файлов, шаблонный код)
32. **Perks** (~2,000 строк, 89 файлов, шаблонный код)
33. **Bodyparts** (~1,500 строк, 106 файлов, шаблонный код)
34. **Items** (~5,300 строк, 126 файлов)
35. **Buffs** (~2,600 строк, 76 файлов)

---

## ЧАСТЬ 4: Оценка трудоёмкости

| Категория | Файлов | Строк | Оценка (часы) |
|-----------|--------|-------|---------------|
| Bulk замены (regex) | ~3,215 | ~200,000 | 8-16 часов |
| P0: Критические | 7 | ~5,600 | 40-60 часов |
| P1: Крупные системы | ~700 | ~130,000 | 200-300 часов |
| P2: Средние системы | ~500 | ~30,000 | 80-120 часов |
| P3: Низкий приоритет | ~500 | ~10,000 | 30-50 часов |
| Тестирование | — | — | 40-60 часов |
| **ИТОГО** | **~3,215** | **~200,000** | **400-600 часов** |

---

## ЧАСТЬ 5: Стратегия

### Рекомендуемый порядок:

1. **Bulk regex замены** (Reference→RefCounted, onready→@onready, export→@export, yield→await, connect→callable)
2. **P0: BaseCharacter → Entity + компоненты** (самая фундаментальная миграция)
3. **P0: MainScene → отдельные менеджеры** (SceneManager, TimeManager, FlagManager)
4. **P0: SceneBase + GameUI** (все сцены зависят от этих двух классов)
5. **P0: Module.gd + GlobalRegistry → RegistryManager** (все модули зависят)
6. **P1: SexEngine** (самая большая система)
7. **P1: InteractionSystem** (вторая по размеру)
8. **P1: Modules** (самое трудоёмкое по количеству файлов)
9. **P2-P3: Остальное**

### Автоматизируемые компоненты:

- **Skins** (170 файлов): шаблонные, 13 строк каждый → batch migration
- **Perks** (89 файлов): шаблонные, ~22 строки каждый → batch migration
- **Bodyparts** (106 файлов): шаблонные, ~14 строк каждый → batch migration
- **Buffs** (76 файлов): шаблонные, ~38 строк каждый → batch migration
- **StatusEffects** (78 файлов): частично шаблонные → semi-automated
