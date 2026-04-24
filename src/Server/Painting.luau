local terrainSettings = require("./Settings")

local Painting = {}


Painting.SetBiome = function(part)
	local Continentalness,PV,Erosion,Temperature,Humidity,Density = terrainSettings.GetPartAttributes(part)
	
end

Painting.Paint = function(part)
	if terrainSettings.caves_Enabled then
		
	else
		
	end
end

return Painting
