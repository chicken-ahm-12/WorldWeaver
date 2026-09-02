# WorldWeaver + Argon

Argon lets the WorldWeaver project live in a normal filesystem structure while mapping the source tree into Roblox services. This makes the project easy to edit, version, and build.

## Project structure

```text
WorldWeaverGame/
├── default.project.json
└── src/
    ├── ServerScriptService/
    │   ├── WorldWeaver/
    │   │   ├── Generator.luau
    │   │   ├── Painting.luau
    │   │   └── Settings.luau
    │   └── Main.server.luau
    └── ReplicatedStorage/
        └── Events/
            ├── gridLoaded
            └── terrainRendered
```

The three WorldWeaver modules stay together because `Generator.luau` requires `Painting.luau` from the same folder.

## Required events

Create two `BindableEvent` instances inside `ReplicatedStorage.Events`:

- `gridLoaded`
- `terrainRendered`

WorldWeaver uses these events to signal the completion of the grid and terrain rendering phases.

## `default.project.json`

```json
{
  "name": "WorldWeaverGame",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$path": "src/ServerScriptService"
    },
    "ReplicatedStorage": {
      "$path": "src/ReplicatedStorage"
    }
  }
}
```

## Building with Argon

1. Install Argon and its Roblox Studio plugin.
2. Open the WorldWeaver project directory in your editor.
3. Start the Studio sync workflow while developing.
4. Make your Luau and settings changes in `src/`.
5. Use the Argon build workflow when you want to produce the Roblox project artifact.

For the CLI workflow, the project can be opened with:

```text
argon studio
```

and built with:

```text
argon build
```

Keep the filesystem structure intact so the module paths remain valid after syncing.
