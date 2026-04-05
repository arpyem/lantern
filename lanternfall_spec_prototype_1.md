# Lanternfall — Prototype Scene Technical Specification

**Godot Version:** 4.x
**Scene scope:** Single self-contained prototype — core loop slice
**Spec version:** 0.5 — Asset pipeline added
**Last updated:** 2026-04-03

> This spec covers the first playable scene. Every system is designed to be
> isolated, testable independently, and extensible into subsequent prototype
> scenes. No system should have hard dependencies on another except through
> clearly defined interfaces described below.

---

## Table of Contents

0. [Claude Code Implementation Briefing](#0-claude-code-implementation-briefing)
1. [Scene Architecture](#1-scene-architecture)
2. [System: Player](#2-system-player)
3. [System: FogSystem](#3-system-fogsystem)
4. [System: PoeManager](#4-system-poemanager)
5. [System: InstallationManager](#5-system-installationmanager)
6. [System: GameManager](#6-system-gamemanager)
7. [Inter-system Communication](#7-inter-system-communication)
8. [Input Map](#8-input-map)
9. [Scene Tree Layout](#9-scene-tree-layout)
10. [Resolved Decisions & Remaining Questions](#10-resolved-decisions--remaining-questions)

---

## 0. Claude Code Implementation Briefing

> **Read this section first.** It summarises everything you need to know before touching a single file. The rest of the spec is the detailed reference — come back to it system by system as you implement.

### 0.1 What You Are Building

A single Godot 4 prototype scene that proves the core gameplay loop of **Lanternfall** — a cozy top-down 2D exploration game where the player carries a handheld lantern through a fog-shrouded world, clears fog permanently by placing light installations, attracts ghostly companions called Poes, and watches a settlement slowly grow as a beacon in the dark.

This is a **script-first prototype** with **generated placeholder art**. There is no hand-made production art yet, but there are still art assets: flat-color PNG placeholders generated on first run by `AssetGenerator.gd` and loaded through `Sprite2D`. The goal is to prove the loop *feels good* before final art is produced. Every script should be written with the expectation that placeholder textures will later be swapped for final sprites without touching logic.

### 0.2 The Five Systems

You are building exactly five systems, each in its own script, wired together by a thin `World.gd` scene controller:

| System | Script | Core job |
|---|---|---|
| Player | `player.gd` | Movement, lantern light, placement input |
| FogSystem | `fog_system.gd` + `fog_renderer.gd` | Fog overlay, permanent clearance, waterline animation |
| PoeManager | `poe_manager.gd` + `poe.gd` | Spawn, attract, collect ghostly companions |
| InstallationManager | `installation_manager.gd` + `installation.gd` | Validate and place permanent light installations |
| GameManager | `game_manager.gd` | Autoload singleton — state and signals only |

### 0.3 The Most Important Design Decisions (Already Made)

Do not revisit these. They are resolved:

- **The lantern never permanently clears fog.** Only placed installations do. The lantern is always temporary visibility.
- **Fog rendering is a hybrid.** `CanvasModulate` + `PointLight2D` handles real-time darkness and the lantern's temporary radial light pool (Godot does this natively, for free). A separate 512×512 `Image` mask handles *permanent* clearance state. The mask is only redrawn during active clearance animations and idle breathing — not every frame.
- **The fog boundary behaves like a waterline**, not a geometric edge. It has noise-offset irregularity, an animated fringe (cool blue-white, like foam), a damp-sand residual on the cleared side, and slow idle breathing. See §3.2a for the full model.
- **Poes spawn only in active fog.** Cleared areas are calm and earned.
- **Placement requires cleared fog** under the player. No stationary requirement.
- **The starting area is pre-cleared** — `pre_clear_circle()` called at the prototype world center on `_ready`, instant, no animation.
- **Noise seed for boundary irregularity is globally consistent** — same seed always produces the same shoreline at a given world position. Do not randomise per-installation.

### 0.4 Architecture Rules — Do Not Break These

- **One script per node.** If a script is handling two concerns, split it.
- **Signals over direct references** between top-level systems wherever practical. All cross-system signal connections are made in `World.gd`, not inside systems.
- **Autoloads are limited to infrastructure.** `GameManager`, `AssetConfig`, and `AssetGenerator` may be autoloaded. No gameplay system is an autoload.
- **No system calls `get_node()` to reach another system.** Use signals or GameManager.
- **Mark prototype seams** with `# PROTOTYPE:` comments anywhere that will need to change when scenes are stitched together — world boundaries, hardcoded sizes, etc.
- **All exported properties are tweakable without recompiling.** Anything that affects feel — radii, durations, speeds, colors, frequencies — must be `@export`. This includes `audio_trigger_threshold`, all fog animation timings, and Poe behavior values.

### 0.5 The FogSystem Is the Hardest Part — Read §3 Carefully

The `FogSystem` + `FogRenderer` is the most novel and most risk-bearing system. Key implementation notes before you start:

- **`FogRenderer` is a swappable class.** `FogSystem` owns a renderer instance and calls it through a small interface: `update(delta)`, `clear_permanent(pos, radius, softness)`, `pre_clear(pos, radius)`, `get_alpha_at(pos)`. This means the rendering approach can be replaced without touching any other system.
- **`_permanent_mask` is never modified by breathing or lantern.** It is the ground truth. Only `clear_permanent()` and `pre_clear()` write to it.
- **`_display_image` is what actually gets pushed to the TextureRect.** It is composited from `_permanent_mask` + active `FogClearanceEvent` states + breathing displacement. Rebuild it only when something has changed.
- **Coordinate mapping:** prototype world space uses top-left origin for fog/image mapping. `image_pixel = (world_pos / world_size) * image_size`. The player starts at world centre `(1024, 1024)` in a `2048×2048` world. The pre-cleared settlement stub is centered on the player start position, not on `(0, 0)`.
- **The HUD CanvasLayer must not be darkened by CanvasModulate.** Place `CanvasModulate` as a direct child of the World scene root. Ensure the HUD CanvasLayer has its own layer index above the fog layer (use layer 10+) and is not affected by the modulate.
- **`fog_cleared_at` signal fires at `audio_trigger_threshold` (0.8) progress** through the clearance animation — not at completion. This makes audio feel causal. Wire this carefully.

### 0.6 Implementation Order

Build and verify each step before moving to the next.

1. **GameManager autoload** — trivial, do this first
2. **AssetConfig autoload** — single constant + `path()` helper
3. **AssetGenerator autoload** — generate all placeholder PNGs to `res://assets/placeholder/`, then idle
4. **World scene + Ground + Camera** — `Sprite2D` ground tile visible, camera tracking a placeholder position
5. **Player** — `Sprite2D` body and lantern sprites loading from AssetConfig; movement working; `PointLight2D` illuminating the dark world through `CanvasModulate`
6. **FogSystem (basic)** — `CanvasModulate` darkening world; `PointLight2D` punching through; pre-cleared starting circle visible in Image mask
7. **FogSystem (waterline)** — clearance animation, boundary noise, fringe, breathing
8. **InstallationManager** — place a lantern post (Sprite2D, unlit → lit swap); watch fog recede with waterline animation
9. **PoeManager** — Poes spawning in fog with correct Sprite2D + AnimationPlayer float loop; drifting toward lantern; collecting
10. **HUD** — Poe counter and installation counter updating
11. **World.gd wiring** — all signals connected, full loop verified end to end

### 0.7 Godot 4 Specific Gotchas

- `PointLight2D` requires the world to use a `CanvasItemMaterial` with the correct blend mode, or the lights will not composite correctly against the `CanvasModulate` darkness. Test this early.
- `Image.set_pixel()` in a tight loop is slow in GDScript. For the 512×512 fog mask, use `Image.set_pixelv()` with `Vector2i` coordinates, and batch all writes before calling `ImageTexture.update(image)` once per frame. If performance is still poor, consider `Image.fill_rect()` for large uniform areas.
- `FastNoiseLite` is built into Godot 4 — use it for boundary irregularity and breathing phase offsets. Do not import an external noise library.
- `CanvasModulate` affects all nodes on the same canvas *including the FogLayer CanvasLayer* unless the CanvasLayer's `follow_viewport` is configured correctly. Test the layer ordering in an empty scene before building on top of it.
- `CharacterBody2D.move_and_slide()` in Godot 4 uses `velocity` directly on the node (not a parameter). Do not pass velocity as an argument.

### 0.9 Asset Pipeline — Read Before Writing Any Visual Node

**Every gameplay-facing visual node is a `Sprite2D` loading a PNG.** Placeholder art is generated once to disk, then loaded normally. Avoid `Polygon2D` and runtime procedural geometry for world visuals. Small debug/UI helpers such as placement indicators may still draw simple primitives.

You will generate placeholder PNGs programmatically via `AssetGenerator.gd` — a one-shot autoload that creates flat-color PNGs at the correct pixel dimensions and saves them to `res://assets/placeholder/` on first run. Every `Sprite2D` in the game loads its texture via `AssetConfig.path("relative/path.png")`. When final PixelLab art is ready, it drops into `res://assets/final/` and a single constant change in `AssetConfig.gd` switches the whole game over.

**Before writing any scene node:** check §1.4 for the full folder structure, pixel specifications, and per-asset dimensions. Build `AssetGenerator.gd` and `AssetConfig.gd` as the first two files after `GameManager.gd`. Do not create any visual node until placeholder PNGs exist on disk for it.

**The `# PROTOTYPE:` comment on every `Sprite2D`** must include the expected final asset path so it is trivially findable when swapping art:
```gdscript
# PROTOTYPE: res://assets/placeholder/poes/common.png
# FINAL: res://assets/final/poes/common.png
$PoeSprite.texture = load(AssetConfig.path("poes/common.png"))
```

The prototype is done when a player can:
1. Move through a dark world with a warm amber lantern glow illuminating the immediate area
2. See Poes drifting in the fog ahead, attracted by the light
3. Press F to place a lantern post in a cleared area
4. Watch the fog recede from the installation with a waterline animation — the boundary breathing, the fringe rolling back, the cleared area settling with a damp-sand edge
5. See Poes collect as they reach the player, incrementing the counter
6. Have a clear sense of what to do next — more fog to push back, more Poes to find

The prototype is intentionally **not** responsible for crafting, agriculture, vendors, multiplayer, biome variation, or dynamic music systems beyond obvious integration seams. Those systems should be stubbed only where they prevent the core loop from compiling cleanly.

If it feels good to play for 10 minutes without instruction, it is done. If it does not, identify the specific moment that breaks the feeling and fix that before declaring completion.

---

## 1. Scene Architecture

### 1.1 Design Principles

- **One script per node.** No script handles two concerns.
- **Signals over direct references.** Systems communicate via signals wherever possible. Direct node references are only used within a system's own scene or when `World.gd` injects a narrow interface explicitly.
- **Only infrastructure helpers are global.** `GameManager`, `AssetConfig`, and `AssetGenerator` are autoloads; all gameplay systems remain scene-local.
- **World visuals are `Sprite2D` assets, not runtime geometry.** Scripts set properties on visual nodes rather than constructing gameplay visuals with `draw_*` or `Polygon2D`. This means swapping placeholder art for final art requires changing one texture property on one node, not touching any script.
- **All placeholder assets are generated PNG files, not procedural geometry.** Claude Code generates placeholder PNGs programmatically at first run via `AssetGenerator.gd` and saves them to `res://assets/placeholder/`. Sprite2D nodes load from these paths. When final art arrives, it mirrors the same folder structure under `res://assets/final/` and a single constant swap in `AssetConfig.gd` redirects the whole game.
- **Prototype seams are explicit.** Anything that will change when scenes are stitched together is marked with a `# PROTOTYPE:` comment. Each `Sprite2D` node's `# PROTOTYPE:` comment includes the expected final asset path.
- **Asset paths are never hardcoded in scripts.** All paths route through `AssetConfig.gd`.

### 1.2 Coordinate Space

- World origin `(0, 0)` is the top-left of the prototype world.
- The player starts at the world centre `(1024, 1024)`.
- The starting cleared area (the settlement stub) is centered on the player start position.
- The prototype world is a fixed 2048 × 2048 pixel space. This is a placeholder — the world size is not final.
- Camera follows the player with a small lag. No hard boundaries in the prototype — the player can walk into fog freely.

### 1.3 Rendering Layers

Layers are assigned explicitly to avoid z-fighting and to ensure the fog overlay sits correctly relative to world content.

| Layer | Content |
|---|---|
| 0 | Ground / terrain (`Sprite2D` using repeatable ground tile texture) |
| 1 | World objects — installations, resource nodes |
| 2 | Poes |
| 3 | Player |
| 4 | Fog overlay (CanvasLayer — rendered above world, below UI) |
| 5 | UI (separate CanvasLayer) |

---

## 1.4 Asset Pipeline

### Folder Structure

```
res://
├── assets/
│   ├── placeholder/               ← generated by AssetGenerator.gd on first run
│   │   ├── player/
│   │   │   ├── idle_down.png      — 16×32, warm cream
│   │   │   ├── idle_up.png
│   │   │   ├── idle_left.png
│   │   │   ├── idle_right.png
│   │   │   └── lantern.png        — 8×12, amber
│   │   ├── poes/
│   │   │   ├── common.png         — 14×14, soft blue-white circle
│   │   │   ├── ember.png          — 14×14, amber
│   │   │   └── wisp.png           — 14×14, pale green
│   │   ├── installations/
│   │   │   ├── lantern_post_unlit.png   — 12×24, dark amber post
│   │   │   └── lantern_post_lit.png     — 12×24, bright amber post
│   │   ├── terrain/
│   │   │   └── ground_tile.png    — 16×16, dark green-grey
│   │   └── ui/
│   │       └── icons.png          — 16×16 spritesheet stubs
│   └── final/                     ← PixelLab art drops here, same structure
│       ├── player/
│       ├── poes/
│       ├── installations/
│       ├── terrain/
│       └── ui/
├── scenes/
├── scripts/
└── ...
```

### AssetConfig.gd (autoload)

A second autoload alongside GameManager. Contains a single constant that controls which asset folder is active:

```gdscript
# AssetConfig.gd
const ASSET_ROOT := "res://assets/placeholder/"
# When final art is ready: const ASSET_ROOT := "res://assets/final/"

static func path(relative: String) -> String:
    return ASSET_ROOT + relative
```

Every `Sprite2D` texture is loaded via `AssetConfig.path(...)`. No asset path appears anywhere else in the codebase.

### AssetGenerator.gd (autoload)

Runs once on first project launch. Checks if `res://assets/placeholder/` exists and is populated. If not, generates all placeholder PNGs programmatically and saves them. After generation it removes itself from the scene — it has no runtime role.

Generated placeholder sprites are **flat color PNGs at correct pixel dimensions with correct pivot points**. They are not procedural geometry drawn at runtime — they are real image files on disk that `Sprite2D` nodes load normally. This means:
- The node structure is identical between placeholder and final art
- Godot's importer processes them like any other sprite
- Frame counts and animation structure are validated against the correct dimensions from day one

### Pixel Specifications

All sprites are designed for **16×16 tile size**, rendered at **3× scale** (48px display tiles). Character sprites are 16×32 (1 tile wide, 2 tiles tall).

| Asset | Dimensions | Frames | Pivot |
|---|---|---|---|
| Player idle (per direction) | 16×32 | 1 | Bottom centre |
| Player walk (per direction) | 16×32 | 4 | Bottom centre |
| Lantern (attached to player) | 8×12 | 1 | Bottom centre |
| Poe (all types) | 14×14 | 3 (float loop) | Centre |
| Lantern post unlit | 12×24 | 1 | Bottom centre |
| Lantern post lit | 12×24 | 2 (subtle pulse) | Bottom centre |
| Ground tile | 16×16 | 1 | Top left |

### Swapping to Final Art

When PixelLab art is ready for a given asset:
1. Export from PixelLab at the correct pixel dimensions listed above
2. Place in the matching path under `res://assets/final/`
3. When all assets for a system are ready, change `ASSET_ROOT` in `AssetConfig.gd`
4. Verify pivot points match — this is the most common issue when swapping
5. No script changes required

**Partial swaps are supported.** If only the Poe art is ready, a per-asset override can be added to `AssetConfig.path()` without changing the global root. This lets final art be integrated incrementally as it's produced.

---

### 2.1 Responsibility

Handles player movement, lantern direction, lantern light output, and placement input. Does not know about fog, Poes, or installations directly — communicates via signals.

### 2.2 Node Structure

```
Player (CharacterBody2D)
├── CollisionShape2D               — capsule, radius 6
├── BodySprite (Sprite2D)          — # PROTOTYPE: res://assets/placeholder/player/idle_down.png
│                                    # FINAL: res://assets/final/player/idle_down.png
│                                    — 16×32, pivot bottom centre, scale 3×
├── LanternSprite (Sprite2D)       — # PROTOTYPE: res://assets/placeholder/player/lantern.png
│                                    # FINAL: res://assets/final/player/lantern.png
│                                    — 8×12, offset in facing direction, rotates with facing
├── LanternLight (PointLight2D)    — primary exploration light source
├── PlacementIndicator (Node2D)    — simple debug/UI helper; may draw an arc in `_draw()`
└── AnimationPlayer                — stub, drives BodySprite frame and LanternSprite visibility
```

### 2.3 Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `speed` | float | 120.0 | Max movement speed in px/s |
| `acceleration` | float | 800.0 | How quickly player reaches max speed |
| `friction` | float | 600.0 | How quickly player decelerates |
| `lantern_radius` | float | 160.0 | PointLight2D texture scale is derived from this |
| `lantern_energy` | float | 1.2 | PointLight2D energy |
| `lantern_color` | Color | Color(1.0, 0.72, 0.25) | Warm amber |

### 2.4 Signals Emitted

| Signal | Arguments | When |
|---|---|---|
| `lantern_position_changed` | `position: Vector2` | Every frame — used by FogSystem and PoeManager |
| `place_installation_requested` | `position: Vector2` | On placement input, with cooldown |

### 2.5 Public Methods

| Method | Arguments | Notes |
|---|---|---|
| `upgrade_lantern(radius, energy)` | float, float | Called by progression system. Updates PointLight2D properties. |

### 2.6 Input Handling

- Movement: `ui_left`, `ui_right`, `ui_up`, `ui_down` (default arrow keys / WASD via remap)
- Placement: `place_installation` (default: F key — see Input Map)

### 2.7 Lantern Light Implementation

`PointLight2D` with a programmatically generated radial gradient texture:
- 128×128 Image, FORMAT_RGBA8
- Warm amber at centre, fully transparent at edge
- Smooth quadratic falloff (`alpha = pow(1 - dist/max_dist, 2)`)
- Blend mode: `ADD` — adds light on top of the world, interacts with CanvasModulate

### 2.8 Facing Direction

- Tracked as a `Vector2`, updated on non-zero movement input
- Default facing: `Vector2.DOWN`
- LanternVisual position and rotation derived from facing each frame
- Facing is still exposed for sprite presentation and placement offset, but FogSystem does not shape the lantern as a cone in the prototype

### 2.9 Constraints & Boundaries

- PROTOTYPE: No world boundary enforcement. Player can exit the 2048×2048 area.
- TODO: Add soft boundary or camera clamp before scene stitching.

---

## 3. System: FogSystem

### 3.1 Responsibility

Owns and manages the fog overlay. Handles both the active (temporary, lantern-driven) fog clearance and permanent (installation-driven) clearance. Persists cleared state for the lifetime of the scene.

### 3.2 Core Architecture Decision — Hybrid Approach

**Decision: CanvasModulate + PointLight2D for real-time feel, Image mask for permanent state. Designed for iteration.**

The fog system is split into two cooperating layers:

**Layer 1 — CanvasModulate (darkness + live lantern)**
A `CanvasModulate` node set to a deep blue-black multiplies the colour of all world content, making everything dark. The player's `PointLight2D` (and Poe glow lights, installation lights) punch through this darkness natively via Godot's 2D light renderer — no per-frame image writing required. This handles the real-time lantern feel at zero extra cost.

**Layer 2 — Image mask (permanent clearance)**
A 512×512 `Image` backed `TextureRect` on a `CanvasLayer` above the world represents the cumulative permanent clearance state. Fogged pixels are opaque; permanently cleared pixels are transparent. This layer is only updated when an installation is placed — not every frame. It is blended over the world *above* the CanvasModulate layer, so cleared areas ignore the darkness entirely.

**Why this split is correct:**
- The lantern's temporary visibility is free (Godot light renderer).
- Permanent clearance is pixel-perfect and easily serialised (Image as PNG).
- The two layers are independently replaceable — if CanvasModulate doesn't feel right, it can be swapped for a fullscreen shader without touching the Image mask, and vice versa.

**Iteration escape hatches — explicitly supported:**

| If this feels wrong | Swap this out for |
|---|---|
| CanvasModulate is too flat / lacks fog texture | Replace with a fullscreen shader sampling a noise texture for fog density variation |
| CanvasModulate darkness is too uniform | Add a second subtle PointLight2D on the player at low energy for ambient fill |
| Boundary noise makes clearance feel chaotic | Reduce `boundary_noise_amplitude` — or switch to a smoother noise type (domain-warped) |
| Breathing oscillation is too noticeable | Halve `breath_amplitude` first; if still wrong, gate breathing to only occur when player is stationary |
| Damp sand darkening reads as a visual glitch | Reduce `damp_sand_opacity` toward 0 — the effect is additive and can be disabled entirely |
| Image mask performance is insufficient | Move compositing to a shader: pass `_permanent_mask` as a uniform, compute boundary noise in GPU |
| The whole hybrid feels wrong | FogSystem exposes `set_renderer(renderer: FogRenderer)` — swap implementations without changing any other system |

**The renderer interface pattern** is how iteration is kept clean. `FogSystem` does not implement fog rendering directly — it owns a `FogRenderer` object that does. In the prototype this is `HybridFogRenderer`. If a full shader approach is needed, it becomes `ShaderFogRenderer`. The interface surface is small: `update(lantern_pos, permanent_mask)` and `clear_permanent(pos, radius, softness)`. All other systems interact only with `FogSystem`, never with the renderer directly.

### 3.2a Fog Border Behaviour — The Waterline Model

**Mental model: the fog is a body of water. Cleared land is a beach. The boundary between them is a shoreline.**

This reframes everything about how the fog boundary looks and behaves:

- The boundary is never a perfect geometric edge — it is a soft, irregular, living shoreline.
- Cleared land has a residual quality near the boundary, like damp sand darker than dry sand.
- The fog side has a luminous quality at its shallowest edge, like water catching light.
- The boundary breathes — a slow, subtle oscillation that never fully stills.
- When fog recedes, it pulls back like a tide going out, not like a curtain being drawn.

---

**Clearance animation — the tide going out:**

When `clear_fog_permanent()` is called, a `FogClearanceEvent` is created and animated over `clearance_duration` seconds:

1. The clearance radius grows outward from the installation point using `ease_out_cubic` — fast initial recession, slowing to stillness as it reaches `target_radius`. The fog rushes back from the new light source, then settles.
2. The boundary edge is **not a clean circle**. At each point on the boundary, the radius is offset by a noise sample: `actual_radius = current_radius + noise.sample(angle) * boundary_noise_amplitude`. This gives the shoreline its organic, non-geometric character. Use a 1D noise sample over angle (0–TAU) with a low frequency so the irregularity is large-scale and gentle, not jittery.
3. The leading edge of recession — the equivalent of the waterline — renders as a soft luminous fringe: a band of warm blue-white Color(0.75, 0.82, 0.95, 0.35) just ahead of the clearance front. This is the foam at the wave's edge. It moves with the boundary and fades to nothing as the clearance settles.
4. Just behind the fringe, on the newly cleared side, a residual damp-sand layer renders briefly: a slightly darker, slightly desaturated version of the cleared ground colour, fading out over 0.8 seconds after the boundary passes. This is the wet sand left behind by the receding tide.
5. Once animation completes, the final boundary retains its noise-offset irregularity permanently — the shoreline is not smoothed out when it settles.

---

**Idle fog breathing — the tide that never fully stills:**

Even with no clearance events active, the fog boundary oscillates. This is implemented as a time-driven noise displacement applied to the boundary of the permanent mask when rendering:

- Each pixel on or near the boundary has its opacity slightly modulated by `sin(time * breath_frequency + noise_offset) * breath_amplitude`.
- `breath_frequency` = 0.18 Hz (one breath every ~5.5 seconds — very slow).
- `breath_amplitude` = 3–5 pixels in image space — barely perceptible as movement, felt as aliveness.
- The noise offset per boundary pixel ensures adjacent points are slightly out of phase — the boundary doesn't heave as one uniform mass, it ripples.
- The breathing never encroaches on cleared space in the permanent mask — it is a display-only modulation applied on top of the settled state.

**Important:** The breathing should be noticed only in peripheral vision or on a still screen. If the player is moving and exploring, it should be subliminal. If the player stops and watches the fog, they should see it. Tune amplitude conservatively — it is easier to add more than to remove it after players have noticed it.

---

**Settled boundary — the damp sand:**

After a clearance event completes, the boundary zone (approximately `boundary_noise_amplitude * 2` pixels wide on the cleared side) retains a subtle permanent darkening — Color(0.0, 0.0, 0.0, 0.08) blended over the cleared area near the boundary. This is the damp sand that doesn't fully dry. It gives cleared areas a sense of having a coast rather than a cut edge, and makes the boundary feel like it has physical history.

This is rendered as part of the permanent mask — a soft gradient written once when the clearance event completes, not recalculated each frame.

---

**Properties updated for waterline model:**

| Property | Type | Default | Notes |
|---|---|---|---|
| `clearance_duration` | float | 1.2 | Seconds for tide-out animation |
| `clearance_ease` | String | "ease_out_cubic" | Easing function for radius growth |
| `boundary_noise_amplitude` | float | 8.0 | Max pixel offset for shoreline irregularity in image space |
| `boundary_noise_frequency` | float | 3.0 | Spatial frequency of shoreline noise — lower = bigger waves |
| `fringe_width` | float | 10.0 | Width of waterline fringe band in image pixels |
| `fringe_color` | Color | Color(0.75, 0.82, 0.95, 0.35) | Cool blue-white — foam at the wave's edge |
| `damp_sand_width` | float | 6.0 | Width of residual darkening on cleared side of boundary |
| `damp_sand_opacity` | float | 0.08 | Alpha of permanent boundary darkening |
| `breath_frequency` | float | 0.18 | Hz of idle fog oscillation |
| `breath_amplitude` | float | 4.0 | Max pixel displacement of breathing in image space |
| `audio_trigger_threshold` | float | 0.8 | Fraction of clearance duration at which fog_cleared_at emits |

**Musical hook:** `fog_cleared_at` emits at `audio_trigger_threshold` progress — just before the tide fully settles. The arpeggio arrives as the waterline is still moving, making it feel like the sound is part of the recession, not a reaction to it.

### 3.3 Node Structure

```
FogSystem (Node2D)                    ← fog_system.gd — owns renderer, exposes public API
├── CanvasModulate                    — Color(0.05, 0.06, 0.12, 1.0): darkens all world content
└── FogLayer (CanvasLayer)            — layer index 4, above world, below UI
    └── FogRect (TextureRect)         — 512×512 Image mask, scaled to world size
```

**CanvasModulate note:** Must be a child of the World scene root, not FogSystem, to correctly affect all world content. FogSystem owns a reference to it but does not parent it. The HUD CanvasLayer must have `follow_viewport` disabled and its own modulate set to white to prevent darkening.

**FogRenderer (inner class / separate script):**
```
FogRenderer                           ← fog_renderer.gd — swappable implementation
├── _permanent_mask: Image            — 512×512, ground truth of permanent clearance
├── _display_image: Image             — 512×512, composited each frame during animations
└── _active_events: Array             — FogClearanceEvent objects currently animating
```

### 3.4 Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `world_size` | Vector2i | Vector2i(2048, 2048) | Must match world coordinate space |
| `image_size` | Vector2i | Vector2i(512, 512) | Fog mask resolution |
| `fog_modulate_color` | Color | Color(0.05, 0.06, 0.12, 1.0) | CanvasModulate colour — base darkness |
| `lantern_clear_radius` | float | 140.0 | Radius of temporary lantern visibility in world px |
| `lantern_clear_softness` | float | 40.0 | Feather width at the temporary lantern light edge |
| `install_clear_radius` | float | 200.0 | Target radius of permanent clearance in world px |
| `install_clear_softness` | float | 60.0 | Feather on settled permanent clearance edge |
| `clearance_duration` | float | 1.2 | Seconds for tide-out animation |
| `clearance_ease` | String | "ease_out_cubic" | Easing applied to radius growth |
| `boundary_noise_amplitude` | float | 8.0 | Max shoreline irregularity in image pixels |
| `boundary_noise_frequency` | float | 3.0 | Spatial frequency of shoreline noise |
| `fringe_width` | float | 10.0 | Waterline fringe band width in image pixels |
| `fringe_color` | Color | Color(0.75, 0.82, 0.95, 0.35) | Cool blue-white — foam at wave's edge |
| `damp_sand_width` | float | 6.0 | Residual darkening width on cleared side |
| `damp_sand_opacity` | float | 0.08 | Alpha of permanent boundary darkening |
| `breath_frequency` | float | 0.18 | Hz of idle fog boundary oscillation |
| `breath_amplitude` | float | 4.0 | Max pixel displacement of breathing |
| `audio_trigger_threshold` | float | 0.8 | Fraction of clearance duration at which fog_cleared_at emits |

### 3.5 Signals Emitted

| Signal | Arguments | When |
|---|---|---|
| `fog_cleared_at` | `position: Vector2` | At `audio_trigger_threshold` fraction of clearance animation — hooks audio system |
| `fog_clearance_completed` | `position: Vector2` | When border animation fully settles — hooks any post-clearance gameplay events |
| `fog_clearance_started` | `position: Vector2, radius: float` | Immediately on installation placement — hooks UI feedback |

### 3.6 Public Methods

| Method | Arguments | Notes |
|---|---|---|
| `clear_fog_permanent(world_pos, radius, softness)` | Vector2, float, float | Initiates a FogClearanceEvent — does not write immediately |
| `get_fog_alpha_at(world_pos)` | Vector2 → float | Reads from `_permanent_mask` (not display image) — used by PoeManager |
| `is_position_cleared(world_pos)` | Vector2 → bool | True if permanent mask alpha < 0.1 at position |
| `set_renderer(renderer)` | FogRenderer | Swaps the fog rendering implementation — for experimentation |
| `pre_clear_circle(world_pos, radius)` | Vector2, float | Instantly clears a circle with no animation — used for starting area only |

### 3.7 Frame Update Behaviour

Each frame in `_process`, the renderer does:

1. **Check for active clearance events.** If any `FogClearanceEvent` is animating, advance each event's `current_radius` by delta using the easing curve. For each event, compute the noise-offset boundary at the current radius and write the animated fringe + clearance to `_display_image`. Composite all active events and the permanent mask together. Push to TextureRect. Emit threshold signals.

2. **Apply idle breathing.** Regardless of active events, the boundary of `_permanent_mask` is displaced by the breathing oscillation for the current frame. This is a display-only operation — `_permanent_mask` itself is never modified by breathing. The displacement is computed per boundary pixel: `display_alpha = permanent_alpha + sin(time * breath_frequency + per_pixel_phase) * breath_amplitude_normalised`.

3. **If no active events and no breathing change since last frame:** skip Image rebuild. This requires tracking whether the breathing displacement has meaningfully changed — a simple time-threshold check (e.g. only rebuild if `fmod(time, 0.05) < delta`) reduces rebuilds to ~20fps for the breathing layer, which is imperceptible.

4. **CanvasModulate + PointLight2D** require no management — Godot handles them.

**Rebuild frequency summary:**
- During clearance animation: every frame for event duration
- Idle breathing: ~20fps (time-gated rebuilds)
- Fully settled with no events: 0 rebuilds per frame

### 3.8 Coordinate Mapping

World coordinates must be mapped to fog Image pixel coordinates:

```
image_pixel = (world_pos / world_size) * image_size
```

The fog Image origin (0,0) corresponds to world position (0,0) — the top-left of the world space. Ensure the player start position is correctly offset.

### 3.9 Serialisation Stub

`get_save_state()` returns the `_permanent_mask` Image as a PNG byte array. `load_save_state(data)` restores it. Not wired in the prototype but the interface should be present.

---

## 4. System: PoeManager

### 4.1 Responsibility

Spawns, updates, and despawns Poe entities. Manages attraction behaviour toward the player's lantern. Reports collections to GameManager.

### 4.2 Node Structure

```
PoeManager (Node2D)
├── SpawnTimer (Timer)       — fires spawn attempts at interval
└── [Poe instances]          — added/removed as children at runtime
```

Each Poe is its own scene instance:

```
Poe (Area2D)
├── CollisionShape2D               — small circle, radius 8
├── PoeSprite (Sprite2D)           — # PROTOTYPE: res://assets/placeholder/poes/common.png
│                                    # FINAL: res://assets/final/poes/common.png
│                                    — 14×14, pivot centre, scale 3×
│                                    — texture swapped to ember.png or wisp.png by type
├── GlowLight (PointLight2D)       — very small, matches Poe colour, energy 0.4, radius 40px
└── AnimationPlayer                — drives PoeSprite float loop (3 frames)
```

### 4.3 PoeManager Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `max_poes` | int | 12 | Maximum simultaneously active Poes |
| `spawn_interval` | float | 3.0 | Seconds between spawn attempts |
| `spawn_radius_min` | float | 180.0 | Minimum distance from player to spawn |
| `spawn_radius_max` | float | 400.0 | Maximum distance from player to spawn |
| `spawn_in_fog_only` | bool | true | Poes only spawn in uncleared fog |

### 4.4 Poe Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `poe_type` | String | "common" | Determines colour and rarity. Types: "common", "ember", "wisp". Extend later. |
| `attraction_radius` | float | 180.0 | Distance at which Poe detects the lantern |
| `move_speed` | float | 40.0 | Movement speed when attracted |
| `wander_speed` | float | 12.0 | Movement speed when idle wandering |
| `collect_radius` | float | 16.0 | Distance at which Poe is collected by player |
| `color` | Color | varies by type | Common = blue-white, Ember = amber, Wisp = pale green |

### 4.5 Poe Behaviour State Machine

```
WANDERING
  → if lantern within attraction_radius: → ATTRACTED
  → if no lantern nearby: continue wandering (random walk)

ATTRACTED
  → move toward player position each frame
  → if distance < collect_radius: → COLLECTED
  → if lantern moves out of (attraction_radius * 1.5): → WANDERING
    (hysteresis prevents jitter at the boundary)

COLLECTED
  → play collect animation (scale to 0, prototype: just free())
  → call GameManager.collect_poe()
  → remove from scene
```

### 4.6 Signals Emitted (Poe)

| Signal | Arguments | When |
|---|---|---|
| `collected` | `poe_type: String` | On collection, before freeing |

### 4.7 Spawn Logic

On each `SpawnTimer` timeout:
1. Check if current Poe count < `max_poes`.
2. Generate a candidate position at a random angle and distance from the player, within `[spawn_radius_min, spawn_radius_max]`.
3. Check `FogSystem.get_fog_alpha_at(candidate_pos)` — only spawn if fog is present (`spawn_in_fog_only`).
4. Assign a type using weighted random: common 70%, ember 20%, wisp 10%.
5. Instance the Poe scene, set its type/color, add as child.

### 4.8 Poe Visual

Loaded from `AssetConfig.path("poes/{type}.png")` where type is "common", "ember", or "wisp".

Placeholder PNGs (generated by AssetGenerator):
- 14×14px, soft circle shape on transparent background
- Common = Color(0.7, 0.85, 1.0), Ember = Color(1.0, 0.65, 0.2), Wisp = Color(0.6, 1.0, 0.7)
- 3 frames arranged horizontally for float loop animation — slight vertical offset per frame
- GlowLight color set in script to match type color; energy 0.4

Idle bob is handled by AnimationPlayer cycling the 3-frame float loop, not by script position manipulation.

---

## 5. System: InstallationManager

### 5.1 Responsibility

Listens for placement requests from the Player. Validates placement. Spawns Installation nodes. Instructs FogSystem to permanently clear fog at the placement point. Reports to GameManager.

### 5.2 Node Structure

```
InstallationManager (Node2D)
└── [Installation instances]    — added as children at runtime
```

Each Installation is its own scene:

```
Installation (StaticBody2D)
├── CollisionShape2D               — small circle, radius 10
├── PostSprite (Sprite2D)          — # PROTOTYPE: res://assets/placeholder/installations/lantern_post_unlit.png
│                                    # FINAL: res://assets/final/installations/lantern_post_unlit.png
│                                    — 12×24, pivot bottom centre, scale 3×
│                                    — texture swapped to lantern_post_lit.png after placement animation
├── LightSource (PointLight2D)     — permanent warm glow, energy starts at 0, tweens to 0.9
└── AnimationPlayer                — drives pop-in scale tween and lit/unlit texture swap
```

### 5.3 InstallationManager Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `placement_cost_poes` | int | 0 | Prototype: free placement. Wire to GameManager.poes_collected later. |
| `min_spacing` | float | 80.0 | Minimum distance between two installations |
| `clear_radius` | float | 200.0 | Passed to FogSystem on placement |
| `clear_softness` | float | 60.0 | Passed to FogSystem on placement |

### 5.4 Installation Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `installation_type` | String | "lantern_post" | Extend for beacon, carved_stone etc. |
| `light_radius` | float | 200.0 | PointLight2D texture scale derived from this |
| `light_energy` | float | 0.9 | Softer and steadier than player lantern |
| `light_color` | Color | Color(1.0, 0.85, 0.45) | Slightly cooler gold than player lantern |

### 5.5 Placement Validation

On receiving `place_installation_requested` from Player:
1. Check that the placement position is within a cleared fog area (`FogSystem.is_position_cleared()`). Placement is only allowed in cleared space.
2. Check that no existing installation is within `min_spacing` of the placement position.
3. If validation passes: emit a success signal or call an injected interface provided by `World.gd`; `World.gd` is responsible for forwarding the placement to `FogSystem` and `GameManager`.
4. If validation fails: emit a failure signal for UI feedback (no placement, no cost).

### 5.6 Signals Emitted

| Signal | Arguments | When |
|---|---|---|
| `installation_placed` | `position: Vector2, type: String` | On successful placement |
| `placement_failed` | `reason: String` | On failed validation |
| `installation_clear_requested` | `position: Vector2, radius: float, softness: float` | When placement succeeds and fog should recede |

### 5.7 Installation Visual

Loaded from `AssetConfig.path("installations/lantern_post_{state}.png")` where state is "unlit" or "lit".

Placeholder PNGs (generated by AssetGenerator):
- 12×24px, pivot bottom centre, scale 3×
- Unlit: thin dark amber rectangle (post) topped with a small circle (housing) — Color(0.45, 0.32, 0.12)
- Lit: same shape, brighter amber, with a soft glow halo baked into the sprite — Color(0.95, 0.75, 0.3)
- Lit version has 2 frames for a subtle pulse (slight brightness variation)

On placement: AnimationPlayer tweens PostSprite scale from Vector2(0,0) to Vector2(1,1) over 0.3s, then swaps texture to lit version and tweens LightSource energy from 0 to 0.9 over 0.5s.

---

## 6. System: GameManager

### 6.1 Responsibility

Singleton autoload. Tracks cross-scene state. Provides a stable interface for all other systems. Does not contain gameplay logic — only state and signals.

### 6.2 Autoload Setup

Register as autoload in Project Settings:
- Name: `GameManager`
- Path: `res://scripts/GameManager.gd`

### 6.3 State

| Variable | Type | Notes |
|---|---|---|
| `poes_collected` | int | Incremented by `collect_poe()` |
| `installations_placed` | int | Incremented by `place_installation()` |
| `cleared_fog_regions` | Array[Dictionary] | Each entry: `{position: Vector2, radius: float}` — for save/load |

### 6.4 Signals

| Signal | Arguments | When |
|---|---|---|
| `poe_collected` | `total: int` | After each collection |
| `installation_placed` | `total: int` | After each placement |
| `fog_cleared` | `position: Vector2` | After permanent fog clearance |

### 6.5 Public Methods

| Method | Notes |
|---|---|
| `collect_poe(type: String)` | Increments counter, emits signal |
| `place_installation(pos: Vector2)` | Increments counter, records region, emits signals |
| `get_save_state() → Dictionary` | Returns full state dict — stub in prototype |
| `load_save_state(data: Dictionary)` | Restores state — stub in prototype |

---

## 7. Inter-system Communication

### 7.1 Signal Flow Diagram

```
Player
  │── lantern_position_changed ──► FogSystem (caches lantern pos for frame update)
  │── lantern_position_changed ──► PoeManager (Poes check distance to this)
  └── place_installation_requested ──► InstallationManager

InstallationManager
  │── installation_clear_requested ──► World.gd ──► FogSystem.clear_fog_permanent()
  │── installation_placed ──► World.gd ──► GameManager.place_installation()
  └── installation_placed ──► HUD (future)

PoeManager / Poe
  │── (calls) GameManager.collect_poe()
  └── collected ──► HUD (future)

GameManager
  │── poe_collected ──► HUD (future)
  └── installation_placed ──► HUD (future)
```

### 7.2 Wiring Location

All signal connections between top-level systems are made in the **main scene script** (`World.gd`), not inside the systems themselves. This keeps systems decoupled — they don't hold references to each other.

```gdscript
# World.gd — connection example
player.lantern_position_changed.connect(fog_system._on_lantern_moved)
player.lantern_position_changed.connect(poe_manager._on_lantern_moved)
player.place_installation_requested.connect(installation_manager._on_place_requested)
```

### 7.3 Direct References (Exceptions)

The following direct `get_node` references are acceptable within a system's own scene:
- Player accessing its own child nodes (LanternLight, BodyVisual, etc.)
- PoeManager accessing Poe child instances it spawned
- InstallationManager accessing Installation child instances it spawned

No system should call `get_node` to reach another top-level system. Use signals or GameManager.

---

## 8. Input Map

Define these actions in Project Settings → Input Map before writing any scripts:

| Action | Default Key | Notes |
|---|---|---|
| `ui_left` | Arrow Left / A | Built-in, remap to WASD |
| `ui_right` | Arrow Right / D | Built-in |
| `ui_up` | Arrow Up / W | Built-in |
| `ui_down` | Arrow Down / S | Built-in |
| `place_installation` | F | Primary placement action |
| `interact` | E | Stub — for vendor interaction in future scenes |
| `open_inventory` | Tab | Stub — for crafting system in future scenes |
| `debug_clear_fog` | ` (backtick) | Debug only — calls FogSystem.clear_all() |

---

## 9. Scene Tree Layout

```
World (Node2D)                        ← world.gd — wires all signals, owns scene lifecycle
├── CanvasModulate                     — Color(0.05, 0.06, 0.12, 1.0) — darkens world content
├── GameManager                        ← autoload
├── AssetConfig                        ← autoload — single ASSET_ROOT constant + path() helper
├── AssetGenerator                     ← autoload — generates placeholder PNGs on first run, then idles
├── Ground (Sprite2D)                  ← tiled ground_tile.png, TextureRepeat enabled
├── TerrainObjects (Node2D)            ← placeholder static sprites: rocks, stumps
├── InstallationManager (Node2D)       ← installation_manager.gd
├── PoeManager (Node2D)                ← poe_manager.gd
│   └── SpawnTimer (Timer)
├── Player (CharacterBody2D)           ← player.gd
│   ├── CollisionShape2D
│   ├── BodySprite (Sprite2D)
│   ├── LanternSprite (Sprite2D)
│   ├── LanternLight (PointLight2D)
│   ├── PlacementIndicator (Node2D)    ← draws arc via _draw(), not a sprite
│   └── AnimationPlayer
├── FogSystem (Node2D)                 ← fog_system.gd
│   └── FogLayer (CanvasLayer)         — layer index 4
│       └── FogRect (TextureRect)
├── HUD (CanvasLayer)                  ← hud.gd — layer index 10, unaffected by CanvasModulate
│   ├── PoeCounter (Label)
│   └── InstallationCounter (Label)
└── Camera2D                           ← follows player with smoothing
```

---

## 10. Resolved Decisions & Remaining Questions

### 10.1 Resolved

| # | Question | Decision |
|---|---|---|
| 1 | Fog Image resolution | 512×512 — increase to 1024×1024 only if edge quality is noticeably poor |
| 2 | Lantern permanence | Installation-only. Lantern is always temporary. |
| 3 | Poe spawn location | Fog-only at base rate. Cleared areas are calm. |
| 4 | Placement cooldown | 0.5 seconds |
| 5 | Placement requirement | Within cleared fog only. No stationary requirement. |
| 6 | Starting area | Pre-cleared circle, radius ~120px at world centre, instant (no animation) |
| 7 | Fog rendering approach | Hybrid: CanvasModulate + PointLight2D for real-time darkness/lantern; Image mask for permanent clearance only. Swappable via FogRenderer interface. |

### 10.2 Open

| # | Question | Impact | Notes |
|---|---|---|---|
| 8 | Does the settled boundary leave a faint permanent residual glow on the fog side, like shallow water catching light? | Boundary richness | Nice-to-have only. Defer if it complicates the first playable. |
| 9 | Should the CanvasModulate value vary per biome (warmer dark in Mosshallow, colder in Ashfields)? | Biome atmosphere | Not in prototype — but `set_ambient_dark(color)` method should be stubbed on FogSystem. |
| 10 | What happens when two clearance circles' shorelines collide during animation? | Edge case feel | They should composite naturally. If the noise offsets produce an odd merged shape, consider smoothing the union boundary. Verify in prototype. |
| 11 | Is `audio_trigger_threshold` of 0.8 correct? | Audio/visual sync | Keep exported, but audio implementation is deferred beyond the first playable. |
| 12 | Does the breathing oscillation need to vary in speed across the boundary (faster in some patches, slower in others) for a more natural water feel? | Realism of breathing | Start with uniform frequency — add variation only if it reads as mechanical. |
| 13 | Should the noise used for boundary irregularity be seeded per-installation or globally consistent? | World coherence | Global seed means the shoreline shape at a given world position is always the same, which makes revisiting feel consistent. Recommended. |

---

*Lanternfall Prototype Spec v0.5 — Asset pipeline added. §0.9 and §1.4 cover the full asset strategy. All visual nodes are Sprite2D loading from AssetConfig.*
