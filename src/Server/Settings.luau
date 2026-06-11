local Settings = {}

Settings.__index = Settings

Settings.TerrainFolder = workspace.Debris

Settings.CaveDisabledMapDIV = 300
Settings.CaveEnabledMapDIV = 70
Settings.YAxisDIV = 30
Settings.GridDIV = 3000
Settings.VoxelSize = 4

Settings.MapWidth = 300
Settings.MapBreadth = 300
Settings.Scale = 200

Settings.RenderThreadCap = 1
Settings.YAXISThreadCap = 1
Settings.GridCAP = 2

Settings.startX = -100
Settings.startZ = -100

Settings.blendThresh = 10
Settings.blendColorThresh = 4

Settings.Seed = 2
Settings.zero_thresh = 0.01

Settings.ChunkSize = 16

Settings.Lacunarity = 2
Settings.Persistance = 0.5

Settings.caves_Enabled = false

Settings.breathingTime = 0.0000001

Settings.BedRock = -100
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
        Color = Color3.new(0.066667, 0.67451, 0.12549)
    },
    [Settings.Biomes[2]] = { -- Mountains,
		Cont = NumberRange.new(0, 0.5),
        Temp = NumberRange.new(0.3, 1),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0.5, 1),
        amp  = 4,
        Color = Color3.new(0.321569, 0.25098, 0.070588)
    },
    [Settings.Biomes[3]] = { -- Desert
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.5, 1),
        Ero  = NumberRange.new(0, 0.5),
        PV   = NumberRange.new(0, 0.4),
        amp  = 1.0,
        Color = Color3.new(0.866667, 0.85098, 0.121569)
    },
    [Settings.Biomes[4]] = { -- Ice
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0, 0.3),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 0.8,
        Color = Color3.new(0.054902, 1, 0.905882)
    },
    [Settings.Biomes[5]] = { -- Savanna
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.5, 1),
        Ero  = NumberRange.new(0.5, 1),
        PV   = NumberRange.new(0, 0.4),
        amp  = 1.3,
        Color = Color3.new(0.784314, 0.627451, 0.12549)
    },
    [Settings.Biomes[6]] = { -- Tundra
        Cont = NumberRange.new(0.5, 1),
        Temp = NumberRange.new(0.3, 0.5),
        Ero  = NumberRange.new(0, 1),
        PV   = NumberRange.new(0, 0.5),
        amp  = 1.1,
        Color = Color3.new(0.431373, 0.658824, 0.784314)
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
        [0] = 0, [0.05] = 0, [0.125] = 5, [0.2] = 8,
        [0.25] = 15, [0.3] = 20, [0.375] = 22, [0.425] = 26,
        [0.5] = 5, [0.55] = 10, [0.625] = 15, [0.675] = 22,
        [0.725] = 28, [0.75] = 32, [0.85] = 50, [0.925] = 55,
        [0.975] = 64, [1] = 64
    },
    [Settings.NoiseNames.Peak] = {
        [0] = -30, [0.05] = -22, [0.125] = -18, [0.2] = -12,
        [0.25] = -9, [0.3] = -6, [0.375] = -3, [0.425] = -1,
        [0.5] = 0, [0.65] = 22, [0.725] = 40, [0.75] = 60,
        [0.85] = 62, [0.925] = 78, [0.975] = 99, [1] = 110
    },
    [Settings.NoiseNames.Eros] = {
        [0] = 5, [0.05] = 3, [0.125] = 3, [0.2] = 2,
        [0.25] = 2, [0.3] = 1, [0.375] = 1, [0.425] = 0,
        [0.5] = 0, [0.65] = -3, [0.725] = -4, [0.75] = -8,
        [0.85] = -16, [0.925] = -16, [0.975] = -19, [1] = -22
    },
    [Settings.NoiseNames.Temp] = {
        [0] = 43, [0.05] = 38, [0.125] = 25, [0.2] = 25,
        [0.25] = 18, [0.3] = 18, [0.375] = 12, [0.425] = 8,
        [0.5] = 22, [0.65] = 20, [0.725] = 15, [0.75] = 22,
        [0.85] = -14, [0.925] = -18, [0.975] = -18, [1] = -18
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