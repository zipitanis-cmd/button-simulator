# Button Simulator

A Roblox incremental/simulator game built with Lua/Luau using a [Rojo](https://rojo.space/)-compatible project structure.

Players earn cash passively, step on physical buttons in the world to spend currency and gain stat boosts, and progress through three layered reset systems: **Multiplier → Rebirth → Ascension**.

---

## Project Structure

```
button-simulator/
├── default.project.json          -- Rojo project file
└── src/
    ├── server/                   -- ServerScriptService
    │   ├── DataManager.lua           DataStore saving/loading
    │   ├── PassiveIncomeHandler.lua  Passive cash gain loop
    │   ├── ButtonPurchaseHandler.lua Handle button touch purchases
    │   ├── RebirthHandler.lua        Rebirth + Ascension logic
    │   └── BillboardHandler.lua      Server-side billboard management
    ├── client/                   -- StarterPlayerScripts
    │   ├── StatsGui.lua              Main stats HUD
    │   ├── PinPanel.lua              Pin/unpin stat panel
    │   └── ButtonFeedback.lua        Purchase popups/notifications
    └── shared/                   -- ReplicatedStorage
        ├── ButtonConfig.lua          ALL button definitions (config table)
        ├── StatFormulas.lua          Income formulas, rebirth/ascension boost calc
        ├── NumberFormatter.lua       K, M, B, T suffix formatting
        └── RemoteEvents.lua          Remote event names/setup
```

---

## Core Game Loop

1. Cash ticks up passively every second based on:
   `Cash/sec = Base Income × Multiplier × Rebirth Boost × Ascension Boost`
2. Players step on **button parts** in the world to spend currency and gain stat boosts.
3. Three progression layers provide escalating resets with permanent boosts:
   - **Layer 1 — Multiplier buttons** (bought with Cash)
   - **Layer 2 — Rebirth-locked buttons** (require ≥1 Rebirth)
   - **Layer 3 — Ascension-locked buttons** (require ≥1 Ascension)
4. **Rebirth** (requires 1,000 Multiplier): resets Cash + Multiplier, grants +1 Rebirth and a 25% permanent boost to multiplier gain.
5. **Ascension** (requires 10 Rebirths): resets Cash + Multiplier + Rebirths, grants +1 Ascension and a 50% permanent boost to rebirth gain.

---

## Key Features

- **Config-driven buttons** — add a new button by adding a single entry to `ButtonConfig.lua`. No new scripts needed.
- **Multi-reward buttons** — one button can grant multiple stat changes (e.g. +50 Multiplier AND ×2 Cash Gain).
- **Billboard GUI** — a `BillboardGui` above each player's head shows their pinned stats. Other players can see it (social/flex feature).
- **Pin/unpin panel** — players choose which stats to display on their billboard.
- **Number formatting** — all displayed numbers use K / M / B / T / Qa / Qi … suffix notation.
- **DataStore saving** — all progress (stats, purchased buttons, pinned stats) persists across sessions with auto-save every 60 s, save-on-leave, and save-on-shutdown.
- **Server-authoritative** — all purchases and stat changes happen on the server; the client only displays.

---

## Setup with Rojo

1. Install [Rojo](https://rojo.space/) (the VS Code extension or the CLI).
2. Open a terminal in the project root.
3. Run `rojo serve default.project.json` (CLI) or use the VS Code extension.
4. Connect from Roblox Studio using the Rojo plugin.

All source files will be synced into the correct Roblox services automatically according to `default.project.json`.

---

## Adding a Button

Open `src/shared/ButtonConfig.lua` and add an entry to `ButtonConfig.Buttons`:

```lua
{
    id             = "my_new_button",
    displayName    = "+999 Multiplier",
    description    = "A very strong button.",
    cost           = 1000000,
    costType       = "Cash",
    rewards        = {
        { rewardType = "Multiplier", rewardOperation = "add", rewardValue = 999 },
    },
    repeatable     = false,
    costScaling    = 1,
    layer          = 1,
    unlockCondition = nil,
},
```

Then place a `Part` in Workspace and set its **`ButtonId` attribute** (string) to `"my_new_button"`. The server will automatically connect its `Touched` event.

---

## Balancing Targets

| Time        | Milestone                                      |
|-------------|------------------------------------------------|
| 0–1 min     | First cheap buttons, Multiplier starts climbing |
| 1–3 min     | Stronger buttons, noticeable acceleration       |
| 3–5 min     | First Rebirth (1,000 Multiplier)               |
| Post-rebirth| Second climb is 1.25× faster                   |
| ~15–20 min  | First Ascension (10 Rebirths)                  |
| Post-asc    | Layer 3 buttons, massive scaling                |
