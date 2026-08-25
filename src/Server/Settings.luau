local Settings = {}

Settings.__index = Settings -- Don't touch this

Settings.TerrainFolder = workspace.Debris -- you can change this to wherever you want to store the whole generated terrain

Settings.CaveDisabledMapDIV = 500 -- The division by which the map will be generated 1 by 1 (600 by 600)
                                  -- NOTE: MAP SIZES SHOULD BE A MULTIPLE OF THIS

Settings.GridDIV = 600 -- The division by which the grid will be generated 1 by 1 (here 600 by 600)
                       -- NOTE: Either keep this same as MapDIV or keep it so the sizes are a multiple of this and the MAP_DIV
Settings.VoxelSize = 4 -- Size of your block (if you increase this, naturally the map will increase in size too)
Settings.useInBuiltTerrain = false -- Determines whether to use in-built terrain generater of roblox
Settings.implementBiomeScoring = true -- A way to variate the terrain, experiment with it and see what you like
Settings.vector3Size = Vector3.new(Settings.VoxelSize, Settings.VoxelSize, Settings.VoxelSize) -- for convenience

Settings.MapWidth = 500 -- Size on X-axis
Settings.MapBreadth = 500 -- Size on Z-axis
                           -- the blocks simulate terrain by changing on Y-Axis 

Settings.Scale = 500 -- Higher value means a more smooth and gradual change in terrain (and Biomes)

Settings.smoothify = false -- Determines whether the terrain should be blocky (like minecraft) or smooth. 
                           -- Cooler if false :)
Settings.smoothifyScale = Settings.Scale * Settings.VoxelSize -- smoothification naturally reduces map size so it has a different scale

Settings.RenderThreadCap = 1
Settings.GridCAP = 2 

Settings.startX = -100 -- Position X where your map will start
Settings.startZ = -100 -- Position Z where your map will start
                       -- NOTE: This is the top left Corner of your map. (StartX, StartZ)
Settings.Center = Vector2.new( -- Center of the world
			Settings.startX + Settings.MapWidth / 2,
			Settings.startZ + Settings.MapBreadth / 2
		)

Settings.Boundary = Vector2.new(Settings.startX + Settings.MapWidth / 2, Settings.startZ) -- boundary of the world
Settings.maxDistanceFromCenter =  (Settings.Boundary - Settings.Center).Magnitude

Settings.blendOn = true -- Whether you want to blend terrain (allows biomes to retain their unique terrain characteristics)
Settings.fastBlend = false -- a faster way of blending. Experiment whether you like it or not
Settings.blendThresh = 5 -- higher means more time to load, donot go past 10 or 15
Settings.fastBlendThresh = 4 -- higher means more time to load
Settings.blendColorThresh = 4 -- self-explanatory. Works a bit differently so experiment with it.

Settings.fallOff = false -- Determines whether the terrain falls off at the end
Settings.fallOffStart = 0.35  -- no falloff inside this distance (0–1)
Settings.fallOffEnd   = 1.0   -- fully suppressed at this distance
Settings.Seed = 2 -- Seed, changing this will change the terrain of map too whenever you generate it.
Settings.zero_thresh = 0.01 -- Donot touch

Settings.ChunkSize = 16 -- Increasing this will increase Chunk Size

Settings.Lacunarity = 2 
Settings.Persistance = 0.5 -- Change and experiment with it

Settings.breathingTime = 0.0000001 -- Don't touch

Settings.BedRock = -200 -- Not in use yet
Settings.AirThresh = 0.15 -- Not in use yet
Settings.CaveFreq = 4 

--/////////////////////// STEPS TO ADD BIOME DATA [2 Steps] //////////////////////

-- Step 1: Add it's name in the Biomes table
Settings.Biomes = {
    "Plains", -- an example name 1
    "Mountains", -- 2
    "Desert", -- 3
    "Ice", -- 4
    "Savanna", -- 5
    "Tundra" -- 6
}

