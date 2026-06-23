# 3D Rendering & Visual Systems — Analysis

> `Player/Player3D/` — 449 .gd файла
> `Player/StageScene3D/` — 70 сцен анимации
> `Shaders/` — 5 шейдеров

## 1. Modular Body System (Slotting Parts)

`Doll3D` (963 строк) — модульная 3D-кукла. Каждая область тела — именованный слот (`"body"`, `"head"`, `"breasts"`, `"legs"`, `"penis"`, `"hair"`, `"ears"`, `"tail"`, `"horns"`, `"hands"`), маппящийся на `.tscn` сцену:

```gdscript
func addPartObject(slot, part: Spatial, callbackObj = null):
    if(parts.has(slot)):
        parts[slot].onRemoved()
        parts[slot].queue_free()
    parts[slot] = part
    getDollSkeleton().getSkeleton().add_child(part)
    part.initPart(self)
```

Части заменяются через `setParts(newparts)` с dirty flags — пересоздаются только изменённые слоты. Каждая часть сама регистрирует **attachment proxies** для неригged предметов (оружие, аксессуары).

## 2. Bone Deformation (Беременность/Грудь)

Деформация через **custom bone poses** на именованных deform-костях:

```gdscript
func setPregnancy(progress: float):
    var horisontalBellyScale = 1.0+max(0.0, progress-1.0)
    setBoneScale3AndOffset("DeformBelly",
        Vector3(verticalBellyScale, horisontalBellyScale, horisontalBellyScale),
        Vector3(-0.03244*0.0, 0.706324, 0.0)*clamp(progress, -0.1, 1.0))
    bellyJiggleBone.stiffness = 0.1 / ((clamp(progress, 0.0, 1.0) + 0.2) / 1.2)
```

- **Грудь**: `setBoneScaleAndOffset("DeformBreasts", ...)` с jiggle stiffness, обратно пропорциональным размеру
- **Беременность**: ограничена 5x, не-uniform scaling (Y/Z оси)
- **Ягодицы**: offsets кость `Tail1` для предотвращения clipping
- Все деформации через `set_bone_custom_pose` — не затрагивают pose анимации

## 3. Jiggle Physics

`JiggleBone` — **Verlet integration** с spring-damper динамикой:

```gdscript
vel += grav * (stiffness / OPTIONS.getJigglePhysicsGlobalModifier())
vel -= vel * (damping) * delta
vel.z = 0.0  # Ограничение 2D плоскостью (BDCC-specific)
bone_rotate_axis.x = 0.0  # Предотвращение clipping при экстремальных размерах
```

**Хак**: Обнуление X-оси velocity и rotation axis — критическое для предотвращения clipping при extreme sizes.

## 4. Chain System

Цепи соединяют два `DollAttachmentZone` через `CurveRenderer` (extends `ImmediateGeometry`). Каждый кадр строится **Bezier catenary**:

```gdscript
var mid_point_sagged = mid_point + (down_vec * sag_static) + (down_vec * sag_from_length * unused_length)
```

Кривая тесселируется в camera-facing quad strip с накопленной UV-дистанцией для texture tiling. Sag пропорционален неиспользованной длине цепи. Типы цепей (normal/short/hose/cable) — разные `.tscn` с разными параметрами `CurveRenderer`.

## 5. Dynamic Body Writings

`WritingsHandler` рендерит текст в **Viewport texture** через Godot 2D `Label`:

1. Читает `writingsData` из куклы (zone → text array)
2. Создаёт `VBoxContainer` + `Label` ноды в zone позициях
3. Зеркалит зоны в зависимости от facing direction
4. Рендерит однократно через `viewport.render_target_update_mode = UPDATE_ONCE`
5. Кормит viewport texture в шейдер: `mesh.fancyMaterial.set_shader_param("texture_writings", theTexture)`

Cache предотвращает лишние ререндеры. Labels получают случайный rotation/offset для органичности.

## 6. Image Packs

`ImagePack` хранит изображения персонажей и сцен с **variant indexing**. Character images могут быть layering arrays:

```gdscript
# ["female_body_base.png", "fox_head.png", "red_ponytail_hair.png"]
```

Scene images поддерживают **условный выбор** через `ImageConditions.areTrue()` — проверяет PC gender traits и game flags (MalePC, FemalePC, HermPC, FlagIsTrue, FlagAbove и т.д.).

## 7. Shaders (5 файлов, ~150 строк)

| Шейдер | Строк | Техника |
|--------|-------|---------|
| Shadow | 24 | 8-tap box blur для drop shadow |
| Outline | 30 | 4-tap alpha-difference outline |
| SmartOutline | 53 | 12-tap radial outline + vertex margin expansion |
| Aura | 35 | Premultiplied-alpha glow (additive) |
| Silhouette | 8 | Flat-color fill с preserved alpha |

Все — `canvas_item` (2D). 3D использует Godot built-in + custom `fancyMaterial` для writings overlay.

## 8. Stage System

`Stage3D` (38 строк) — простой менеджер сцен с fade transitions. `BaseStageScene3D` — базовый класс для 70 анимационных сцен. `StageScene.gd` (135 строк) — чистый constants файл с ~130 ID сцен.

## 9. Сильные стороны

1. **Модульность** — части тела слотятся/заменяются динамически
2. **Bone deformation** — чистая система через custom poses
3. **Jiggle physics** — Verlet integration с простыми хаками для clipping
4. **Dynamic writings** — инновационный подход через viewport textures
5. **Image conditions** — гибкая система вариативности изображений

## 10. Слабые стороны

1. **963 строки в Doll3D** — смешивает слотting, state machine, particles, chains, writings
2. **Хардкодинг** — `vel.z = 0.0` и `bone_rotate_axis.x = 0.0` без конфигурации
3. **Нет оптимизации** — body writings рендерят при каждом изменении без dirty tracking
4. **5 шейдеров** — все примитивные, нет пост-обработки

## 11. Рекомендации

| Приоритет | Действие |
|---|---|
| **Высокий** | Разбить Doll3D на подсистемы (SlotManager, PhysicsManager, WritingsManager) |
| **Средний** | Добавить dirty tracking для body writings |
| **Средний** | Вынести jiggle physics в отдельный компонент |
| **Низкий** | Добавить LOD для distant pawns |
