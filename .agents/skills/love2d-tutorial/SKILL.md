---
name: love2d-tutorial
description: Build a complete game in Lua + LÖVE (11.5) following the "BYTEPATH" architecture from a327ex's tutorial series. Use when the user wants to make a full love2d game, set up the project skeleton, add rooms/areas/objects, passives/skill tree, or an in-game console. Covers game loop, libraries, rooms & areas, player/enemies/director, stats-as-data, skill tree, and console.
---

# Make a Full Game in LÖVE (BYTEPATH-style)

This skill distills the "BYTEPATH" tutorial (a327ex, github.com/a327ex/blog/issues/30) — a 15-part series that builds a complete twin-stick shooter with a Path-of-Exile-style passive skill tree. The goal is a **player-friendly early build**: a small-but-complete playable game and, crucially, a **code structure that scales to hundreds of items/passives without getting lost**. Target runtime is **LÖVE 11.5** (the tutorial was written for 0.10.2; the deltas are listed in Pitfalls).

## Before You Start

- User needs: basics of programming + OOP + basic Lua (learnxinyminutes.com/docs/lua). This is for someone who can already program.
- **Follow with exercises.** The tutorial is built around exercises so the reader learns instead of copy-pasting; don't skip them — the skill's value is the structure, not the literal code.
- The tutorial repo (full reference implementation): github.com/a327ex/BYTEPATH, `tutorial/` folder.

## When to Use

- Setting up a new LÖVE 11.5 project skeleton (conf.lua, main.lua, folders, auto-require).
- Deciding the high-level game architecture: rooms/scenes, area object management, base GameObject.
- Building any of: player movement, stats/attacks, enemies, a difficulty/director system, passives/skill tree, an in-game terminal console, or a low-res pixelated render.
- When the user wants a code structure that stays navigable as the game grows large.

## LÖVE 11.5 Project Layout

```text
project/
├── conf.lua            # window + module config, gw/gh/sx/sy globals
├── main.lua            # love callbacks: load/update/draw/keypressed/textinput...
├── libraries/          # classic, hump (timer+camera), boipushy, moses, lume
├── objects/            # every game class as its own file -> auto-required
├── rooms/              # Stage, Console, SkillTree (scene classes)
├── utils.lua           # UUID(), distance(), random(), chanceList() helpers
└── globals.lua         # colors, enemies list, and other global constants
```

## Core Dependencies (drop into `libraries/`, require at top of main.lua)

| Library | Path | Use |
| --- | --- | --- |
| `rxi/classic` | `libraries/classic/classic` | OOP: `Object:extend()`, classes as global variables |
| `hump` | `libraries/hump/timer` + `.../camera` | timers (`after`/`every`/`tween`) + camera |
| `boipushy` (adonaac) | `libraries/boipushy/Input` | polled input instead of callbacks: `input:bind`, `input:pressed/down/released` |
| `moses` (Yonaba) | `libraries/moses/moses` | table helpers (`each`, `map`, `filter`, `shuffle`...) |
| `lume.uuid` (rxi) | copy just the UUID fn into utils.lua | unique object IDs |

The whole project runs on **4 global "runtime" variables**: `Object` (classic), `Timer`/`camera`, `Input`, and `timer` (a global hump.timer instance). Global variables are used liberally and intentionally (see Coding Practices below).

## Built In: pixelated low-res rendering

- `conf.lua` defines `gw=480, gh=270` (a base resolution that divides cleanly into 1920x1080), plus `sx, sy` scale factors (start at 1; in 11.5 just call `love.window.setMode(gw*sx, gh*sy)`).
- In 11.5 use `love.graphics.setDefaultFilter('nearest', 'nearest')` in love.load for the crisp pixel look.
- Each Room draws its content to a Canvas of `gw×gh`, then draws that canvas scaled by `sx, sy` with `setBlendMode('alpha', 'premultiplied')` — this is what keeps small shapes proportionally scaled and centered when the window grows.
- Disable automatic window scaling: LÖVE 11 does NOT auto-resize a 480x270 window to fill the monitor the way older tutorials imply; handle scaling yourself via the Canvas + `setMode`.

## Architecture (the reusable core)

### 1. Game loop

- `main.lua` only needs `love.load` (once), `love.update(dt)`, `love.draw` (every frame); LÖVE's default `love.run` handles the rest.
- The whole game is the while-true loop in `love.run`: poll events → `dt = love.timer.getDelta()` → `love.update(dt)` → clear, `love.draw`, present.
- `dt` (delta time) is used to make speeds frame-rate independent.

### 2. Rooms (scenes) + gotoRoom