-- Step 2: Reference it in Details by
--         its position in Table 
--         (how Plains is 1 in this case)
--         And add these details

Settings.BiomeDetails = {
    [Settings.Biomes[1]] = { -- so for reference Settings.Biomes[1] for Plains, if you want to reference savanna, it is 5
        Cont = NumberRange.new(0, 0.5), -- Add all these variables with their specific ranges (should be between 0-1)
        Temp = NumberRange.new(0, 0.3),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 1.7, -- Add the amplitude to your liking
        Color = Color3.new(0.066667, 0.67451, 0.12549), -- Add the color of terrain blocks in that biome
        Material = Enum.Material.Grass -- Add the material of the terrain blocks in that biome

        -- NOTE: DONOT CHANGE THE NAMES OF THESE VARIABLES
    },
    [Settings.Biomes[2]] = { -- Mountains,
		Cont = NumberRange.new(0, 0.5),
        Temp = NumberRange.new(0.3, 1),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0.5, 1),
        amp  = 2.3,
        Color = Color3.new(0.321569, 0.25098, 0.070588),
        Material = Enum.Material.Rock
    },
    [Settings.Biomes[3]] = { -- Desert
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.5, 1),
        Ero  = NumberRange.new(0, 0.5),
        PV   = NumberRange.new(0, 0.4),
        amp  = 1,
        Color = Color3.new(0.866667, 0.85098, 0.121569),
        Material = Enum.Material.Sand
    },
    [Settings.Biomes[4]] = { -- Ice
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0, 0.3),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 0.8,
        Color = Color3.new(0.054902, 1, 0.905882),
        Material = Enum.Material.Ice
    },
    [Settings.Biomes[5]] = { -- Savanna
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.5, 1),
        Ero  = NumberRange.new(0.5, 1),
        PV   = NumberRange.new(0, 0.4),
        amp  = 1.3,
        Color = Color3.new(0.784314, 0.627451, 0.12549),
        Material = Enum.Material.Sandstone

    },
    [Settings.Biomes[6]] = { -- Tundra
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.3, 0.5),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 1.1,
        Color = Color3.new(0.431373, 0.658824, 0.784314),
        Material = Enum.Material.Glacier

    }
}

Settings.DensityNoise = "Density"

-- /////////// NOISE DATA //////////

-- Noises influence the base terrain, they are the core of this module,
-- changing, adding or deleting one of these will influence the terrain A LOT
-- so these are very powerful parameters and tinkering them will let you
-- customize terrain a lot. Except density.

-- NOTE: Best not to remove these default noises as it might mess up generation.
-- You can, however add more noises to variate the terrain

-- ///////////////  STEPS TO ADD NOISE VALUES [3 STEPS] ////////////////////////////////

-- Step 1: Add the Noise Name here

-- NOTE: here you have a nickname for the noise (on the left) and its actual name (on the right)
Settings.NoiseNames = {
	Cont = "Continentalness", -- Example naming scheme
	Peak = "PV",
	Eros = "Erosion",
	Temp = "Temperature",
	Hum = "Humidity"
}

-- Step 2: Reference these names in this table by their nickname and add their parameters.
Settings.NoiseDetails = {
	[Settings.NoiseNames.Cont] = { -- Reference cont by its nickname
		amp = 3, -- Add all these parameters
		freq = 2,
	
	},
	[Settings.NoiseNames.Peak] = {
		amp = 500,
		freq = 4,
	
	},
	[Settings.NoiseNames.Eros] = {
		amp = -10,
		freq = 16,
	
	},
	[Settings.NoiseNames.Temp] = {
		amp = 250,
		freq = 8
	},
	[Settings.NoiseNames.Hum] = {
		amp = 1,
		freq = 32
	}
}

