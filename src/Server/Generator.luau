local Painting = require(script.Parent.Painting)

local Generator = {}

Generator.threadsRunning = 0
Generator.YThreadsRunning = 0
Generator.threadsCompleted =0
Generator.heightGrid = {}

-- Simple 4-neighbor color blend, no radius loop
function Generator.blendColorSimple(terrainSettings, x, z, startW, endW, startB, endB)
    local heightGrid = Generator.heightGrid
    local biomeDetails = terrainSettings.BiomeDetails

    local ownBiome = heightGrid[x][z]["Biome"]
    local ownColor = biomeDetails[ownBiome].Color

    local r, g, b = ownColor.R, ownColor.G, ownColor.B
    local samples = 1
	local blendThresh = terrainSettings.blendColorThresh
    local neighbors = {
        (x > startW) and heightGrid[x-blendThresh] and heightGrid[x-blendThresh][z],
        (x < endW)   and heightGrid[x+blendThresh] and heightGrid[x+blendThresh][z],
        (z > startB) and heightGrid[x][z-blendThresh],
        (z < endB)   and heightGrid[x][z+blendThresh],
    }

    for _, neighbor in ipairs(neighbors) do
        if neighbor and neighbor["Biome"] and neighbor["Biome"] ~= "" then
            local col = biomeDetails[neighbor["Biome"]].Color
            r += col.R
            g += col.G
            b += col.B
            samples += 1
        end
    end

    return Color3.new(r / samples, g / samples, b / samples)
end

Generator.createPart = function(terrainSettings, x, y, z, i)
	local part = Instance.new("Part")
	
	if i == nil then
		part.Name = tostring(x).."_"..tostring(y).."_"..tostring(z)
	else
		part.Name = tostring(x).."_"..tostring(y).."_"..tostring(z).."_("..tostring(i)..")"
	end
	part.Material = Enum.Material.Plastic
	part.Size = Vector3.new(terrainSettings.VoxelSize, terrainSettings.VoxelSize, terrainSettings.VoxelSize)
	part.Anchored = true
	return part
end

Generator.setAttributes = function(terrainSettings, part, array, dens) 
	for i, v in pairs(terrainSettings.NoiseNames) do
		part:SetAttribute(v, array[v])
	end
	part:SetAttribute("Density", dens)
	part:SetAttribute("Biome", array.Biome)
	part.Color = array.Color
	part.Material = terrainSettings.BiomeDetails[array.Biome].Material
end

Generator.createChunk = function(terrainSettings, x,y,z)
	local newChunk
	local v_x = math.floor(x/terrainSettings.ChunkSize)
	local v_y = math.floor(y/terrainSettings.ChunkSize)
	local v_z = math.floor(z/terrainSettings.ChunkSize)

	local name = v_x.."_"..v_y.."_"..v_z
	
	newChunk = Instance.new("Model")
	newChunk.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	newChunk.Name = name
	newChunk.Parent = terrainSettings.TerrainFolder
	return newChunk
end

Generator.getChunk = function(terrainSettings, x,y,z)
	local newChunk
	local name
	local v_x = math.floor(x/terrainSettings.ChunkSize)
	local v_y = math.floor(y/terrainSettings.ChunkSize)
	local v_z = math.floor(z/terrainSettings.ChunkSize)

	name = v_x.."_"..v_y.."_"..v_z
	newChunk = terrainSettings.TerrainFolder:FindFirstChild(name)
	
	if newChunk == nil then
		newChunk = Generator.createChunk(terrainSettings, x,y,z)
	end

	return  newChunk
end


Generator.generateHeight = function(terrainSettings, x,z,f)
	local scale = terrainSettings.Scale
	if terrainSettings.smoothify then
		scale = terrainSettings.smoothifyScale
	end
	local n = math.noise((x/scale)* f, (z/scale) * f, terrainSettings.Seed)
	n = math.clamp(n,-0.5, 0.5)
	n += 0.5
	return n -- -1, 2 (0.00000004) * 45 = 11.22112
end

Generator.generateDensity = function(terrainSettings, x,y,z)
	local scale = terrainSettings.Scale
	if terrainSettings.smoothify then
		scale = terrainSettings.smoothifyScale
	end
	local n = math.noise((x/scale) * terrainSettings.CaveFreq, (y/scale) * terrainSettings.CaveFreq, (z/scale) * terrainSettings.CaveFreq)
	n = math.clamp(n,-0.5, 0.5)
	n += 0.5
	return n
end

