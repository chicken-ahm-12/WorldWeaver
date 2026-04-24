# WorldWeaver

A powerful terrain generation tool that lets you generate terrain procedurally. It provides you with an extensive set of settings that allows you to generate the type of terrian you want, with the type of biomes you want, with the items you want, similar to how minecraft works.

## Getting Started

### Create a script
First create a script and make variables linking to the Modules Settings and Generator:

```lua
local Settings = require(path_to_settings_module)
local Generator = require(path_to_generator_module)
```
### Create a settings object

Initialize a Settings object by running:

```lua
local new_Settings = Settings.new()
```

This ensures you can make different settings (such as different size, amplitudes, etc)
for different chunks of terrain at different places in your map (if thats what you are going for)

### Generate Terrain

```lua
Generator.generateTerrain(new_Settings)
```
voila! run the script and watch your terrain generate realtime!