-- Step 3: Add these Interpolation Values
-- Reference the noise names and add a range of values (from 0-1 in any division)
-- And equal those divided values to a certain height
-- This is the crucial part that influences terrain height etc.
-- tinker with these in any way or shape to get your desired map
-- You have to add your custom noise here with its ranged heights
-- for it to have visible effect on terrain

Settings.InterpolationValues = {
    [Settings.NoiseNames.Cont] = { -- range of values with certain heights for continentalness
        [0] = 0, [0.05] = 5, [0.125] = 5, [0.2] = 10,
        [0.25] = 15, [0.3] = 20, [0.375] = 22, [0.425] = 26,
        [0.5] = 5, [0.55] = 10, [0.625] = 15, [0.675] = 28,
        [0.725] = 52, [0.75] = 52, [0.85] = 52, [0.925] = 70,
        [0.975] = 92, [1] = 108
    },
    [Settings.NoiseNames.Peak] = {
        [0] = 5, [0.05] = 10, [0.125] = 10, [0.2] = 15,
        [0.25] = 25, [0.3] = 25, [0.375] = 55, [0.425] = 88,
        [0.5] = 110, [0.65] = 110, [0.725] = 110, [0.75] = 140,
        [0.85] = 160, [0.925] = 160, [0.975] = 160, [1] = 200
    },
    [Settings.NoiseNames.Eros] = {
        [0] = 5, [0.05] = 3, [0.125] = 3, [0.2] = 2,
        [0.25] = 2, [0.3] = 1, [0.375] = 1, [0.425] = 0,
        [0.5] = 0, [0.65] = -3, [0.725] = -4, [0.75] = -8,
        [0.85] = -16, [0.925] = -16, [0.975] = -19, [1] = -22
    },
    [Settings.NoiseNames.Temp] = {
        [0] = 80, [0.05] = 68, [0.125] = 55, [0.2] = 55,
        [0.25] = 32, [0.3] = 27, [0.375] = 27, [0.425] = 20,
        [0.5] = 10, [0.65] = 10, [0.725] = 2, [0.75] = -10,
        [0.85] = -20, [0.925] = -20, [0.975] = -33, [1] = -45
    },
    [Settings.NoiseNames.Hum] = {
        [0] = -31, [0.125] = -27, [0.2] = -22, [0.25] = -18,
        [0.3] = -10, [0.375] = -10, [0.425] = -2, [0.5] = -12,
        [0.65] = -2, [0.725] = 8, [0.75] = 12, [0.85] = 17,
        [0.925] = 22, [0.975] = 28, [1] = 28
    }
}

Settings.new = function() -- dont touch
	local self = setmetatable({}, Settings)
	return self
end

function Settings:fallOffFunction(x)
    
    local s = self.fallOffStart
    local e = self.fallOffEnd

    if x <= s then return 1 end
    if x >= e then return 0 end

    local n = (x - s) / (e - s)


    return 1 - (n * n * (3 - 2 * n))
   
end

function Settings:GetInterpolatedAmpValue(val, noiseName) -- dont touch
	local interpolVals = self.InterpolationValues[noiseName]

	for i, v in pairs(interpolVals) do
		if val <= i then
			return v
		end
	end
end

function Settings:ValueInRange(Range, num) -- dont touch
	local min = Range.Min
	local max = Range.Max
	local penalty
	local exist = false
	if num >= min and num <= max then
		penalty = 0
		exist = true
	elseif num < min then
		penalty = min - num
	elseif num > max then
		penalty = num - max
	end
	return exist, penalty
end

function Settings:GetPartAttributes(part) 
	local noises = self.NoiseNames
	local Continentalness = part:GetAttribute(noises.Cont)
	local PV = part:GetAttribute(noises.Peak)
	local Erosion = part:GetAttribute(noises.Eros)
	local Temperature = part:GetAttribute(noises.Temp)
	local Humidity = part:GetAttribute(noises.Hum)
	local Density = part:GetAttribute(Settings.DensityNoise)
	return Continentalness, PV, Erosion, Temperature, Humidity, Density
end

return Settings