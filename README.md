# WorldWeaver

A powerful terrain generation tool that lets you generate terrain procedurally. It provides you with an extensive set of settings that allows you to generate the type of terrian you want, with the type of biomes you want, with the items you want, similar to how minecraft works.

# Getting Started

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

# Best Practices

### Size should equal

There are size parameters that control the size of your terrain:
```lua
Settings.MapWidth = 600
Settings.MapBreadth = 600
```
The best practice that ensures your terrain generates without hiccups would be
to make these values equal, that is:
```lua
Settings.MapWidth = 300
Settings.MapBreadth = 300
```
their values should be same.

### Size should be a multiple of division
This setting is what controls how much area (in this case 600 by 600) will be generated in a single moment:
```lua
Settings.CaveDisabledMapDIV = 600 -- or 300 whatever you like
```
Make sure your width and breath are a multiple of this (in our case a multiple of 600):
```lua
Settings.MapWidth = 600 -- or 1200 or 1800
Settings.MapBreadth = 600 -- or 1200 or 1800 
```
or it should be less than the division itself
```lua
Settings.MapWidth = 300 -- or 175 or 500
Settings.MapBreadth = 300 -- or 175 or 500
```

### Don't go for too many blocks
if the size is too large (like 1200 by 1200) roblox will
have a hard time closing and or will lag after a good while in run-time

the best way to deal with this would be to create your own
chunk loader and unloader that generates a certain chunk and 
ungenerates other (this might come in future updates)

In any case a size of 600 by 600 or 800 by 800 is a very big map in of itself
so you don't need to worry about that in first place.


# Snapshots

![Generated_Terrain](snapshots\image.png)


