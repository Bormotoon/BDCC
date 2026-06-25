# Task: Godot 3→4 .tscn Scene File Migration

## Agent: opencode
## Priority: P1 (parallel, non-blocking)
## Scope: .tscn and .tres files ONLY — do NOT touch .gd files

## Project Context

BDCC (Broken Dreams Correctional Center) is a text-based adult sci-fi game built on Godot. We are migrating from Godot 3.x to Godot 4.4.1. The GDScript (.gd) migration is mostly done by another agent. Your task is to migrate **scene files** (.tscn, .tres) from Godot 3 format to Godot 4 format.

- **Repo root**: `/home/borm/VibeCoding/BDCC`
- **Godot version**: 4.4.1 installed at `~/.local/bin/godot`
- **Total .tscn files**: ~644 scenes, ~73 .tres resources
- **Another agent is working on .gd files simultaneously** — do NOT edit any .gd files

## What to Do

### Step 1: Inventory

Find all .tscn and .tres files that contain Godot 3 node types or deprecated properties:

```bash
# Find .tscn files
find /home/borm/VibeCoding/BDCC -name "*.tscn" | wc -l

# Find .tres files
find /home/borm/VibeCoding/BDCC -name "*.tres" | wc -l
```

### Step 2: Node Type Renames

In `.tscn` files, replace Godot 3 node type names with Godot 4 equivalents. These appear in lines like:
```
[node name="Foo" type="Spatial" parent="."]
```

**Node type renames:**
| Godot 3 | Godot 4 |
|---------|---------|
| Spatial | Node3D |
| KinematicBody | CharacterBody3D |
| KinematicBody2D | CharacterBody2D |
| Viewport | SubViewport |
| Particles | GPUParticles3D |
| Particles2D | GPUParticles2D |
| CPUParticles | CPUParticles3D |
| CPUParticles2D | CPUParticles2D |
| ARVRCamera | XRCamera3D |
| ARVRController | XRController3D |
| ARVRAnchor | XRAnchor3D |
| ARVROrigin | XROrigin3D |
| MeshInstance | MeshInstance3D |
| MeshInstance2D | MeshInstance2D |
| Light | Light3D |
| OmniLight | OmniLight3D |
| SpotLight | SpotLight3D |
| DirectionalLight | DirectionalLight3D |
| ClippedCamera | Camera3D |
| Camera | Camera3D |
| AnimationPlayer | AnimationPlayer |
| AnimationTree | AnimationTree |
| ResourceInteractiveLoader | ResourceLoader |
| ResourcePreloader | ResourcePreloader |
| SoftBody | SoftBody3D |
| AudioStreamPlayer | AudioStreamPlayer |
| AudioStreamPlayer2D | AudioStreamPlayer2D |
| AudioStreamPlayer3D | AudioStreamPlayer3D |
| CanvasItem | CanvasItem |
| Control | Control |
| Container | Container |
| WindowDialog | Window |
| Popup | Popup |
| PopupDialog | Popup |
| ToolButton | Button |
| LinkButton | LinkButton |
| LineEdit | LineEdit |
| TextEdit | TextEdit |
| TreeItem | (removed, use Tree node) |
| GraphNode | GraphNode |
| GraphEdit | GraphEdit |
| StyleBoxFlat | StyleBoxFlat |
| StyleBoxLine | StyleBoxLine |
| StyleBoxEmpty | StyleBoxEmpty |
| ImageTexture | ImageTexture |
| AtlasTexture | AtlasTexture |
| GradientTexture2D | GradientTexture2D |
| NoiseTexture2D | NoiseTexture2D |
| PlaceholderTexture2D | PlaceholderTexture2D |
| ViewportTexture | ViewportTexture |
| CurveTexture | CurveTexture |
| Sprite | Sprite2D |
| Sprite3D | Sprite3D |
| AnimatedSprite | AnimatedSprite2D |
| AnimatedSprite3D | AnimatedSprite3D |
| Label | Label |
| RichTextLabel | RichTextLabel |
| Button | Button |
| TextureRect | TextureRect |
| NinePatchRect | NinePatchRect |
| ProgressBar | ProgressBar |
| HSlider | HSlider |
| VSlider | VSlider |
| Range | Range |
| ScrollBar | ScrollBar |
| HScrollBar | HScrollBar |
| VScrollBar | VScrollBar |
| TabContainer | TabContainer |
| Tabs | Tabs |
| Panel | Panel |
| PanelContainer | PanelContainer |
| MarginContainer | MarginContainer |
| HBoxContainer | HBoxContainer |
| VBoxContainer | VBoxContainer |
| GridContainer | GridContainer |
| CenterContainer | CenterContainer |
| ScrollContainer | ScrollContainer |
| WindowDialog | Window |
| ConfirmationDialog | ConfirmationDialog |
| AcceptDialog | AcceptDialog |
| ColorPicker | ColorPicker |
| ColorPickerButton | ColorPickerButton |
| FileDialog | FileDialog |
| PopupMenu | PopupMenu |
| OptionButton | OptionButton |
| CheckBox | CheckBox |
| CheckButton | CheckButton |
| SpinBox | SpinBox |
| WindowDialog | Window |

