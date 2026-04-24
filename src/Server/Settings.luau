

local Settings = {}

Settings.__index = Settings -- DONOT Touch this

Settings.TerrainFolder = workspace.Debris -- The folder in which the terrain will be stored

Settings.CaveDisabledMapDIV = 600 -- Map Division when Rendering without Caves (600 * 600 blocks will be rendered first before moving on to the next)
Settings.CaveEnabledMapDIV = 70 -- Map Division for Rendering (1 by 1) When Caves Are Enabled (Has no functionality yet)
Settings.YAxisDIV = 30 -- (Division for when loading Caves, Not in Use)
Settings.GridDIV = 3000 -- This much blocks (3000 * 3000) will have their data loaded before before the next batch, 3000 * 3000 is unrealistic as nobody would have such a huge map

Settings.VoxelSize = 4 -- Size of a single block

Settings.MapWidth = 200 -- The actual Width (X) of the map (multiply this by your voxel size) to get the actual length
Settings.MapBreadth = 200 -- The Actual  Breadth (Y) of the map (multiply this by your voxel size) to get the actual length
Settings.Scale = 200 -- How smooth the terrain should be, lower values result in sharp changes, higher in smoother

Settings.RenderThreadCap = 1 -- How many Divisions of Map to Render at Once (1 for best performance)
Settings.YAXISThreadCap = 1-- How many Divisions of Y-axis to Render at Once (1 for best performance)
Settings.GridCAP = 2 -- How many Divisions of Grid to Render at Once (1 for best performance)

Settings.startX = -100 -- starting point of your map (X)
Settings.startZ = -100 --starting point of your map (Y)

-- pie (1200) ^ 2

Settings.Seed = 2 -- Changing this value will result in a different map
Settings.zero_thresh = 0.01 -- not your concern

Settings.ChunkSize = 16 -- increase or decreasing this might impact performance (A map is made up of chunks that are made of blocks)

Settings.Lacunarity = 2 -- initial frequency
Settings.Persistance = 0.5 --  If the amplitude decreases or increases

Settings.caves_Enabled = false -- self-exp

Settings.breathingTime = 0.0000001 -- lowest time smth smth dw

Settings.BedRock = -100 -- Where the world ends (on y-axis)
Settings.AirThresh = 0.15 -- below which or equal to it is air
Settings.CaveFreq = 4 -- Self Exp



-- 5
-- If you add more Noise Details (in noise map) make sure to add its name to Noise Names as well
-- It will automatically implement in terrain
Settings.NoiseNames = {
	Cont = "Continentalness",
	Peak = "PV",
	Eros = "Erosion",
	Temp = "Temperature",
	Hum = "Humidity"
	-- Example add "Moisture"
}

Settings.DensityNoise = "Density"

Settings.NoiseDetails = {
	[Settings.NoiseNames.Cont] = {
		amp = 3, -- Affects Height
		inverse = false, -- Affects if it goes in inverse (lower means higher, high means low)
		freq = 2, -- how frequently the change is supposed to happen
		pow=1	
	},
	[Settings.NoiseNames.Peak]= {
		amp = 250,
		inverse = false,
		freq = 2,
		pow=1
	},
	[Settings.NoiseNames.Eros]= {
		amp = -10,
		inverse = false,
		freq = 10,
		pow=1
	},
	[Settings.NoiseNames.Temp] = {
		amp = -20,
		inverse = false,
		freq = 8
	},
	[Settings.NoiseNames.Hum] = {
		amp = 0,
		inverse = false,
		freq = 32
	}
	
	-- [Settings.NoiseNames.Moisture] = {
--        amp = 0, inv=false, freq = 10}
}

--- //////////// FOR FUTURE UPDATES (NOT IN USE YET)

Settings.InterpolationValues = {
	[Settings.NoiseNames.Cont] = {
		[-2] = 0,
		[-1.8] = 0,
		[-1.5] = 5,
		[-1.2] = 8,
		[-1] = 15,
		[-0.8] = 20,
		[-0.5] = 22,
		[-0.3] = 26,
		[0] = 5,
		[0.2] = 10,
		[0.5] = 15,
		[0.7] = 22,
		[0.9] = 28,
		[1] = 32,
		[1.4] = 50,
		[1.7] = 55,
		[1.9] = 64,
		[2] = 64		
	},
	[Settings.NoiseNames.Peak]= {
		[-2] = -30,
		[-1.8] = -22,
		[-1.5] = -18,
		[-1.2] = -12,
		[-1] = -9,
		[-0.8] = -6,
		[-0.5] = -3,
		[-0.3] = -1,
		[0] = 0,
		[0.6] = 22,
		[0.9] = 40,
		[1] = 60,
		[1.4] = 62,
		[1.7] = 78,
		[1.9] = 99,
		[2] = 110
	},
	[Settings.NoiseNames.Eros] = {
		[-2] = 5,
		[-1.8] = 3,
		[-1.5] = 3,
		[-1.2] = 2,
		[-1] = 2,
		[-0.8] = 1,
		[-0.5] = 1,
		[-0.3] = 0,
		[0] = 0,
		[0.6] = -3,
		[0.9] = -4,
		[1] = -8,
		[1.4] = -16,
		[1.7] = -16,
		[1.9] = -19,
		[2] = -22
	},
	[Settings.NoiseNames.Temp] = {
		[-2] = 43,
		[-1.8] = 38,
		[-1.5] = 25,
		[-1.2] = 25,
		[-1] = 18,
		[-0.8] = 18,
		[-0.5] = 12,
		[-0.3] = 8,
		[0] = 22,
		[0.6] = 20,
		[0.9] = 15,
		[1] = 22,
		[1.4] = -14,
		[1.7] = -18,
		[1.9] = -18,
		[2] = -18
	},
	[Settings.NoiseNames.Hum] = {
		[-2] = -31,
		[-1.5] = -27,
		[-1.2] = -22,
		[-1] = -18,
		[-0.8] = -10,
		[-0.5] = -10,
		[-0.3] = -2,
		[0] = -12,
		[0.6] = -2,
		[0.9] = 8,
		[1] = 12,
		[1.4] = 17,
		[1.7] = 22,
		[1.9] = 28,
		[2] = 28
	}
}
	
--/// MISCELLANOUS FUNCTIONS

Settings.new = function()
	local self = setmetatable({}, Settings)
	return self
end

function Settings:ValueInRange(Range, num)
	local min = Range.min
	local max = Range.max
	local exist
	
	if num >= min and num <= max then
		exist = true
	else
		exist = false
	end
	return exist
end

function Settings:GetPartAttributes(part)
	local noises = Settings.NoiseNames
	local Continentalness = part:GetAttribute(noises.Cont)
	local PV = part:GetAttribute(noises.Peak)
	local Erosion = part:GetAttribute(noises.Eros)
	local Temperature = part:GetAttribute(noises.Temp)
	local Humidity = part:GetAttribute(noises.Hum)
	local Density = part:GetAttribute(Settings.DensityNoise)

	return Continentalness,PV,Erosion,Temperature,Humidity,Density
end


return Settings
