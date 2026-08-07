# Rogue Shooter (LÖVE 11.5)

A top-down roguelike shooter. Everything — art, walls, and sound — is generated
programmatically at runtime; no image or audio assets are downloaded.

## Run

```bash
love .
```

Requires [LÖVE](https://love2d.org/) 11.x.

## The loop

- You spawn in the middle of a procedurally generated dungeon.
- Kill enemies (two kinds: chasing **Grunt**, ranging **Shooter**). Killing an
  enemy can drop a health pickup.
- Find the **key** and the **door**.
- Touch the door while holding the key to advance to the next, harder level.
  HP carries over with a small heal.
- Dying shows a game-over screen; press **R** to restart from level 1.

## Controls

| Input | Action |
| --- | --- |
| `WASD` / arrows | Move |
| Mouse | Aim |
| Left mouse (hold) | Shoot |
| `Esc` | Quit |

## Layout

Follows the BYTEPATH room + area + game-object architecture:

```
conf.lua            window / version config (gw=480, gh=270 base res)
main.lua            love callbacks, module wiring, gotoRoom
globals.lua         tile size, enemy class registry
utils.lua           math helpers, collision, camera mapping
level.lua           procedural dungeon generation + placement
lib/classic.lua     minimal OOP (callable classes)
lib/camera.lua      follow + clamped camera
lib/sfx.lua         runtime-synthesized sound effects
objects/            GameObject, Area (manager), Player, Bullet, Grunt,
                    Shooter, Key, Door, Pickup, Particle
rooms/Stage.lua     the play room: generation, camera, HUD, canvas render
```

The game renders to a fixed 480×270 canvas and scales it to the window
(aspect-preserving, `nearest` filter) for a crisp pixel look. Content is drawn
at `gw×gh`; the camera follows the player clamped to the dungeon bounds and the
mouse position is mapped back through the same transform for aiming.
