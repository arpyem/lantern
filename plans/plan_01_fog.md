# Plan 01 — Fog System

## Context
World.tscn currently has: CanvasModulate, Ground, PoeManager, Player, Camera2D.
Player has movement and lantern PointLight2D. Poes spawn around the lantern.
Plans directory is clean. Build only what is described here.

## Goal
Add visible animated fog on top of the existing CanvasModulate darkness.
The fog is purely visual for now — soft, layered, drifting sprite clusters
in the style of BOTW/TOTK ground mist.
No clearing, no interaction with game logic, no behaviour changes.

---

## 1. Generate fog sprites

Add a fog sprite generation block to AssetGenerator (or create it if it doesn't exist).

Three sprites, saved as horizontal 4-frame spritesheets:

| File | Dimensions (per frame) | Spritesheet size |
|---|---|---|
| `res://assets/placeholder/fog/fog_large.png` | 48×32 | 192×32 |
| `res://assets/placeholder/fog/fog_medium.png` | 32×24 | 128×24 |
| `res://assets/placeholder/fog/fog_small.png` | 20×16 | 80×16 |

Each sprite is a soft gaussian blob — bright cool-white core fading to fully
transparent at edges. No outlines. No defined shape. Rounded and puffy.

Generation per sprite (for each of 4 frames):
- Create Image at frame dimensions, FORMAT_RGBA8, all pixels start transparent
- For each pixel, compute distance from image centre
- Apply gaussian falloff: `alpha = exp(-dist² / (2 × sigma²)) × max_alpha`
- Color: lerp from Color(0.65, 0.74, 0.88, 0.0) at edge to Color(0.78, 0.85, 0.95, 1.0) at core
- Per frame, vary sigma slightly (frame 0: 1.0×, frame 1: 1.03×, frame 2: 1.05×, frame 3: 1.03×)
  — this bakes a subtle breathing variation into the spritesheet

Sigma values:
- fog_large: base sigma = 18, max_alpha = 0.55
- fog_medium: base sigma = 11, max_alpha = 0.60
- fog_small: base sigma = 7, max_alpha = 0.65

Stitch the 4 frames side-by-side into one Image and save with `Image.save_png()`.

---

## 2. FogCluster scene

Create `res://scenes/fog_cluster.tscn` and `res://scripts/fog_cluster.gd`.

Scene tree:
```
FogCluster (Node2D)              — fog_cluster.gd
├── LayerA (Sprite2D)            — fog_large spritesheet, hframes = 4
├── LayerB (Sprite2D)            — fog_medium spritesheet, hframes = 4
├── LayerC (Sprite2D)            — fog_small spritesheet, hframes = 4
└── AnimationPlayer
```

`fog_cluster.gd`:

```
@export var drift_speed: float = 4.0
@export var drift_angle: float = 0.0
@export var phase_offset: float = 0.0
@export var opacity_scale: float = 1.0
@export var wrap_distance: float = 120.0
var _spawn_origin: Vector2
```

On `_ready`:
- Store `_spawn_origin = position`
- Offset LayerB position by a small random amount (±8px x, ±6px y)
- Offset LayerC position by a larger random amount (±14px x, ±10px y)
- Set LayerA/B/C modulate: alpha = (0.9, 0.7, 0.5) × opacity_scale
- Set each layer's frame to a random start frame (0–3)
- Load textures via AssetConfig if it exists, otherwise load() directly

AnimationPlayer — one animation "breathe", 3.0s loop:
- Track 1: LayerA frame, keys at 0s→3→1s→0→2s→1→3s→2 (cycles slowly)
- Track 2: LayerB frame, same but offset by 0.4s
- Track 3: LayerC frame, same but offset by 0.8s

In `_process(delta)`:
- `position += Vector2.from_angle(drift_angle) * drift_speed * delta`
- If `position.distance_to(_spawn_origin) > wrap_distance`:
  - `position = _spawn_origin`

---

## 3. FogManager node

Create `res://scripts/fog_manager.gd`. Add a `FogManager` (Node2D) to World.tscn.

```
@export var cluster_scene: PackedScene
@export var cluster_count: int = 60
@export var world_radius: float = 1200.0
```

On `_ready`: call `_populate()`

`_populate()`:
- For i in cluster_count:
  - Generate random position using uniform disk:
    `var r = world_radius * sqrt(randf())`
    `var a = randf() * TAU`
    `var pos = Vector2(cos(a), sin(a)) * r`
  - Instance cluster_scene, set position = pos
  - Randomise: drift_angle (0–TAU), phase_offset (0–3.0), opacity_scale (0.7–1.0)
  - Add as child

Assign `cluster_scene` in Inspector after creating the scene.

---

## 4. Update World.tscn

Add FogManager between Ground and PoeManager.
Set z_index: Ground = 0, FogManager = 1, PoeManager = 2, Player = 3.

```
World (Node2D)
├── CanvasModulate
├── Ground
├── FogManager (Node2D)        ← new
├── PoeManager (Node2D)
├── Player (CharacterBody2D)
└── Camera2D
```

No changes to world.gd.

---

## Done when
- Dark world has visible soft fog clusters drifting slowly
- Fog has layered depth — large, medium, small sprites overlapping
- Player lantern illuminates nearby fog sprites with warm amber glow (free, Godot handles it)
- Animation gives a gentle breathing quality
- 60fps maintained at cluster_count = 60 (reduce to 40 if not)
- Fog reads as cool blue-white ground mist, not smoke or a flat overlay

## Not in this plan
- Fog clearing or dispersal
- Fog reacting to player proximity
- FogSystem logic (is_position_lit, etc)
- Installation placement
- HUD
- Poe collection
