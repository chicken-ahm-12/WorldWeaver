local TweenService = game:GetService("TweenService")
local Settings = {}

Settings.__index = Settings

Settings.TerrainFolder = workspace.Debris

Settings.CaveDisabledMapDIV = 600
Settings.CaveEnabledMapDIV = 70
Settings.YAxisDIV = 30
Settings.GridDIV = 3000
Settings.VoxelSize = 4
Settings.useInBuiltTerrain = false
Settings.implementBiomeScoring = true
Settings.vector3Size = Vector3.new(Settings.VoxelSize, Settings.VoxelSize, Settings.VoxelSize)

Settings.MapWidth = 600
Settings.MapBreadth = 600
Settings.Scale = 200

Settings.smoothify = false
Settings.smoothifyScale = Settings.Scale * Settings.VoxelSize

Settings.RenderThreadCap = 1
Settings.YAXISThreadCap = 1
Settings.GridCAP = 2

Settings.startX = -100
Settings.startZ = -100

Settings.blendOn = true
Settings.blendThresh = 10
Settings.blendColorThresh = 4

Settings.fallOff = false
Settings.fallFactor = 0.5 -- How early do you want to fall off? lower = closer to edge
Settings.fallThresh = 50
Settings.fallDist = math.abs(Vector2.new(Settings.MapWidth/2, Settings.MapBreadth/2).Magnitude - Settings.fallThresh)

Settings.Seed = 2
Settings.zero_thresh = 0.01

Settings.ChunkSize = 16

Settings.Lacunarity = 2
Settings.Persistance = 0.5

Settings.caves_Enabled = false

Settings.breathingTime = 0.0000001

Settings.BedRock = -200
Settings.AirThresh = 0.15
Settings.CaveFreq = 4

Settings.Biomes = {
    "Plains",
    "Mountains",
    "Desert",
    "Ice",
    "Savanna",
    "Tundra"
}
Settings.BiomeDetails = {
    [Settings.Biomes[1]] = { -- Plains
        Cont = NumberRange.new(0, 0.5),
        Temp = NumberRange.new(0, 0.3),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 1.7,
        Color = Color3.new(0.066667, 0.67451, 0.12549),
        Material = Enum.Material.Grass
    },
    [Settings.Biomes[2]] = { -- Mountains,
		Cont = NumberRange.new(0, 0.5),
        Temp = NumberRange.new(0.3, 1),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0.5, 1),
        amp  = 3,
        Color = Color3.new(0.321569, 0.25098, 0.070588),
        Material = Enum.Material.Rock
    },
    [Settings.Biomes[3]] = { -- Desert
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.5, 1),
        Ero  = NumberRange.new(0, 0.5),
        PV   = NumberRange.new(0, 0.4),
        amp  = 1.0,
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

Settings.NoiseNames = {
	Cont = "Continentalness",
	Peak = "PV",
	Eros = "Erosion",
	Temp = "Temperature",
	Hum = "Humidity"
}

Settings.DensityNoise = "Density"

Settings.NoiseDetails = {
	[Settings.NoiseNames.Cont] = {
		amp = 3,
		inverse = false,
		freq = 2,
		pow = 1
	},
	[Settings.NoiseNames.Peak] = {
		amp = 1000,
		inverse = false,
		freq = 4,
		pow = 1
	},
	[Settings.NoiseNames.Eros] = {
		amp = -10,
		inverse = false,
		freq = 16,
		pow = 1
	},
	[Settings.NoiseNames.Temp] = {
		amp = 300,
		inverse = false,
		freq = 8
	},
	[Settings.NoiseNames.Hum] = {
		amp = 0,
		inverse = false,
		freq = 32
	}
}

Settings.InterpolationValues = {
    [Settings.NoiseNames.Cont] = {
        [0] = 0, [0.05] = 5, [0.125] = 5, [0.2] = 10,
        [0.25] = 15, [0.3] = 20, [0.375] = 22, [0.425] = 26,
        [0.5] = 5, [0.55] = 10, [0.625] = 15, [0.675] = 28,
        [0.725] = 28, [0.75] = 52, [0.85] = 80, [0.925] = 80,
        [0.975] = 120, [1] = 150
    },
    [Settings.NoiseNames.Peak] = {
        [0] = 5, [0.05] = 10, [0.125] = 10, [0.2] = 150,
        [0.25] = 25, [0.3] = 25, [0.375] = 55, [0.425] = 88,
        [0.5] = 110, [0.65] = 110, [0.725] = 140, [0.75] = 170,
        [0.85] = 200, [0.925] = 200, [0.975] = 250, [1] = 290
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

Settings.new = function()
	local self = setmetatable({}, Settings)
	return self
end

function Settings:fallOffFunction(x)
    -- Ease out for now, you can change it however you like
    --return 1- ((6*math.pow(x, 5)) - (15*math.pow(x, 4)) + (10*math.pow(x, 3)))
    return math.exp(-Settings.fallFactor * x)

   
end

function Settings:GetInterpolatedAmpValue(val, noiseName)
	local interpolVals = Settings.InterpolationValues[noiseName]

	for i, v in pairs(interpolVals) do
		if val <= i then
			return v
		end
	end
end

function Settings:ValueInRange(Range, num)
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
	local noises = Settings.NoiseNames
	local Continentalness = part:GetAttribute(noises.Cont)
	local PV = part:GetAttribute(noises.Peak)
	local Erosion = part:GetAttribute(noises.Eros)
	local Temperature = part:GetAttribute(noises.Temp)
	local Humidity = part:GetAttribute(noises.Hum)
	local Density = part:GetAttribute(Settings.DensityNoise)
	return Continentalness, PV, Erosion, Temperature, Humidity, Density
end

function Settings:cubicBezier(p0, p1, p2, p3, t)
	return (1 - t)^3 * p0 + 3 * (1 - t)^2 * t * p1 + 3 * (1 - t) * t^2 * p2 + t^3 * p3
end

return Settings