Generator.generateDivision = function(terrainSettings, startW, endW, startB, endB)
	Generator.threadsRunning += 1

	task.spawn(function()
		for x = startW, endW do
			for z = startB, endB do
				local n_chunk = Generator.getChunk(terrainSettings, x,0,z)
				local B_h
				local F_h
				local R_h
				local L_h
				local part
				local currArr = Generator.heightGrid[x][z]
				
				if Generator.heightGrid[x][z].TotalHeight == nil then
					print("Nil at X: "..x..", Z: "..z.."\n")
					continue	
				end

				local color = Generator.blendColorSimple(terrainSettings, x, z, startW, endW, startB, endB)
				currArr.Color = color
				local currentHeight = Generator.heightGrid[x][z].TotalHeight
				local maxNeighborHeight = currentHeight
				local minNeighbotHeight = currentHeight

				if x > startW then
					B_h = Generator.heightGrid[x-1][z].TotalHeight
					maxNeighborHeight = math.max(maxNeighborHeight, B_h)
					minNeighbotHeight = math.max(minNeighbotHeight, B_h)
				end
				if x < endW then
					F_h = Generator.heightGrid[x+1][z].TotalHeight
					maxNeighborHeight = math.max(maxNeighborHeight, F_h)
					minNeighbotHeight = math.max(minNeighbotHeight, F_h)
				end
				if z > startB then
					L_h = Generator.heightGrid[x][z-1].TotalHeight
					maxNeighborHeight = math.max(maxNeighborHeight, L_h)
					minNeighbotHeight = math.max(minNeighbotHeight, L_h)
				end
				if z < endB then
					R_h = Generator.heightGrid[x][z+1].TotalHeight
					maxNeighborHeight = math.max(maxNeighborHeight, R_h)
					minNeighbotHeight = math.max(minNeighbotHeight, R_h)
				end

				local currX = x
				local currZ = z 

				if not terrainSettings.smoothify then
					currX *= terrainSettings.VoxelSize
					currZ *= terrainSettings.VoxelSize
				end

				local heightDifference_ = (maxNeighborHeight - currentHeight)
				local heightDifference = math.abs(heightDifference_)


				if heightDifference == 0 then
					local new_Height = currentHeight 
					
					if terrainSettings.useInBuiltTerrain then
						workspace.Terrain:FillBlock(CFrame.new(
						Vector3.new(
							currX, 
							new_Height, 
							currZ
							)
						), terrainSettings.vector3Size, terrainSettings.BiomeDetails[currArr.Biome].Material)
					else
						part = Generator.createPart(terrainSettings, x,0,z)
						part.CFrame = CFrame.new(
						Vector3.new(
							currX, 
							new_Height, 
							currZ
							)
						)
						Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
						part.Parent = n_chunk
					end


				elseif heightDifference > terrainSettings.VoxelSize then
					-- Extend this part to fill the gap

					local t_parts = math.ceil(heightDifference/terrainSettings.VoxelSize)

					local partY = currentHeight

					local new_Height


					if partY%(terrainSettings.VoxelSize) ~= 0 then
						partY -= (terrainSettings.VoxelSize/2)
					end

					for i  = 0, t_parts-1, 1 do
						new_Height = partY + (terrainSettings.VoxelSize*(i))

						if terrainSettings.useInBuiltTerrain then
							workspace.Terrain:FillBlock(CFrame.new(
								Vector3.new(
								currX, 
								new_Height, 
								currZ
								)
							), terrainSettings.vector3Size, terrainSettings.BiomeDetails[currArr.Biome].Material)
						else
							part = Generator.createPart(terrainSettings, x,0,z, i)
							part.CFrame = CFrame.new(
							Vector3.new(
								currX, 
								new_Height, 
								currZ
								)
							)
							Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
							part.Parent = n_chunk
						end
					end

				else
					--Normal part for small height differences
					
					local new_Height = currentHeight 
					if terrainSettings.useInBuiltTerrain then
						workspace.Terrain:FillBlock(CFrame.new(
							Vector3.new(
									currX, 
									new_Height, 
									currZ
								)
						), terrainSettings.vector3Size, terrainSettings.BiomeDetails[currArr.Biome].Material)
						
						workspace.Terrain:FillBlock(CFrame.new(
							Vector3.new(
								currX, 
								new_Height, 
								currZ
								)
						), terrainSettings.vector3Size, terrainSettings.BiomeDetails[currArr.Biome].Material)
					else
						part = Generator.createPart(terrainSettings, x,0,z)
						part.CFrame = CFrame.new(
						Vector3.new(
								currX, 
								new_Height, 
								currZ
								)
						)
						Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
						part.Parent = n_chunk

						new_Height = currentHeight + terrainSettings.VoxelSize
						part = Generator.createPart(terrainSettings,x,0,z, 1)
						part.CFrame = CFrame.new(
							Vector3.new(
								currX, 
								new_Height, 
								currZ
								)
						)

						Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
						part.Parent = n_chunk
					end

				end

			end
			if (x%(terrainSettings.VoxelSize * 50)) then
				task.wait()
			end
		end

		Generator.threadsRunning-=1
		Generator.threadsCompleted+=1
	end)
	
