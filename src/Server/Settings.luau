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
		[-2] = 0, [-1.8] = 0, [-1.5] = 5, [-1.2] = 8,
		[-1] = 15, [-0.8] = 20, [-0.5] = 22, [-0.3] = 26,
		[0] = 5, [0.2] = 10, [0.5] = 15, [0.7] = 22,
		[0.9] = 28, [1] = 32, [1.4] = 50, [1.7] = 55,
		[1.9] = 64, [2] = 64
	},
	[Settings.NoiseNames.Peak] = {
		[-2] = -30, [-1.8] = -22, [-1.5] = -18, [-1.2] = -12,
		[-1] = -9, [-0.8] = -6, [-0.5] = -3, [-0.3] = -1,
		[0] = 0, [0.6] = 22, [0.9] = 40, [1] = 60,
		[1.4] = 62, [1.7] = 78, [1.9] = 99, [2] = 110
	},
	[Settings.NoiseNames.Eros] = {
		[-2] = 5, [-1.8] = 3, [-1.5] = 3, [-1.2] = 2,
		[-1] = 2, [-0.8] = 1, [-0.5] = 1, [-0.3] = 0,
		[0] = 0, [0.6] = -3, [0.9] = -4, [1] = -8,
		[1.4] = -16, [1.7] = -16, [1.9] = -19, [2] = -22
	},
	[Settings.NoiseNames.Temp] = {
		[-2] = 43, [-1.8] = 38, [-1.5] = 25, [-1.2] = 25,
		[-1] = 18, [-0.8] = 18, [-0.5] = 12, [-0.3] = 8,
		[0] = 22, [0.6] = 20, [0.9] = 15, [1] = 22,
		[1.4] = -14, [1.7] = -18, [1.9] = -18, [2] = -18
	},
	[Settings.NoiseNames.Hum] = {
		[-2] = -31, [-1.5] = -27, [-1.2] = -22, [-1] = -18,
		[-0.8] = -10, [-0.5] = -10, [-0.3] = -2, [0] = -12,
		[0.6] = -2, [0.9] = 8, [1] = 12, [1.4] = 17,
		[1.7] = 22, [1.9] = 28, [2] = 28
	}
}

Settings.new = function()
	local self = setmetatable({}, Settings)
	return self
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