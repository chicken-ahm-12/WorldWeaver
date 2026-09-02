local WorldWeaver = script.Parent.WorldWeaver
local Settings = require(WorldWeaver.Settings)
local Generator = require(WorldWeaver.Generator)

local settings = Settings.new()

-- Tune your map here.
settings.Seed = 42
settings.MapWidth = 500
settings.MapBreadth = 500
settings.startX = -250
settings.startZ = -250

-- Required after changing interpolation/noise configuration.
settings:BuildCache()

Generator.generateTerrain(settings)