end

Generator.genereateGRID_Division = function(terrainSettings, startW, endW, startB, endB)
	task.spawn(function()
		local center = Vector2.new(
			terrainSettings.startX + terrainSettings.MapWidth / 2,
			terrainSettings.startZ + terrainSettings.MapBreadth / 2
		)
		local maxDistCenter = (center - Vector2.new(terrainSettings.startX, terrainSettings.startZ)).Magnitude

		local heightGrid = Generator.heightGrid
		local biomeDetails = terrainSettings.BiomeDetails
		local noiseDetails = terrainSettings.NoiseDetails
		local noiseNames = terrainSettings.NoiseNames
		local voxelSize = terrainSettings.VoxelSize
		local invVoxel = 1 / voxelSize
		local smoothify = terrainSettings.smoothify
		local yieldEvery = voxelSize * 50

		local function snapVoxel(v)
			return math.floor(v * invVoxel) * voxelSize
		end

		-- ─── Pass 1: Generate height grid ───────────────────────────────────────
		for x = startW, endW do
			if not heightGrid[x] then heightGrid[x] = {} end
			local gridX = heightGrid[x]

			local cx = x - center.X
			for z = startB, endB do
				if not gridX[z] then gridX[z] = {} end
				local cell = gridX[z]

				local currVec2 = Vector2.new(x,z)
				local currDistFromCenter = (currVec2-center).Magnitude
				local currDistInv = currDistFromCenter/maxDistCenter
				local fallOffValue = terrainSettings:fallOffFunction(currDistInv)
				local c_Y = 0
				local c_Y_ =0 
				local totalNoise = 0

				for _, v in noiseNames do
					local nc = noiseDetails[v]
					local noise_Y = Generator.generateHeight(terrainSettings, x, z, nc.freq)
					cell[v] = noise_Y
					totalNoise += noise_Y
					c_Y  += terrainSettings:GetInterpolatedAmpValue(noise_Y, v)
					c_Y_ += noise_Y * nc.amp
				end

				if terrainSettings.fallOff then
					c_Y  *= fallOffValue
					c_Y_ *= fallOffValue
				end

				local density_p = Generator.generateDensity(terrainSettings, x, c_Y, z)
				local norm = Generator.generateHeight(terrainSettings, x, z, 1)

				cell.TotalNoise = totalNoise
				cell.Density = density_p
				cell.NormalNoise = norm

				local biome, score = Painting.SetBiome(cell, terrainSettings)
				cell.Biome = biome

				if terrainSettings.implementBiomeScoring then
					c_Y  *= score
					c_Y_ *= score
				end

				cell.RawHeight = smoothify and c_Y  or snapVoxel(c_Y)
				cell.TotalHeight = smoothify and c_Y_ or snapVoxel(c_Y_)
				cell.Color = biomeDetails[biome].Color
			end

			if x % yieldEvery == 0 then task.wait() end
		end

		if terrainSettings.blendOn then
			if terrainSettings.fastBlend then
				local blendRadius = terrainSettings.fastBlendThresh
				local yieldEveryBlend = voxelSize * 10
				local tempGrid = {}
				
				for x = startW, endW do
					local gridX = heightGrid[x]
					if not gridX then continue end
					tempGrid[x] = {}
					local tempX = tempGrid[x]

					for z = startB, endB do
						if not gridX[z] then continue end

						local totalWeight, blendedAmp = 0, 0

						for nx = math.max(startW, x - blendRadius), math.min(endW, x + blendRadius) do
							local neighbor = heightGrid[nx] and heightGrid[nx][z]
							if not neighbor then continue end
							local biome = neighbor.Biome
							if not biome or biome == "" then continue end

							local dx = nx - x
							local w = 1 / (dx * dx + 0.5)
							blendedAmp  += biomeDetails[biome].amp * w
							totalWeight += w
						end

						if totalWeight > 0 then
							tempX[z] = blendedAmp / totalWeight
						end
					end
					if x % yieldEveryBlend == 0 then task.wait() end
				end

				for x = startW, endW do
					local gridX = heightGrid[x]
					if not gridX then continue end
					local tempX = tempGrid[x]
					if not tempX then continue end

					for z = startB, endB do
						local cell = gridX[z]
						if not cell then continue end

						local totalWeight, blendedAmp = 0, 0

						for nz = math.max(startB, z - blendRadius), math.min(endB, z + blendRadius) do
							local t = tempX[nz]
							if not t then continue end

							local dz = nz - z
							local w = 1 / (dz * dz + 0.5)
							blendedAmp  += t * w
							totalWeight += w
						end

						local c_Y
						if totalWeight > 0 then
							c_Y = cell.RawHeight * (blendedAmp / totalWeight)
						else
							c_Y = cell.RawHeight * biomeDetails[cell.Biome].amp
						end

						cell.TotalHeight = smoothify and c_Y or snapVoxel(c_Y)
					end

					if x % yieldEveryBlend == 0 then task.wait() end
				end
			else
				local blendRadius = terrainSettings.blendThresh
				for x = startW, endW do
					local gridX = Generator.heightGrid[x]
					
					for z = startB, endB do
						if not gridX or not gridX[z] then continue end

						local xMin = math.max(startW, x - blendRadius)
						local xMax = math.min(endW, x + blendRadius)
						local zMin = math.max(startB, z - blendRadius)
						local zMax = math.min(endB, z + blendRadius)
						local currVec2 = Vector2.new(x,z)
						local totalWeight = 0
						local blendedAmp = 0
						local r, g, b = 0, 0, 0

						for nx = xMin, xMax do
							local gridNX = Generator.heightGrid[nx]
							if not gridNX then continue end
							local dx = nx - x
							local dxSq = dx * dx

							for nz = zMin, zMax do
								local currVec2N = Vector2.new(nx,nz)
								local neighbor = gridNX[nz]
								local distSQRt = (currVec2N - currVec2).Magnitude
								if not neighbor then continue end

								local neighborBiome = neighbor["Biome"]
								if not neighborBiome or neighborBiome == "" then continue end

								
								local distSq = dxSq + (nz - z) * (nz - z)
								local w = 1 / (distSq + 0.5)

								local details = terrainSettings.BiomeDetails[neighborBiome]
								blendedAmp += details.amp * w

								local col = details.Color
								r += col.R * w
								g += col.G * w
								b += col.B * w

								totalWeight += w
							end
						end

						local cell = gridX[z]

						if totalWeight > 0 then
							local invTotal = 1 / totalWeight
							local c_Y = cell["RawHeight"] * (blendedAmp * invTotal)
							if not terrainSettings.smoothify then
								c_Y = math.round(c_Y / terrainSettings.VoxelSize) * terrainSettings.VoxelSize
							end 
							cell["TotalHeight"] = c_Y
							
						else
							local c_Y = cell["RawHeight"] * terrainSettings.BiomeDetails[cell["Biome"]].amp
							if not terrainSettings.smoothify then
								c_Y = math.floor(c_Y / terrainSettings.VoxelSize) * terrainSettings.VoxelSize
								c_Y -= c_Y%terrainSettings.VoxelSize
							end

							cell["TotalHeight"] = c_Y
						end
					end

					if (x % (terrainSettings.VoxelSize * 20) == 0) then
						task.wait()
					end
				end
			end
		end

		Generator.threadsRunning -= 1
	end)
