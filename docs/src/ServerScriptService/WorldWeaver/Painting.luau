--[[
Copyright 2026 WorldWeaver by chicken-ahm-12

Github: chicken-ahm-12

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
]]

local Painting = {}

Painting.SetBiome = function(arr, terrainSettings)
	local bestscore = math.huge
	local bestScoreInv = math.huge
	local currBiome
	local iterationPassed = false
	local totals =0
	for v = 1, #terrainSettings.Biomes do
		local biomeName = terrainSettings.Biomes[v]
		local Biome_arr = terrainSettings.BiomeDetails[biomeName]
		local score = 0
		for n = 1, #terrainSettings._noiseCache do
		local noiseNickName = terrainSettings._noiseCache[n]
		local noiseName = terrainSettings.NoiseNames[noiseNickName][1]
		local exist, Penalty = terrainSettings:ValueInRange(Biome_arr[noiseName], arr[noiseName] or 0)
			if exist then
				if not iterationPassed then
					totals +=1
				end
				score += Penalty
			end
		end
		iterationPassed = true
		if score < bestscore then
			bestscore = score
			currBiome = biomeName
		end
	end
	bestScoreInv = (totals - bestscore)/totals
	return currBiome, bestScoreInv
end


return Painting