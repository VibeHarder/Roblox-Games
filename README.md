# Roblox-Games

A collection of Roblox experiences built with [Rojo](https://rojo.space/) and Luau.
Each game lives in its own folder under `games/` and can be synced into Roblox Studio independently.

## Games

| Game | Path | Genre | Description |
| --- | --- | --- | --- |
| Pastel Rift Survival | [`games/pastel-rift-survival`](games/pastel-rift-survival) | Co-op wave survival | Protect the Pastel Core from corrupted creatures emerging from dimensional rifts across 20 waves. |

## Requirements

- [Roblox Studio](https://www.roblox.com/create)
- [Rojo](https://rojo.space/) CLI or the VS Code extension

## Getting started

1. Clone the repository:

   ```bash
   git clone https://github.com/VibeHarder/Roblox-Games.git
   cd Roblox-Games
   ```

2. Pick a game and enter its folder, for example:

   ```bash
   cd games/pastel-rift-survival
   ```

3. Start Rojo and connect the plugin in Roblox Studio:

   ```bash
   ./scripts/bootstrap.sh
   # or
   rojo serve
   ```

   On Windows PowerShell, `./scripts/bootstrap.ps1` is also available.

4. See the game's own `README.md` for gameplay details and Studio setup steps.

## Repository layout

```text
Roblox-Games/
├── games/
│   └── <game-slug>/
│       ├── default.project.json   # Rojo project mapping
│       ├── README.md              # Game-specific setup and gameplay docs
│       ├── scripts/               # Bootstrap helpers
│       └── src/                   # Luau source (ReplicatedStorage, ServerScriptService, StarterPlayer)
└── README.md                      # This catalog
```

## Adding a game

Create a new folder under `games/` using a short kebab-case slug, give it its own
`default.project.json`, `README.md`, `scripts/`, and `src/` tree, and add a row to the
table above. Keep each game self-contained so it can be synced to Studio on its own.

## Notes

- Game logic is server-authoritative; the client sends requests and the server validates them.
- DataStore saving requires API Services to be enabled in the published experience's Game Settings.
- Source is hosted here; publishing an experience to a Roblox account is done from Roblox Studio.