- A Room is just an `Object:extend()` class with `new`/`update`/`draw`. All rooms live in `rooms/`.
- Simple version: one global `current_room`; `love.update/draw` call `current_room:update/draw` if set.
- `gotoRoom(room_type, ...)` creates the new room from a string via `_G[room_type](...)` and swaps `current_room`. Old room is garbage-collected (no continuity). Good for BYTEPATH's 3 rooms (Stage, Console, SkillTree) which need no state carried across.
- Persistent variant (for dungeon roguelikes like Binding of Isaac): `rooms[name]` table + `addRoom` + `activate`/`deactivate`. Use only when rooms must survive.
- **Rule of thumb from the tutorial:** only make a thing a separate room if it truly needs its own lifecycle. Overlays/menus that sit on top of the live game usually belong in the same room.

### 3. Area (object manager) + GameObject

- `Area` lives inside a Room; holds `game_objects`. Its `update` iterates **backwards** (`for i=#list,1,-1`) so removing dead objects doesn't skip elements.
- `addGameObject(type, x, y, opts)` instantiates by string name (`_G[type](self, x, y, opts)`), inserts, returns the instance.
- Query helpers: `getAllGameObjectsThat(filter_fn)` — used for proximity/type checks (e.g. homing projectile finds a nearby enemy).
- `GameObject` (base): `new(area, x, y, opts)` copies every `opts` key onto self, sets `x, y`, a unique `id` (`UUID()`), `dead=false`, and an internal `self.timer = Timer()`. `update(dt)` updates the timer; set `dead=true` to be removed.
- Draw-order / layers are handled by sorting objects; `Area` draws them in list order.

## Build Procedure (follow this order)

1. **Scaffold** — conf.lua, main.lua, libraries, folder structure, `recursiveEnumerate` + `requireFiles` so every file under `objects/` (and `rooms/`) auto-requires. In 11.5 `requireFiles` just does `require(path:sub(1,-5))` after enumerating via `love.filesystem`.
2. **Input** — boipushy: `input:bind('left', 'move_left')` etc. Query with `input:pressed('action')`, `input:down('action')` (with optional interval for auto-repeat), `input:released`.
3. **Timers** — global `timer:after/sec`, `timer:every(sec, fn, times)`, `timer:tween(seconds, subject_table, target_table, mode, on_complete)`. `tween` is how all smooth animation (camera zoom, HP bars, circle pulses) is done. Use `timer:cancel(handle)`; consider tagging timers (EnhancedTimer / chrono) so repeat events reset cleanly.
4. **Rooms + Area + GameObject** — wire the skeleton above. Verify with a circle object that spawns and self-destructs.
5. **Pixel canvas + camera** — canvas rendering per Room; `hump.camera` to follow the player in Stage, lock at `0,0` in SkillTree.
6. **Player** — twin-stick movement: position/rotation `x,y,r`, rotation velocity `rv`, velocity `v`, linear+angular acceleration `a`, friction. Model as `base_max_v`, `max_v`, momentum so multipliers can scale it.
7. **Player stats & attacks** — HP/Boost/Ammo as `max_*` + current values. Attacks are projectiles (circles + colliders). Resources on the map use the same chase/collect pattern (an Ammo object with a `target` it accelerates toward → reuse for homing).
8. **Enemies** — each enemy is a GameObject; register class names in a global `enemies` table (`{'Rock','Shooter',...}`) so the rest of the game can filter "is this an enemy".
9. **Director (difficulty/gameplay loop)** — separate Director object holding spawn rules, difficulty scaling, and resource/attack spawn timing.
10. **Coding practices pass** — see below; decide where globals are fine and when to actually abstract.
11. **Passives** — implement stats as data (see next section).
12. **Skill tree** — define nodes in a text table, render Nodes + Line links, pan/zoom, spend skill points, save/load.
13. **Console room** — terminal-flavored menu/UI.
14. **Final** — menus, restart, score, save/load, polish.

## Director / difficulty pattern

- Difficulty increases on a timer (e.g. every 22s a new "round").
- Rounds have a point budget; enemies cost fixed points; pick enemies within budget randomly until spent.
- Points per round follow a "normalize → relax → intensify" curve from a formula (feels better than linear).
- **`chanceList`** (in utils.lua) — instead of raw `love.math.random`, build a list `{value,weight}` expanded to flat entries, draw by removing from the list, regenerate when empty. Guarantees exact distribution (X exactly 25 times out of 100) — used everywhere probabilities must feel controlled (drops, barrage-on-cycle, resource spawns).
- Resources/attacks/powerups spawn on their own cadences independent of difficulty (e.g. resource every 16s, attack every 30s).

## Passives as data (stats-driven design — the key scaling idea)

- Model every upgradable stat on the Player as a variable:
  - **Multipliers** (start 1): `hp_multiplier`, `ammo_multiplier`, `boost_multiplier`, `mvspd_multiplier`...
  - **Flats** (start 0): `flat_hp`, `flat_ammo`, `flat_boost`...
  - **Chances** (start 0): `barrage_chance`, `homing_chance`...