end

Generator.generateTerrain = function(terrainSettings )
	
	
	local generating = false
	local mapBreadthPer = math.ceil(terrainSettings.MapBreadth / terrainSettings.GridDIV)
	local remainingMapBreadth = terrainSettings.MapBreadth % terrainSettings.GridDIV
	local mapWidthPer = math.ceil(terrainSettings.MapWidth / terrainSettings.GridDIV)
	local remainingMapWidth = terrainSettings.MapWidth % terrainSettings.GridDIV
	local totalDiv = mapWidthPer * mapBreadthPer
	
	print("================== Initializing Terrain Grid ======================")
	print("Total Divisions: ",  totalDiv)
	print("Total Width Divisions: ", mapWidthPer)
	print("Total Breadth Divisions: ", mapBreadthPer)
	
	
	if mapBreadthPer <= 1 and mapWidthPer <=1  then
		Generator.threadsRunning+=1
		
		Generator.genereateGRID_Division(terrainSettings, terrainSettings.startX, (terrainSettings.MapWidth+terrainSettings.startX), terrainSettings.startZ, (terrainSettings.MapBreadth + terrainSettings.startZ))
		
	else
		
		print("-----------------------------------------------")
		local div_no = 0
		for i = 1, mapWidthPer,1 do
		
			local startW = terrainSettings.startX
			local endW = (terrainSettings.GridDIV * i) + terrainSettings.startX
			if i ~= 1 then
				startW = (terrainSettings.GridDIV * (i-1)) + 1 + terrainSettings.startX
			end
			if math.abs(startW - endW) < terrainSettings.GridDIV then
				endW = terrainSettings.MapWidth + terrainSettings.startX
			end

			local v = 1
			while v <= mapBreadthPer  do
				local startB = terrainSettings.startZ
				local endB = (terrainSettings.GridDIV * v) + terrainSettings.startZ

				if v ~= 1 then
					startB = (terrainSettings.GridDIV * (v-1)) + 1 + terrainSettings.startZ
				end
				if math.abs(startB - endB) < terrainSettings.GridDIV then
					endW = terrainSettings.MapBreadth + terrainSettings.startZ
				end

				if Generator.threadsRunning >= terrainSettings.GridCAP then
					--print("Threads: ", Generator.threadsRunning)
					repeat task.wait() until Generator.threadsRunning == 0
					v-=1
				else
					Generator.threadsRunning+=1
					Generator.genereateGRID_Division(terrainSettings, startW,endW, startB,endB)
					
					print("Running Division/Total Divisions : "..(div_no).."/"..totalDiv)
					
					
				end
				v+=1
				div_no+=1
			end
				
		end
	end
	
	--print("Threads: ", Generator.threadsRunning)
	repeat task.wait(terrainSettings.breathingTime) until Generator.threadsRunning == 0
	print("================== GRID INITIALIZED! ==================\n")
	
	mapBreadthPer = math.ceil(terrainSettings.MapBreadth / terrainSettings.CaveDisabledMapDIV)
	remainingMapBreadth = terrainSettings.MapBreadth % terrainSettings.CaveDisabledMapDIV
	mapWidthPer = math.ceil(terrainSettings.MapWidth / terrainSettings.CaveDisabledMapDIV)
	remainingMapWidth = terrainSettings.MapWidth % terrainSettings.CaveDisabledMapDIV
	totalDiv = mapWidthPer * mapBreadthPer
	
	print("================== RENDERING TERRAIN =================")
	
	local div_no = 0
	if mapBreadthPer <=1 and mapWidthPer <=1 then
		div_no+=1
		Generator.generateDivision(terrainSettings, terrainSettings.startX, terrainSettings.MapWidth + terrainSettings.startX, terrainSettings.startZ, terrainSettings.MapBreadth + terrainSettings.startZ)

	else
			
		for i = 1, mapWidthPer,1 do

			local startW = terrainSettings.startX
			local endW = (terrainSettings.CaveDisabledMapDIV * i) + terrainSettings.startX
			if i ~= 1 then
				startW = (terrainSettings.CaveDisabledMapDIV * (i-1)) + 1 + terrainSettings.startX
				
			end
			if math.abs(startW - endW) < terrainSettings.CaveDisabledMapDIV then
				endW = terrainSettings.MapWidth + terrainSettings.startX
			end

			for v = 1, mapBreadthPer, 1  do

				local startB = terrainSettings.startZ
				local endB = (terrainSettings.CaveDisabledMapDIV * v) + terrainSettings.startZ

				if v ~= 1 then
					startB = (terrainSettings.CaveDisabledMapDIV * (v-1)) + 1 + terrainSettings.startZ
				end
				
				if math.abs(startB - endB) < terrainSettings.CaveDisabledMapDIV then
					endW = terrainSettings.MapBreadth + terrainSettings.startZ
				end
				if Generator.threadsRunning >= terrainSettings.RenderThreadCap then

					repeat
						print("Running Division/Total Divisions : "..(div_no).."/"..totalDiv)
						task.wait()
					until Generator.threadsRunning == 0
					
					div_no+=1
					Generator.generateDivision(terrainSettings, startW,endW,startB,endB)
					
				else
					div_no+=1	
					print("Running Division/Total Divisions : "..(div_no).."/"..totalDiv)
					
					Generator.generateDivision(terrainSettings, startW,endW,startB,endB)
				

				end
			end

		end
	end

		
	
	repeat print("Running Division/Total Divisions : "..(div_no).."/"..totalDiv); task.wait() until Generator.threadsRunning == 0
	
	Generator.heightGrid = {}

	print("================== TERRAIN RENDERED! ==================\n")
	
end


return Generator