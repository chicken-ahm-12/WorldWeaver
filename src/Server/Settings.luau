--[[
Copyright 2026 WorldWeaver by chicken-ahm-12

Github: chicken-ahm-12

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
]]

local Settings = {}

Settings.__index = Settings -- Don't touch this

Settings.TerrainFolder = workspace.Debris -- you can change this to wherever you want to store the whole generated terrain

Settings.Scale = 500 -- Higher value means a more smooth and gradual change in terrain (and Biomes)
Settings.Seed = 2 -- Seed, changing this will change the terrain of map too whenever you generate it.
Settings.zero_thresh = 0.01 -- Donot touch
Settings.ChunkSize = 16 -- Increasing this will increase Chunk Size

Settings.Persistance = 0.45 -- Higher value means more ragged/spiky terrain
                           -- Lower value means more flat and smoother terrain

Settings.startX = -100 -- Position X where your map will start
Settings.startZ = -100 -- Position Z where your map will start
                       -- NOTE: This is the top left Corner of your map. (StartX, StartZ)

Settings.MapWidth = 500 -- Size on X-axis
Settings.MapBreadth = 500 -- Size on Z-axis
                           -- the blocks simulate terrain by changing on Y-Axis 

Settings.Center = Vector2.new( -- Center of the world
			Settings.startX + Settings.MapWidth / 2,
			Settings.startZ + Settings.MapBreadth / 2
		)

Settings.breathingTime = 0.0000001 -- Don't touch

Settings.CaveDisabledMapDIV = 500 -- The division by which the map will be generated 1 by 1 (600 by 600)
                                  -- NOTE: MAP SIZES SHOULD BE A MULTIPLE OF THIS

Settings.GridDIV = 600 -- The division by which the grid will be generated 1 by 1 (here 600 by 600)
                       -- NOTE: Either keep this same as MapDIV or keep it so the sizes are a multiple of this and the MAP_DIV
Settings.VoxelSize = 4 -- Size of your block (if you increase this, naturally the map will increase in size too)
Settings.useInBuiltTerrain = false -- Determines whether to use in-built terrain generater of roblox
                                   -- You can increase the size that roblox can handle at a moment using this
                                   -- but see if you like the look
Settings.implementBiomeScoring = false -- A way to variate the terrain, experiment with it and see what you like
Settings.vector3Size = Vector3.new(Settings.VoxelSize, Settings.VoxelSize, Settings.VoxelSize) -- for convenience
Settings.smoothify = false -- Determines whether the terrain should be blocky (like minecraft) or smooth. 
Settings.smoothifyScale = Settings.Scale * 2 -- you can set a different scale aswell
Settings.smoothificationFactor = Settings.VoxelSize - 0.001
Settings.smoothificationSize = Settings.vector3Size + Vector3.new(Settings.smoothificationFactor,Settings.smoothificationFactor,Settings.smoothificationFactor)

Settings.sharperBiomes = true -- Just means biome boundaries will look more defined even when blend is on
Settings.sharpnessBiomeDefactor = 1 -- Higher means less sharp boundary betweenbiomes

Settings.RenderThreadCap = 1
Settings.GridCAP = 2 

Settings.Boundary = Vector2.new(Settings.startX + Settings.MapWidth / 2, Settings.startZ) -- boundary of the world
Settings.maxDistanceFromCenter =  (Settings.Boundary - Settings.Center).Magnitude

Settings.blendOn = true -- Whether you want to blend terrain (allows biomes to retain their unique terrain characteristics)
Settings.fastBlend = true -- a faster way of blending. Experiment whether you like it or not
Settings.blendThresh = 10 -- higher means more time to load, donot go past 10 or 15
Settings.fastBlendThresh = 4 -- higher means more time to load
Settings.blendColorThresh = 4 -- self-explanatory. Works a bit differently so experiment with it.

Settings.fallOff = false -- Determines whether the terrain falls off at the end
Settings.fallOffStart = 0.35  -- no falloff inside this distance (0–1)
Settings.fallOffEnd   = 1.0   -- fully suppressed at this distance

Settings.BedRock = -200 -- Not in use yet
Settings.CaveFreq = 4 

--/////////////////////// STEPS TO ADD BIOME DATA [2 Steps] //////////////////////