- A skill-tree node is just data: `tree[10] = {name='HP', stats={{'6% Increased HP', 'hp_multiplier', 0.06}}, x=.., y=.., links={...}, type='Small'}`.
- `treeToPlayer(player)` reads the chosen nodes and writes the matching variables; a final `player:setStats()` applies them (`max_hp = (max_hp+flat_hp)*hp_multiplier`, then `hp=max_hp`).
- The stat variable name in the node AND the Player field must match exactly — a thin, error-prone link, but fine solo. This pattern is what lets 900+ tree nodes work without a giant switch statement.
- Actions like homing projectiles are just an `attack` string on the projectile; enemies-vs-not is the `enemies` global list; object identity via `e:is(_G['ClassName'])`.

## Skill tree specifics

- Define everything in a text file (`tree.lua`): each node has name, stats, `x,y`, `links` (list of node indices), and type (Small/Medium/Big/Notable).
- `SkillTree` room keeps its own `nodes`/`lines` tables (not an Area). `Node` and `Line` objects; `Line` draws between two node positions from their ids.
- Camera: drag to pan (move opposite to mouse delta: `current - previous`), and tween `camera.scale` on wheel for zoom-in/out (with min/max clamps). Draw nodes filled (background color) then outlined so lines don't overlap visually.
- Spent skill points + node states saved/loaded via `love.filesystem`.

## Console room pattern

- Lines = colored Text objects positioned via a running `line_y` (increment per line); add each with a small `after(delay)` so the terminal types in.
- Input lines: when `inputting` is true, forward `love.textinput(t)` (hook `current_room:textinput` in main.lua) to accumulate chars; Enter executes the command, Backspace removes a char (use input repeat). Blinking cursor = rectangle toggled on a timer.
- Modules = separate objects (Resolution, Volume, Ship select...) spawned by commands; the room creates/deletes them.

## Coding Practices (the tutorial's opinionated stance)

The tutorial explicitly argues that team/enterprise advice ≠ solo game-dev advice. Practical stance:

- **Globals are fine if you think about the type:**
  - Type 1 (read a lot, rarely written) — constants like `all_colors`, `gw/gh` — harmless, use freely.
  - Type 2 (written a lot, rarely read) — like an analytics table — mostly harmless.
  - Type 3 (written AND read a lot, e.g. `current_room`) — the actual danger people mean by "avoid globals." Use sparingly and only change at a tiny set of well-defined spots.
- **Abstracting vs. copy-paste:** default to repeating small bits of code rather than abstracting early. Build an abstraction (function/component/parent class) only when changes are frequent AND unpredictable, and the repetition has actually become a burden. Predictable/small changes are often *cheaper* as copy-paste in games. Big `if/elseif` chains and large classes are tolerated for the same reason.

## Pitfalls

- **LÖVE 0.10.2 → 11.5 deltas** (the tutorial targets 0.10.2):
  - `conf.lua`: set `t.version = "11.5"`. `t.window.fsaa` was renamed to `t.window.msaa` in 11.x (best left at 0). `t.modules.*` names are unchanged.
  - Window doesn't auto-scale a 480x270 canvas to fill the monitor in 11.x the way older docs imply — do the Canvas + `setMode` + `setDefaultFilter('nearest')` scaling yourself.
  - `love.graphics.setDefaultFilter('nearest','nearest')` is the modern way to get the pixel look.
  - Float-precision of textures/canvas scale factors can vary; keep base resolution a clean divisor of the target (480x270 for 1920x1080).
- **Remove-from-array-while-iterating** must loop backwards (`for i=#t,1,-1`).
- **Global name collisions:** class names are global by design (`Object:extend()` binds `ClassName` globally), so class names must be unique. `require` caches modules; don't `require` with `.lua` (strip it).
- **Homing/proximity loops** call `getAllGameObjectsThat` every frame — keep the filter cheap (radius check, class check), or cache targets.
- **`opts` table** in GameObject used as `local opts = opts or {}` to avoid nil errors when no options passed.
- **Random seed:** use `love.math.random` (auto-seeded by `love.run`) instead of Lua's `math.random` so IDs/randomness differ between runs.
- **tween requires the target be fields of a table** — you can't tween a bare number variable; wrap it in a table or use the subject-table form.
- **Timer handles leak**: cancel/clear timers on room death to avoid callbacks firing in a destroyed room.

## Verification

1. `love .` launches a window with no Lua errors; a blank or placeholder screen renders.
2. A test object added via `area:addGameObject('Circle', x, y)` updates and draws, and self-destructs (`dead=true`) and is removed without iteration bugs.
3. `gotoRoom('Stage')` / any room swap works and doesn't error after many swaps (no stale refs).
4. Player movement is frame-rate independent (same speed at 30 / 60 / 144 fps).
5. Director spawns enemies/resources on the defined cadence; difficulty ramps over time.
6. Skill tree renders Nodes + lines, pans/zooms, spends points, and those points actually change player stats on the next run (multiplier/flat applied in `setStats`).
7. Console accepts text input, runs commands, and redraws lines without flicker.
8. `lua` has no global duplicate-class collisions on auto-require (watch stderr on boot).
