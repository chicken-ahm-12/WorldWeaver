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



Painting.Paint = function(part, terrainSettings)
	if terrainSettings.caves_Enabled then

	else

	end
end

return Painting