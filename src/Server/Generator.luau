

local Generator = {}

Generator.threadsRunning = 0
Generator.YThreadsRunning = 0
Generator.threadsCompleted =0
Generator.heightGrid = {}

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
	local n = math.noise((x/terrainSettings.Scale)* f, (z/terrainSettings.Scale) * f, terrainSettings.Seed)
	n = math.clamp(n,-0.5, 0.5)
	n += 0.5
	n*=2
	n-=1
	return n -- -1, 2 (0.00000004) * 45 = 11.22112
end

Generator.generateDensity = function(terrainSettings, x,y,z)
	local n = math.noise((x/terrainSettings.Scale) * terrainSettings.CaveFreq, (y/terrainSettings.Scale) * terrainSettings.CaveFreq, (z/terrainSettings.Scale) * terrainSettings.CaveFreq)
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

				if Generator.heightGrid[x][z].TotalHeight == nil then
					print("Nil at X: "..x..", Z: "..z.."\n")
					continue	
				end


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


				local heightDifference_ = (maxNeighborHeight - currentHeight)
				local heightDifference = math.abs(heightDifference_)

				if heightDifference == 0 then
					part = Generator.createPart(terrainSettings, x,0,z)
					local new_Height = currentHeight 
					part.CFrame = CFrame.new(
						Vector3.new(
							x * terrainSettings.VoxelSize, 
							new_Height, 
							z * terrainSettings.VoxelSize
						)
					)
					Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
					part.Parent = n_chunk


				elseif heightDifference > terrainSettings.VoxelSize then
					-- Extend this part to fill the gap

					local t_parts = heightDifference_/terrainSettings.VoxelSize

					local partY = (currentHeight + maxNeighborHeight) / 2

					local new_Height


					if partY%(terrainSettings.VoxelSize) ~= 0 then
						partY -= (terrainSettings.VoxelSize/2)
					end

					for i  = 0, t_parts, 1 do
						new_Height = partY + (terrainSettings.VoxelSize*(i-2))

						part = Generator.createPart(terrainSettings, x,0,z, i)
						part.CFrame = CFrame.new(
							Vector3.new(x * terrainSettings.VoxelSize, new_Height, z * terrainSettings.VoxelSize)
						)
						part.Parent = n_chunk
						Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
					end

				else
					--Normal part for small height differences

					part = Generator.createPart(terrainSettings, x,0,z)
					local new_Height = currentHeight 
					part.CFrame = CFrame.new(
						Vector3.new(
							x * terrainSettings.VoxelSize, 
							new_Height, 
							z * terrainSettings.VoxelSize
						)
					)
					Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
					part.Parent = n_chunk


					new_Height = currentHeight + terrainSettings.VoxelSize
					part = Generator.createPart(terrainSettings,x,0,z, 1)
					part.CFrame = CFrame.new(
						Vector3.new(
							x * terrainSettings.VoxelSize, 
							new_Height, 
							z * terrainSettings.VoxelSize
						)
					)

					Generator.setAttributes(terrainSettings, part, Generator.heightGrid[x][z], Generator.heightGrid[x][z].Density)
					part.Parent = n_chunk

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
		for x = startW, endW do
			if Generator.heightGrid[x] == nil then
				Generator.heightGrid[x] = {}
			end
			for z = startB, endB do

				local c_Y = 0

				if Generator.heightGrid[x][z] == nil then
					Generator.heightGrid[x][z] = {}
				end
				local count = 0
				for i, v in terrainSettings.NoiseNames do
					count+=1

					local noiseCharacteristics = terrainSettings.NoiseDetails[v]
					local noise_Y = Generator.generateHeight(terrainSettings, x,z,noiseCharacteristics.freq)

					Generator.heightGrid[x][z][v] = noise_Y

					if noiseCharacteristics.inverse == true then
						noise_Y =math.abs(noise_Y)
					end

					noise_Y *= (noiseCharacteristics.amp * (terrainSettings.Persistance^count-1)) 
					c_Y += noise_Y

				end


				c_Y = math.floor(c_Y/terrainSettings.VoxelSize)
				c_Y -= c_Y%terrainSettings.VoxelSize
				local density_p = Generator.generateDensity(terrainSettings, x, c_Y, z)
				Generator.heightGrid[x][z]["TotalHeight"] = c_Y
				Generator.heightGrid[x][z]["Density"] = density_p

			end
			if (x%(terrainSettings.VoxelSize * 50) == 0) then
				task.wait()
			end
		end
		Generator.threadsRunning-=1
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
