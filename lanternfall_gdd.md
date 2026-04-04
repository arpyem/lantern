# Game Design Document — Lanternfall

**Version:** 0.5 (Aligned with Prototype Spec)
**Status:** Early Development
**Last Updated:** 2026-04-03

> *Previously titled "Drift & Weave." Renamed to better reflect the revised core concept.*

---

## Table of Contents

1. [Concept](#1-concept)
2. [Gameplay Overview](#2-gameplay-overview)
3. [World & Setting](#3-world--setting)
4. [Exploration & The Fog](#4-exploration--the-fog)
5. [Progression Systems](#5-progression-systems)
6. [Gathering & Crafting](#6-gathering--crafting)
7. [Settlement Building](#7-settlement-building)
8. [The Poe Economy — Ghostly Companions](#8-the-poe-economy--ghostly-companions)
9. [Biomes](#9-biomes)
10. [Music & Audio](#10-music--audio)
11. [Multiplayer & Social](#11-multiplayer--social)
12. [Art Direction](#12-art-direction)
13. [Art Production](#13-art-production)
14. [UI & UX](#14-ui--ux)
15. [Technical Requirements](#15-technical-requirements)
16. [Monetization](#16-monetization)
17. [Scope & Milestones](#17-scope--milestones)

---

## 1. Concept

### 1.1 Elevator Pitch

*"A mysterious world lies hidden in a living darkness. You carry the light."*

Lanternfall is a cozy exploration and settlement game set in a world shrouded in fog. Armed with a handheld lantern, the player pushes back the darkness — gathering resources, installing permanent lights, growing luminous plants, and building a settlement that itself becomes a beacon. The world rewards those who illuminate it: fog recedes to reveal new biomes, hidden paths, and long-buried secrets. Ghostly companions (Poes) are drawn to your light and act as a social currency attracting vendors and unlocking community growth. The darkness is not hostile — it is patient, and full of things waiting to be found.

### 1.2 Core Fantasy

You are an explorer and a builder, but above all you are a bringer of light. Every action — placing a lantern post, planting a glowing crop, clearing a fog pocket — makes the world more knowable and more beautiful. The game rewards curiosity: returning to an old area with a new tool or new knowledge reveals something that was always there, just waiting. The world feels like it has a secret it is slowly letting you in on.

### 1.3 Tone

**Grounded fantasy.** The world is mysterious but not threatening. The darkness is eerie but cozy — more like a foggy autumn morning than a horror game's night. Organic agriculture sits alongside light-magic; scientific curiosity blends with something older and stranger. The fantastical elements are present but understated.

The aesthetic sits at the intersection of two specific references:

**Animal Crossing** provides the domestic register — the unhurried daily rhythm, the pleasure of small rituals, the sense that the settlement is *yours* rather than a base. Vendors are neighbours with personality and memory, not service menus. The world is patient; it will be there when you come back. There is no urgency, only invitation.

**Zelda: BOTW / TOTK** provides the visual and material language — specifically the Sheikah and Zonai aesthetic of technology grown as much as built. Ancient stone wrapped in living circuitry. Wooden structures threaded with glowing amber veins. Devices that look simultaneously discovered and invented. The merger of the organic and the mechanical is not steampunk — it is quieter and stranger than that, more like something a civilisation grew from the ground up and then left behind.

Where these two references fuse for Lanternfall: the lantern is a Zonai device — amber glass held in root-like metalwork, warm and slightly alive-feeling. Permanent installations look like ruins the player is *reactivating* rather than structures they are building from scratch. The settlement grows the way Tarrey Town does — incrementally, with personality, each arrival changing the feel of the place. The fog has the volumetric physicality of TOTK's gloom but rendered warm rather than threatening.

### 1.4 Design Pillars

| Pillar | Description |
|---|---|
| **Light as progress** | Illumination is the primary mechanic and metaphor. Clearing fog is exploration, progression, and world-building simultaneously. |
| **The world remembers** | Permanent installations stay lit. Plants keep growing. The fog does not return. Every session leaves a visible mark. |
| **Revisit rewards** | New tools and biome knowledge make old areas yield new things. The player always has a reason to go back. |
| **Musical world** | Every interaction produces musical feedback that harmonises with the ambient soundscape. The world is an instrument the player is slowly tuning. |
| **Cozy stakes** | Nothing is lost through failure or experimentation. The world is mysterious in its darkness, not punishing. |

### 1.5 Player Profile

The target player is a **horizon chaser** — motivated by perpetual progression and the promise of what's next. The fog mechanic gives the horizon a spatial dimension: the next goal is not just a new recipe but a new piece of the world made visible. This player also responds to environmental storytelling, systems that reward revisiting, and a world that feels genuinely reactive to their actions.

### 1.6 Spiritual Ancestors

**Primary references — these define the game's identity:**
- **Animal Crossing (series)** — domestic rhythm, vendor-as-neighbour, settlement as home, unhurried pacing, the world waiting patiently for you
- **Zelda: Tears of the Kingdom / Breath of the Wild** — Zonai/Sheikah aesthetic (organic-meets-technology), open exploration, environmental reactivity, Poe companions, volumetric fog (gloom), the sense that the world has a deep geological and civilisational history

**Secondary references — tone, systems, and feel:**
- **Outer Wilds** — a world full of secrets that rewards attention and revisiting
- **Spiritfarer** — warmth, building as care, emotional texture in a fantastical world
- **Stardew Valley** — seasonal rhythm, vendor relationships, the satisfaction of a growing farm
- **Journey** — ambient co-presence, musical world, wordless wonder
- **Tunic** — mystery as mechanic, curiosity as the core skill

---

## 2. Gameplay Overview

### 2.1 The Core Loop

1. **Venture out** with your handheld lantern — light temporarily reveals a cone of the fogged world ahead
2. **Gather** resources exposed by the light — organic materials, minerals, fog-crystals, buried objects
3. **Encounter** Poes drawn to your lantern — collect them as you explore
4. **Install** a permanent light source — lantern post, luminous plant, carved beacon — holding the fog back for good
5. **Return** to your settlement — craft, upgrade tools, trade with vendors using gathered materials and Poes
6. **Unlock** a new tool, biome access, or installation type — the horizon shifts outward
7. **Revisit** an old area with new knowledge or a new tool — find something that was always there, now reachable

### 2.2 Session Feel

A session feels like a gentle expedition followed by a satisfying return. The player leaves the warmth of their settlement, pushes into the dark a little further than before, fills their pockets, and comes home to build something that makes the world a little brighter. Each session ends with a visible, permanent change to the world.

### 2.3 Win Conditions & Failure States

There is no fail state. The fog does not fight back. Resources are not permanently depleted. The player can always return to settlement safely.

Long-term success is self-defined: a fully lit region, a thriving settlement, a complete vendor roster, all biomes discovered, all Poe types collected. None are mandatory; all are satisfying.

> **[PLACEHOLDER]** Define any optional challenge or self-imposed difficulty systems for players who want stakes.

### 2.4 Controls & Input

For the **first playable prototype**, controls are deliberately narrow:

- Movement: keyboard movement (`WASD` / arrow keys)
- Placement: single key (`F`) to place the current installation type
- Lantern aiming: tied to facing / movement direction for the prototype

Mouse aiming, controller support, gathering interactions, and crafting input should be deferred until the core exploration loop feels good. The prototype's job is to validate movement, temporary visibility, permanent fog clearance, and Poe attraction with the least possible input complexity.

---

## 3. World & Setting

### 3.1 The World

The world of Lanternfall is ancient, quiet, and mostly dark. It was not always this way — ruins of old settlements, overgrown infrastructure, and half-buried machinery suggest a civilisation that once lit this place and then, for reasons the player slowly uncovers, went dark. The fog is not malevolent; it is more like a slow tide that came in when the lights went out.

The visual language of the world draws directly from TOTK's Zonai aesthetic: stone structures threaded with glowing amber circuitry, wooden frameworks grown around ancient devices, organic forms that are simultaneously natural and engineered. The lost civilisation did not build with steel and glass — they grew their technology from the land, and what remains looks like something between a ruin and a root system. The player's lantern taps into this same tradition, and the installations they place feel like they belong to it.

The world is grounded fantasy. Materials are organic and mineral; processes are agricultural and artisanal. But something older runs underneath — a light-magic that predates the lost civilisation, which the player's lantern accesses without fully understanding.

### 3.2 The Settlement

The settlement is the player's home in the Animal Crossing sense — not a base or a hub but a *place*, with its own personality that accumulates over time. It begins as a single lit clearing: a workbench, a crop plot, one vendor stall. As the player clears fog, gathers materials, and attracts Poes, more arrives. New vendors come and settle, each one changing the texture of the place. Structures go up that the player chose and placed. The settlement becomes a warm centre the world slowly fills in around — and because every vendor is a character with memory and routine, returning to it after an expedition feels like coming home.

Visually the settlement should echo Tarrey Town's incremental warmth — each addition is legible as a contribution, the whole thing feeling handmade rather than generated. Structures use the same organic-technology language as the wider world: timber frames with glowing inlaid veins, lanterns that are also plants, workbenches that look grown as much as built.

### 3.3 Lore & Narrative

> **[PLACEHOLDER]** The world has a history the player uncovers through environmental storytelling — found objects, ruined infrastructure, the things Poes seem to remember. Define the lore arc: what happened to the light? What are the Poes? What is the fog, really? Answers should be ambient and optional — the game is complete without them, richer with them.

---

## 4. Exploration & The Fog

### 4.1 The Handheld Lantern

The lantern is the player's primary tool and the game's most important object. It projects a cone of light that temporarily reveals the fogged world ahead — terrain, resources, hidden objects, Poes, points of interest. Without it, the world is dark. With it, the world slowly becomes known.

Aesthetically the lantern is a Zonai device — amber glass set in root-like metalwork that looks grown rather than forged, warm and slightly alive. Early lanterns are small and intimate; later upgrades feel more powerful but maintain the same organic character, as if the lantern has been trained rather than engineered. The light it casts is warm amber — distinct from the cooler blue-white of the fog, and from the steadier golden glow of permanent installations.

The lantern is the central upgrade path. Early versions cast a small warm cone. Later versions can be wider, brighter, longer-range, or tuned to specific frequencies that reveal things invisible to a standard lantern — unlocking new layers of what was always there.

### 4.2 Fog Behaviour

The fog is not flat or uniform — it has texture, varying density across regions, and a living boundary. The mental model for the fog boundary is **a waterline**: cleared land is a beach, active fog is water, and the edge between them is a shoreline that breathes, ripples, and recedes like a tide when light pushes it back.

The boundary is never a perfect geometric circle. It has noise-offset irregularity (organic shoreline character), a soft luminous fringe at the receding edge during clearance (foam at the wave's edge), a residual damp-sand darkening on the newly cleared side, and a slow idle oscillation when nothing is clearing — the tide that never fully stills.

Fog clearance is permanent. Once an area is lit by a permanent installation, it stays lit and the shoreline settles into its new position. The player's progress is always visible in the landscape — not as a hard-edged circle but as a coastline they have personally shaped.

> **[PLACEHOLDER]** Define fog density tiers — does thicker fog require a more powerful lantern to penetrate, acting as a natural progression gate into later biomes?

### 4.3 Permanent Light Installations

Installing a permanent light source is one of the most satisfying actions in the game. Critically, installations should not feel like things the player is imposing on the world — they should feel like things the player is *restoring* or *constructing*, depending on context. Restored installations are half-buried structures the player uncovers and reactivates; constructed installations are new additions built in the vocabulary of the world. Both modes are valid and both exist in the game — early areas lean toward restoration, later areas toward construction.

Every installation has two visual states: **unlit** (ruined, dormant, fog-swallowed) and **lit** (active, glowing, holding the fog back). The transition between these states on placement is a key feel moment — a pop-in animation followed by a texture swap from unlit to lit sprite, with the PointLight2D energy tweening up as the installation comes to life. The visual language is TOTK Zonai: organic forms threaded with glowing amber, stone and wood and soft circuitry coexisting in the same object.

| Installation | Description | Aesthetic | Unlock |
|---|---|---|---|
| Lantern post | Basic radius fog clearance | A living wooden stake with an amber crystal that blooms when placed | Early game, craftable from darkwood and fog-crystal |
| Luminous plant | Grown from seeds, soft light, harvestable over time | Root systems that glow from underneath, flowers that cast warm pools | Mid game, requires agriculture knowledge |
| Beacon structure | Clears wide areas, landmark-scale | A reactivated Zonai-style tower — stone with amber veins that pulse back to life | Mid-late, significant resources and Poes |
| Carved stone | Ancient light-magic, reveals lore layer | Pre-existing ruins unlocked rather than built — always were there, now lit | Late, unlocked through world discovery |

Each installation triggers a distinct audio event on placement — a soft musical chord that resolves into the ambient soundscape, making the world feel more harmonious than it did before.

### 4.4 Revisit Rewards

Old areas contain resources and secrets accessible only with later tools or knowledge — a core mechanic that keeps the full map alive throughout the game. Examples:

- A mineral vein requiring a specific chisel upgrade to extract
- A Poe type that only appears near a particular luminous plant species
- A buried structure only visible with a lore-tuned lantern frequency
- A fog pocket that only clears when a beacon of sufficient power is installed nearby

The world map should always function partly as a to-do list of unfinished business.

> **[PLACEHOLDER]** Design a tagging or annotation system so the player can mark areas for revisiting without breaking the exploratory feel.

---

## 5. Progression Systems

### 5.1 Overview

Progression in Lanternfall operates across three interlocking tracks that feed one another:

- **Exploration track** — lantern upgrades, fog penetration, biome access
- **Crafting track** — material tiers, recipe unlocks, installation types
- **Settlement track** — vendor arrival, structure upgrades, Poe economy depth

No track is a prerequisite for another in a strict sense — the player can lean into whichever feels most compelling — but they are designed to naturally pull each other forward.

### 5.2 Lantern Upgrade Path

> **[PLACEHOLDER]** Define the full lantern upgrade tree — cone width, brightness, range, frequency tuning. What materials and Poes does each upgrade require? How many tiers before end-game?

### 5.3 Milestone & Horizon Design

At every moment of play, the player should be able to see at least one clear next goal — ideally three, at different time scales: something achievable this session, something achievable in a few sessions, and something on the distant horizon. The progression system must be designed to maintain this at all stages of the game, including late game.

> **[PLACEHOLDER]** Map out the full milestone graph — what unlocks what, and what new goal each milestone reveals. Validate that no stage of play has a visible dead end.

### 5.4 Seasonal Rhythm

> **[PLACEHOLDER]** Define whether seasons exist in Lanternfall and what they mean mechanically — new materials available, Poe behaviour changes, fog density shifts. Does a season affect the whole world or vary by biome?

---

## 6. Gathering & Crafting

### 6.1 Resource Categories

Resources in Lanternfall reflect the grounded fantasy tone — organic, mineral, and light-touched:

| Category | Examples | Primary Use |
|---|---|---|
| Organic | Mossweed, darkroot, spore clusters, bark | Crafting, agriculture, vendor trade |
| Mineral | Fog-crystal, ironstone, compressed ash | Lantern upgrades, beacon construction |
| Light-touched | Glow-resin, echo-amber, condensed light | Advanced installations, lore items |
| Cultivated | Grown from seeds on settlement plots | Passive income, luminous plant fuel |

### 6.2 Crafting System

> **[PLACEHOLDER]** Define the crafting interface and recipe structure. How are recipes discovered — by finding materials, by vendor unlock, by world discovery? How does the recipe tree branch, and how does each unlock reveal a new branch?

### 6.3 Agriculture

Luminous plants are both a light installation and an agricultural system. Planting, tending, and harvesting them contributes to fog clearance passively over time, produces harvestable materials, and attracts specific Poe types. The agriculture system should feel like a quiet background loop running alongside active exploration.

> **[PLACEHOLDER]** Define the agriculture system in full — growth cycles, tending actions, harvest yields, and how plant placement interacts with fog and Poe attraction.

---

## 7. Settlement Building

### 7.1 Overview

The settlement is the player's home, workshop, and community hub. It grows through three mechanisms: structures the player builds, vendors attracted by Poe accumulation, and environmental improvements that expand the settlement's lit footprint.

### 7.2 Structures

> **[PLACEHOLDER]** Define the full structure list — workbench tiers, storage, agriculture plots, vendor stalls, communal spaces. What does each require to build and what does it unlock?

### 7.3 Vendors

Vendors are characters attracted to the settlement by Poe accumulation and word of the player's growing light. Each vendor offers a distinct service — trading, recipe knowledge, lantern tuning, lore — and has their own arrival conditions and relationship depth.

> **[PLACEHOLDER]** Define the full vendor roster — who they are, what they offer, what brings them, and whether they have relationship arcs or just transactional roles.

### 7.4 Settlement as Beacon

The settlement's total light output is a meaningful game stat — it determines how far its warmth is visible in the fog and influences which Poes and vendors are drawn to it. Building up the settlement is not just functional, it is a contribution to the world's overall illumination.

---

## 8. The Poe Economy — Ghostly Companions

### 8.1 What Poes Are

Poes are small ghostly beings — curious, gentle, drawn to light. They exist in the fog in large numbers, going about their own quiet business, and are attracted to the player's lantern as they explore. They are not caught or harmed — they simply follow the light, and can be guided back to the settlement.

Visually they should feel distinct from Zelda's Poes — more like soft floating wisps with personality, somewhere between a firefly and a small ghost. They are the soul of the world's ambient life.

### 8.2 Poes as Currency

Poes function as a social and economic currency rather than a crafting material. They are used to:

- Attract and unlock vendors (a vendor requires X Poes to settle)
- Unlock certain beacon structures that require community as much as materials
- Trade for rare recipes or lore items with specific vendors
- Contribute to the settlement's light output

Poes are not spent in a depleting sense — they accumulate as a reputation. A vendor doesn't take your Poes; they come because enough Poes have gathered around you.

> **[PLACEHOLDER]** Finalise the Poe economy model — is it a pure accumulation score, or are Poes a spendable resource in some contexts? Define Poe types and whether different types have different uses or attractions.

### 8.3 Poe Types

Different Poe types appear in different biomes and under different conditions — some near luminous plants, some in dense fog, some only at certain times of day or season. Collecting a full range of Poe types is a long-term collector's goal.

> **[PLACEHOLDER]** Define the full Poe type list with appearance conditions, visual distinctions, and any unique economic roles.

---

## 9. Biomes

### 9.1 Overview

Biomes are distinct regions of the fogged world, each with a unique visual identity, material set, Poe types, and exploration challenges. Discovering a new biome opens new crafting paths and — critically — gives the player new tools or knowledge to bring back to old areas.

### 9.2 Biome Design Principles

- Each biome must introduce at least one material not found elsewhere
- Each biome must introduce at least one revisit hook for earlier areas
- Each biome should feel tonally distinct but remain within the cozy-mysterious register
- Biome access should feel earned but not arbitrarily gated

### 9.3 Biome Concepts

> **[PLACEHOLDER]** Define 4–6 biomes in full — name, visual identity, unique materials, unique Poe types, fog characteristics, and what new capability or knowledge they grant the player.

Starter concepts to develop:

| Biome | Tone | Unique Hook |
|---|---|---|
| The Mosshallow | Damp, overgrown, ancient | Organic materials; buried ruins with lore |
| The Ashfields | Dry, mineral, open | Dense mineral deposits; fog is thicker, rewards better lantern |
| The Canopy Dark | Vertical, tangled, alive | Rare plants; fog behaves differently in treetops |
| The Tidemarsh | Coastal, reflective, eerie | Light refracts through water; unique crystal materials |
| The Deep Quiet | Deepest fog, most mysterious | End-game biome; answers some lore questions |

---

## 10. Music & Audio

### 10.1 Philosophy

The world of Lanternfall is a musical instrument. Every action the player takes produces a sound that is not just feedback but a note — and that note harmonises with everything else happening in the soundscape. The cumulative effect of a well-lit, well-tended world is a richer, more complex, more beautiful ambient score than a dark, unexplored one.

### 10.2 Musical Fog Clearance

Clearing fog releases soft arpeggios that resolve into the ambient music — each clearance event adds a new harmonic layer. A fully lit area has a richer ambient texture than a newly explored one. The player can hear their own progress.

### 10.3 Installation Audio Events

Each type of permanent installation has a distinct audio signature on placement:

- **Lantern post** — a single warm chime that sustains and fades into the ambient
- **Luminous plant** — a soft organic tone, slightly unpredictable in pitch, that adds a living quality
- **Beacon structure** — a full chord event, felt as well as heard, that shifts the ambient key
- **Carved stone** — something older and stranger; a tone that doesn't quite fit the ambient but somehow resolves anyway

### 10.4 Dynamic Score Architecture

> **[PLACEHOLDER]** Define the technical approach to the dynamic score — middleware (FMOD, Wwise), layering system, how biome transitions affect the ambient key, how time of day or season shifts the tonal palette. Define the base key and scale palette for each biome.

### 10.5 Poe Audio

Poes produce soft tonal sounds as they move — a light, wandering melodic line that weaves through the ambient. A dense cluster of Poes produces something almost choral. The player should be able to hear when Poes are nearby before seeing them.

---

## 11. Multiplayer & Social

### 11.1 Soft Multiplayer

Other players exist in the world as travellers — ambient presences that drift through your map occasionally, visible but not interactive. You may see the installations they have placed in a shared region, or find an object they left behind. No communication is required or expected.

> **[PLACEHOLDER]** Define the full soft multiplayer architecture — how shared regions work, how visit frequency is controlled, privacy settings, and how the system preserves the solo experience while adding ambient life.

### 11.2 Poe & Recipe Exchange

Travellers can leave rare Poe types or recipe fragments near your settlement — discoverable objects that add to your progression without requiring any direct interaction. This is the primary social hook: the world feels inhabited without being social.

> **[PLACEHOLDER]** Define the exchange system in full — what can be left, how the player discovers it, opt-in/out controls.

---

## 12. Art Direction

### 12.1 Visual Language & Medium

**Lanternfall is top-down 2D pixel art.**

This decision is driven by production reality (solo dev, no 3D modelling skills) and is treated as a strength, not a compromise. The cozy exploration genre is largely defined by 2D games — Stardew Valley, Chicory, Unpacking, Undertale — and the specific aesthetic of Lanternfall (warm amber light against cool fog, organic forms, luminous plants, a settlement that accumulates character) is highly expressive in pixel art.

The BOTW/TOTK reference translates into 2D as a set of design principles rather than a visual style to copy directly: material weight communicated through texture and highlight, the organic-technology vocabulary expressed through silhouette and colour rather than geometry, the sense of a world with geological history communicated through layered environmental detail.

The art style is **warm, textured, and moderately detailed** — not the 8-bit minimalism of early Stardew, but not so dense that it becomes muddy at game scale. Every asset should read clearly at the intended camera distance first, with detail that rewards a closer look second.

The visual identity of Lanternfall is defined by the tension and harmony between two things: the **cool blue-grey of the fog** and the **warm amber glow of light**. Every screen is a composition of these two palettes — the player is always moving from one into the other, and the world visually records where they have been.

### 12.2 Colour Palette

| Context | Palette | Notes |
|---|---|---|
| Fog (unexplored) | Deep blue-grey, near-black at edges | Volumetric, slightly luminous — not flat darkness |
| Fog (near light) | Soft blue-white, translucent | Should feel like morning mist, not threat |
| Lantern light | Warm amber, high saturation at source | Distinct from fog and from permanent light |
| Permanent installations | Golden, steadier and softer than lantern | Feels settled, safe, earned |
| Luminous plants | Warm green-gold | Organic light — slightly variable, alive |
| Settlement | Full warm palette, no fog | The one place that feels fully known |
| Biome variation | Each biome has a distinct secondary tint | Mosshallow = cool green; Ashfields = ochre; Tidemarsh = deep teal |

### 12.3 Lantern Light Rendering (2D)

In top-down 2D, the lantern cone becomes a literal visible shape on the ground — a warm radial gradient overlaid on the fog layer, with a direction controlled by the player. This is both technically simpler than 3D volumetric lighting and potentially more elegant: the cone is readable, the boundary between light and dark is legible, and the player can see exactly where they have and haven't explored.

**Implemented in Godot 4 as a hybrid system:**
- `CanvasModulate` darkens all world content to deep blue-black. The player's `PointLight2D` (and Poe glow lights, installation lights) punch through this darkness natively — no per-frame image writing required for the live lantern.
- A separate 512×512 Image mask on a `CanvasLayer` handles *permanent* fog clearance state. This mask is only updated during active clearance animations and idle boundary breathing — not every frame.
- The fog boundary behaves as a waterline — see §4.2 for the full model. It is not a flat overlay but a living, organic shoreline with noise-offset irregularity, animated recession on clearance, and slow idle breathing.

Key feel targets:
- The lantern cone edge should be soft, not hard — a gradient falloff, not a sharp circle
- The transition from lit to dark at the cone edge should feel like moving from a warm room into a cool night
- Permanent light installations should cast a distinctly different quality of light — broader, softer, steadier — so explored and unexplored areas read clearly at a glance
- The HUD is on a separate CanvasLayer unaffected by the world darkening

### 12.4 Settlement Visual Identity

The settlement should feel like a place that has accumulated character over time — every addition legible as a choice the player made. The Animal Crossing reference is useful here: each new structure or vendor changes the feel of the whole, and the player should be able to see the history of their decisions in the landscape.

Structures use the organic-technology vocabulary: timber with glowing inlaid veins, lanterns that are also plants, roofs that have begun to grow moss. The overall impression should be warmth and gentle industry — a place where things are made carefully and with care.

### 12.5 Poe Visual Design

Poes are soft floating wisps — distinct from the Zelda design, which is more skull-like and angular. Lanternfall Poes are rounder, more diffuse at the edges, with a slow internal light that pulses gently. They should read as curious and gentle rather than spectral. Different Poe types are distinguished by colour temperature, size, and movement pattern — not by facial features or complex silhouettes.

> **[PLACEHOLDER]** Develop a full Poe visual design guide — silhouette language, colour coding by type, animation principles (how do they move? do they react to the player's presence?)

---

## 13. Art Production

### 13.1 Toolchain

| Tool | Role |
|---|---|
| **Nano Banana** | Concept art generation — mood, palette, design language, asset references |
| **PixelLab** | Pixel art production — converting concepts into game-ready assets, animation |
| **Godot 4** | Engine — top-down 2D, CanvasModulate + PointLight2D lighting, Image mask fog system |

The workflow is: Nano Banana establishes the visual direction and generates reference images → PixelLab translates those references into pixel assets at the correct resolution and palette → assets are integrated into Godot 4 with lighting and fog applied programmatically.

Nano Banana is used as an **art direction tool**, not a final asset pipeline. Generated images set the tone, palette, and design vocabulary. They are not imported directly into the game.

**Asset pipeline:** All game assets live under `res://assets/`. Placeholder PNGs are generated programmatically by an `AssetGenerator` script on first run and saved to `res://assets/placeholder/`. Final PixelLab art mirrors the same folder structure under `res://assets/final/`. A single constant in `AssetConfig.gd` switches the whole game between placeholder and final art — no other changes required. See the Prototype Spec for the full folder structure and pixel specifications.

### 13.2 Production Order

Asset production should follow this priority order, from highest to lowest. Do not move to the next category until the current one is locked.

**1. Master palette** — extracted from Nano Banana concept art. Must be locked before any pixel assets are produced. All subsequent assets are constrained to this palette. Target: 28–32 colours total, covering fog, light, terrain, characters, UI.

**2. Player character & lantern** — on screen at all times, sets the tone for everything else. Includes idle, walk (4 directions), lantern-raise animation. Get these feeling right before any environment work.

**3. Poes** — the second most visible character type. 2–3 types to start. Simple silhouettes, distinct colour temperatures, looping float animation. These should feel alive with minimal frames.

**4. Core terrain tiles** — the single most time-consuming category. Start with one biome (The Mosshallow recommended — organic, forgiving, doesn't require the precision of stone or water). Grass base, fog overlay, path, water edge, tree. Tileable and seamless.

**5. Settlement structures** — workbench, crop plot, vendor stall, lantern post. The first things the player sees. These establish the organic-technology vocabulary in pixel form.

**6. Permanent installations** — lantern post (field version), luminous plant (3 growth stages), beacon structure. These need to read clearly both unlit (restoration state) and lit (active state).

**7. Vendors & NPCs** — after the world is established. Characters should feel like they belong to the world the terrain and structures have defined.

**8. Additional biome tiles** — one biome at a time, in progression order.

**9. UI elements** — last. The UI should be designed around the game's feel, not the other way around.

### 13.3 Palette Strategy

The master palette is the most critical art production decision. It must be locked from Nano Banana concepts before PixelLab work begins, and it must not drift between asset sessions.

**Recommended palette structure:**

| Group | Colours | Notes |
|---|---|---|
| Fog darks | 4 | Near-black to mid blue-grey — the unexplored world |
| Fog mids | 3 | Translucent fog texture, fog-near-light transition |
| Amber lights | 4 | Lantern source → falloff → warm ambient |
| Gold lights | 3 | Permanent installation glow — softer, steadier than lantern |
| Terrain neutrals | 6 | Stone, earth, bark, path — the substrate of the world |
| Organic greens | 4 | Moss, plant life, luminous plant base colours |
| Accent colours | 4 | Poe types, rare materials, lore objects — used sparingly |
| UI / character | 4 | Skin tones, UI chrome, text backgrounds |

Total: ~32 colours. This is a constraint, not a target — if 28 covers everything, use 28.

### 13.4 Nano Banana Prompt Strategy

Before generating individual assets, use Nano Banana to establish the following reference images in order. Each session should build on the last — reference earlier outputs when prompting for new ones to maintain consistency.

**Session 1 — Fog and light mood**
Goal: lock the core visual contrast. Generate 4–6 variations of a foggy landscape with a single warm light source. Look for the palette relationship between the fog blues and the amber light that feels right. Extract hex values.

**Session 2 — The lantern**
Goal: establish the primary object. Generate close-up references of the lantern — Zonai-influenced, amber glass, root-like metalwork. Should feel grown rather than manufactured. Try variations in size and form.

**Session 3 — Settlement structures**
Goal: establish the organic-technology vocabulary. Generate 3–4 settlement building concepts — workbench, vendor stall, crop plot. Each should feel like it belongs to the same visual language: timber, glowing veins, things that grow and are also made.

**Session 4 — Poes**
Goal: establish the companion visual language. Generate soft, round, wisp-like ghostly beings — distinct from Zelda Poes, more organic and diffuse. Try 3–4 colour variants. The silhouette should be readable at 16×16 pixels.

**Session 5 — Biome: The Mosshallow**
Goal: establish the first biome's environmental identity. Damp, ancient, overgrown. Ruins half-consumed by moss and root. The first place the player will explore — it sets the tone for the world's history.

**Session 6 — Restoration vs. construction contrast**
Goal: generate paired images of the same installation in unlit (ruined, fog-swallowed) and lit (restored, active) states. This establishes the visual language for the game's core progression beat.

### 13.5 Pixel Art Specifications

All sprites are designed for **16×16 tile size**, rendered at **3× scale** (48px display tiles). Character sprites are 16×32 (one tile wide, two tiles tall). Source art is always produced at native 1× resolution — scaling is handled by Godot.

| Asset | Dimensions | Frames | Pivot |
|---|---|---|---|
| Player idle (per direction) | 16×32 | 1 | Bottom centre |
| Player walk (per direction) | 16×32 | 4 | Bottom centre |
| Lantern (attached to player) | 8×12 | 1 | Bottom centre |
| Poe (all types) | 14×14 | 3 (float loop) | Centre |
| Lantern post unlit | 12×24 | 1 | Bottom centre |
| Lantern post lit | 12×24 | 2 (subtle pulse) | Bottom centre |
| Luminous plant (per growth stage) | 16×24 | 2 (gentle sway) | Bottom centre |
| Ground tile | 16×16 | 1 | Top left |
| Vendor / NPC | 16×32 | 1 idle to start | Bottom centre |

Export from PixelLab at native dimensions. Do not export at scaled resolution.

### 13.6 Animation Priorities

Not everything needs animation. Prioritise in this order:

- **Player character** — walk cycle (4 directions), idle. Essential. Lantern-raise animation is post-prototype — stub with a static frame for now.
- **Poes** — 3-frame floating loop (handled by AnimationPlayer cycling sprite frames), attracted state (speed increase only, no new frames needed in prototype), collected state (scale to zero). Essential.
- **Luminous plants** — growth stages as discrete static frames; gentle 2-frame sway loop. Important.
- **Lantern post** — unlit → lit texture swap on placement, with pop-in scale tween. The lit version has a 2-frame subtle pulse. Important.
- **Fog boundary** — idle breathing via boundary oscillation (implemented in FogSystem, not a sprite animation). Important.
- **Beacon activation** — one-shot animation when a beacon comes back to life. High impact, worth the investment when beacon is implemented.
- **Vendor characters** — idle only to start. Walk cycles post-launch.
- **Settlement structures** — static. Smoke from a chimney is a nice addition but not essential.

---

## 14. UI & UX

The full UI philosophy remains open, but the **prototype HUD should stay minimal**:

- Poe counter
- Installation counter
- Optional placement failure feedback

Inventory, crafting interface, map/fog revelation UI, milestone notifications, and broader diegetic UI experiments are explicitly **out of scope for the first playable**. The prototype should prove legibility and feel with as little UI as possible.

---

## 15. Technical Requirements

### 15.1 Engine

**Godot 4.x** — top-down 2D. No 3D. Selected for its native 2D lighting system, built-in `FastNoiseLite`, strong GDScript tooling, and solo-dev-friendly workflow.

### 15.2 Rendering & Fog Architecture

The fog system is a hybrid of two layers:

- **CanvasModulate + PointLight2D** — darkens all world content; player lantern and installation lights punch through natively via Godot's 2D light renderer. Zero per-frame cost for the live lantern.
- **512×512 Image mask** — a `TextureRect` on a `CanvasLayer` above the world tracks permanent fog clearance state. Updated only during active clearance animations and idle boundary breathing. Serialised as PNG for save/load.

The fog boundary is implemented as a waterline — see §4.2. Boundary irregularity uses `FastNoiseLite` with a globally consistent seed.

Performance budget for simultaneous `PointLight2D` sources in a dense settlement to be validated during prototyping. The Image mask rebuild frequency is ~20fps for idle breathing, every frame during active clearance events.

### 15.3 Save System

Fog clearance state is intended to be persisted as a PNG export of the permanent mask Image. Installation positions, Poe counts, and progression state are serialised as JSON.

For the first playable, save/load should be treated as a **stub seam only**. The prototype does not need a finished save pipeline if state can be reset quickly during iteration.

### 15.4 Target Platforms

The first playable prototype targets **desktop PC first** with keyboard input. Windows is the immediate development target; broader PC support is desirable but not required to prove the loop. Mobile and console are explicitly deferred, and should not influence prototype control or rendering decisions yet.

### 15.5 Soft Multiplayer Architecture

Soft multiplayer remains a longer-horizon feature and is **out of scope for the first playable prototype**. The immediate technical risk to validate is the fog system and the single-player exploration loop. Any multiplayer-facing state should be designed later around proven single-player progression data, not pre-optimized into the first slice.

---

## 16. Monetization

Monetization is intentionally deferred. It should not shape prototype scope or technical architecture at this stage.

---

## 17. Scope & Milestones

Project scope should be treated in explicit phases:

**Phase 1 — First playable prototype**

Goal: prove the game's core sensation.

Includes:
- Player movement in a dark top-down world
- Handheld lantern using Godot 2D lighting for temporary visibility
- FogSystem with permanent clearance mask and waterline-style boundary behavior
- One installation type: lantern post
- One Poe type with spawn, attraction, and collection behavior
- Generated placeholder PNG asset pipeline (`AssetGenerator` + `AssetConfig`)
- Minimal HUD only

Excludes:
- Crafting
- Agriculture
- Vendors and settlement simulation
- Multiple biomes
- Full lore implementation
- Multiplayer / traveller systems
- Finished save/load
- Dynamic music system beyond hooks

Done looks like:
- A player can explore for 10 minutes without instruction and understand the loop
- Placing a lantern post permanently changes the world in a satisfying, readable way
- Poes are visible, collectible, and reinforce the loop
- The generated placeholder asset workflow supports rapid iteration without reworking scene logic

**Phase 2 — Vertical slice**

Goal: wrap the proven loop in one authored biome and one stronger progression layer.

Likely additions:
- One biome with clearer material identity
- Basic gathering and one simple recipe chain
- At least one meaningful lantern or installation upgrade
- Stronger audio feedback and presentation polish

**Phase 3 — Expansion systems**

Only after the loop is proven should the project expand into:
- Agriculture
- Vendors
- Settlement growth layers
- Additional biomes
- Save/load completion
- Social / traveller systems
- Richer music and narrative delivery

---

*Lanternfall GDD — Concept Draft v0.5. Aligned with Prototype Spec v0.5. The immediate focus is a narrow first playable prototype that proves the exploration loop with generated placeholder assets before broader production planning resumes.*