-- Step 1: Add it's name in the Biomes table
Settings.Biomes = {
    "Plains", -- an example name 1
    "Mountains", -- 2
    "Desert", -- 3
    "Ice", -- 4
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
        amp  = 3.7,
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

-- NOTE: here you have a nickname for the noise (on the left) and its actual name and priority (on the right)
-- FORMAT: Nickname = {Name, Priority}
-- Priority means which noise will be most relevant in setting the base terrain (Due to how persistance works).
-- It is descending, meaning smaller integers (starting from 1) will have higher priority.
Settings.NoiseNames = {
	Cont = {"Continentalness",1}, -- Example naming scheme
	Peak = {"PV",4},
	Eros = {"Erosion",2},
	Temp = {"Temperature",5},
	Hum = {"Humidity",3}
}

-- Step 2: Reference these names in this table by their nickname and add their parameters.
Settings.NoiseDetails = {
	[Settings.NoiseNames.Cont[1]] = { -- Reference cont by its nickname [1] means the first value of the table Cont (its name)
		amp = 4, -- Add all these parameters
		freq = 2,
	
	},
	[Settings.NoiseNames.Peak[1]] = {
		amp = 250,
		freq = 4,
	
	},
	[Settings.NoiseNames.Eros[1]] = {
		amp = -Settings.VoxelSize,
		freq = 16,
	
	},
	[Settings.NoiseNames.Temp[1]] = {
		amp = 20,
		freq = 8
	},
	[Settings.NoiseNames.Hum[1]] = {
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
    [Settings.NoiseNames.Cont[1]] = { -- range of values with certain heights for continentalness
        [0] = 0, [0.05] = 5, [0.125] = 5, [0.2] = 10,
        [0.25] = 15, [0.3] = 20, [0.375] = 20, [0.425] = 20,
        [0.5] = 5, [0.55] = 10, [0.625] = 10, [0.675] = 28,
        [0.725] = 32, [0.75] = 32, [0.85] = 46, [0.925] = 55,
        [0.975] = 68, [1] = 68
    },
    [Settings.NoiseNames.Peak[1]] = {
        [0] = 50, [0.05] = 68, [0.125] = 68, [0.2] = 77,
        [0.25] = 82, [0.3] = 96, [0.375] = 105, [0.425] = 105,
        [0.5] = 130, [0.65] = 130, [0.725] = 130, [0.75] = 152,
        [0.85] = 170, [0.925] = 180, [0.975] = 180, [1] = 194
    },
    [Settings.NoiseNames.Eros[1]] = {
        [0] = 5, [0.05] = 3, [0.125] = 3, [0.2] = 2,
        [0.25] = 2, [0.3] = 2, [0.375] = 0, [0.425] = 0,
        [0.5] = 0, [0.65] = -3, [0.725] = -8, [0.75] = -8,
        [0.85] = -16, [0.925] = -16, [0.975] = -16, [1] = -22
    },
    [Settings.NoiseNames.Temp[1]] = {
        [0] = 80, [0.05] = 68, [0.125] = 55, [0.2] = 55,
        [0.25] = 55, [0.3] = 37, [0.375] = 37, [0.425] = 37,
        [0.5] = 22, [0.65] = 10, [0.725] = 10, [0.75] = -5,
        [0.85] = -20, [0.925] = -20, [0.975] = -33, [1] = -33
    },
    [Settings.NoiseNames.Hum[1]] = {
        [0] = -31, [0.125] = -27, [0.2] = -27, [0.25] = -18,
        [0.3] = -10, [0.375] = -10, [0.425] = -12, [0.5] = -12,
        [0.65] = -12, [0.725] = 1, [0.75] = 8, [0.85] = 8,
        [0.925] = 17, [0.975] = 28, [1] = 28
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


function Settings:BuildCache()
    self._interpCache = {}
    self._noiseCache = {}

    for nickname, props in pairs(self.NoiseNames) do
        self._noiseCache[props[2]] = nickname
    end

    for noiseName, tbl in pairs(self.InterpolationValues) do
        local keys = {}
        for k in pairs(tbl) do table.insert(keys, k) end
        table.sort(keys)
        self._interpCache[noiseName] = keys
    end
end

function Settings:GetInterpolatedAmpValue(val, noiseName)
    local interpolVals = self.InterpolationValues[noiseName]
    local keys = self._interpCache[noiseName]

    local prevKey, prevVal = nil, nil
    for _, k in ipairs(keys) do
        local v = interpolVals[k]
        if val <= k then
            if prevKey == nil then return v end
            local t = (val - prevKey) / (k - prevKey)
            return prevVal + (v - prevVal) * t
        end
        prevKey = k
        prevVal = v
    end
    return prevVal
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