### Step 3: Property Renames

In `.tscn` files, replace deprecated property names:

| Godot 3 | Godot 4 |
|---------|---------|
| margin_left | offset_left |
| margin_right | offset_right |
| margin_top | offset_top |
| margin_bottom | offset_bottom |
| rect_min_size | custom_minimum_size |
| rect_position | position |
| rect_size | size |
| rect_rotation | rotation |
| rect_scale | scale |
| rect_pivot_offset | pivot_offset |
| rect_clip_content | clip_contents |
| mouse_filter | mouse_filter (same) |
| size_flags_horizontal | size_flags_horizontal (same) |
| size_flags_vertical | size_flags_vertical (same) |
| hint_tooltip | tooltip_text |

### Step 4: Node Property Renames (3D)

| Godot 3 | Godot 4 |
|---------|---------|
| transform | transform (same) |
| translation | position |
| rotation_degrees | rotation_degrees |
| scale | scale |

### Step 5: Shader References

Replace `.shader` with `.gdshader` in any resource references.

### Step 6: ext_resource Type Changes

In `.tscn`, `ext_resource` type hints may need updating:
```
# Old:
[ext_resource path="..." type="Script" id=1]
# Godot 4 uses: type="Script" (same, no change needed)
```

But `.shader` → `.gdshader` in paths.

### Step 7: sub_resource Updates

Some sub_resource types were renamed:
- `RectangleShape2D` → `RectangleShape2D` (same, but `extents` property → `size`, and value is halved)
- `PlaneShape` → `PlaneShape` (same)
- `SphereShape` → `SphereShape` (same)
- `CapsuleShape` → `CapsuleShape` (same)
- `BoxShape` → `BoxShape` (same, but `extents` → `size`)
- `ConvexPolygonShape` → `ConvexPolygonShape` (same)
- `HeightMapShape` → `HeightMapShape` (same)
- `PlaneMesh` → `PlaneMesh` (same)
- `PrismMesh` → `PrismMesh` (same)
- `SphereMesh` → `SphereMesh` (same)
- `CapsuleMesh` → `CapsuleMesh` (same)
- `BoxMesh` → `BoxMesh` (same)
- `TextMesh` → `TextMesh` (same)

### Step 8: Resource format changes

- `Font` resource: `DynamicFontData` → `FontFile`, `DynamicFont` → `FontVariation`
- `StyleBox` types: same names, but check for deprecated properties

## Critical Rules

1. **DO NOT edit .gd files** — another agent handles those
2. **Work in batches** — process 50 files at a time, commit after each batch
3. **Preserve all data** — only rename types/properties, don't remove content
4. **Commit after each batch** with descriptive message like "fix: migrate .tscn Godot 3→4 types (batch N)"
5. **Test periodically** — run `godot --headless --check-only 2>&1 | grep "ERROR"` to check for new errors
6. **Some errors are expected** — font errors (Titillium), scene instantiation errors — these are non-blocking
7. **Do not change node hierarchy** — only rename types and properties

## Workflow

1. Start with simplest scenes first (UI scenes in Game/UI/)
2. Then Player/ scenes
3. Then Game/ scenes  
4. Then Scenes/ (main game scenes)
5. Then Modules/ scenes (content modules)

## Commits

Use conventional commit format:
```
fix: migrate .tscn Godot 3→4 node types (batch N)

Replaced deprecated node type names and properties:
- Spatial→Node3D, KinematicBody→CharacterBody3D
- margin_*→offset_*, rect_*→position/size
- Applied to N files in <directory>
```

## Verification

After each batch, run:
```bash
godot --headless --check-only 2>&1 | grep -c "SCRIPT ERROR"
godot --headless --check-only 2>&1 | grep -c "ERROR:" 
```

Track if error count changes. Font/scene errors are expected and can be ignored.

## Known Non-Blocking Errors (ignore these)

- `Font` resource errors (Titillium-Bold.otf, Titillium-Regular.otf) — missing font files
- `TooltipDisplay.tscn` non-existent — scene reference issue
- `ModBrowser.tscn` / `LaunchScreen.tscn` resource errors — font dependencies

## Do NOT Touch

- Any `.gd` files (scripts) — another agent is working on these
- `project.godot` — already configured
- `MIGRATION_CHECKLIST.md` — managed by another agent
- `MEMORY*.md` files — managed by another agent
