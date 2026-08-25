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
	for i, v in pairs(terrainSettings.Biomes) do
		local checkCont, contPen = terrainSettings:ValueInRange(terrainSettings.BiomeDetails[v].Cont, arr.Continentalness or 0)
		local checkTemp, tempPen = terrainSettings:ValueInRange(terrainSettings.BiomeDetails[v].Temp, arr.Temperature or 0)
		local checkErosion, eroPen = terrainSettings:ValueInRange(terrainSettings.BiomeDetails[v].Ero, arr.Erosion or 0)
		local checkPV, pvPen = terrainSettings:ValueInRange(terrainSettings.BiomeDetails[v].PV, arr.PV or 0)
		local score = contPen + tempPen + eroPen+ pvPen
		if score < bestscore then
			bestscore = score
			currBiome = v
		end
	end
	bestScoreInv = (4 - bestscore)/4
	return currBiome, bestScoreInv
end


return Painting