local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local WeaponsFolder = ServerStorage:WaitForChild("Weapons")
local Arenas = require(game.ReplicatedStorage.Shared.Modules.Arenas)

local WeaponModule = {}
WeaponModule.spawnCooldown = 30 -- seconds between spawns
WeaponModule.activeSpawns = {} -- [arenaName] = { spawned weapons }


function WeaponModule.findWeaponModelById(id)
	for _, weaponModel in ipairs(WeaponsFolder:GetChildren()) do
		local weaponIDValue = weaponModel:FindFirstChild("WeaponID")
		if weaponIDValue and weaponIDValue.Value == id then
			return weaponModel
		end
	end
	return nil
end

-- Selects a random weapon from the arena’s weapon config
function WeaponModule.getRandomWeapon(arenaName: string): Model?
	local arenaData = Arenas.get(arenaName)
	if not arenaData then
		warn("Arena data not found for", arenaName)
		return nil
	end

	local weapons = arenaData.Weapons
	if #weapons == 0 then
		warn("No weapons configured for arena:", arenaName)
		return nil
	end

	local chosenWeapon = weapons[math.random(1, #weapons)]
	return WeaponModule.findWeaponModelById(chosenWeapon.ID)
end

-- Get random position on a weapon spawn surface
function WeaponModule.getRandomPositionOnSurface(surface: BasePart): Vector3
	local size = surface.Size
	local position = surface.Position

	local x = position.X + (math.random() - 0.5) * size.X
	local z = position.Z + (math.random() - 0.5) * size.Z
	local y = position.Y + 0.5 -- Slightly above surface to avoid clipping

	return Vector3.new(x, y, z)
end

-- Spawns a weapon model in arena at a random position
function WeaponModule.spawnWeapon(arenaInstance: Model, arenaName: string)
	local surfaceFolder = arenaInstance:FindFirstChild("WeaponSpawnSurfaces")
	if not surfaceFolder then
		warn("No WeaponSpawnSurfaces folder found in", arenaInstance.Name)
		return
	end

	local surface = surfaceFolder:FindFirstChild("WeaponSpawnSurface")
	if not surface or not surface:IsA("BasePart") then
		warn("WeaponSpawnSurface not found or invalid in", arenaInstance.Name)
		return
	end

	local weaponModel = WeaponModule.getRandomWeapon(arenaName)
	if not weaponModel then
		return
	end

	local clone = weaponModel:Clone()
	clone:PivotTo(CFrame.new(WeaponModule.getRandomPositionOnSurface(surface)))
	clone.Parent = arenaInstance
	WeaponModule.createCarrier(clone)

	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")

	if primaryPart then
		-- Ensure it's unanchored
		primaryPart.Anchored = false

		-- Optional: Make it massless (gravity will not act strongly)
		primaryPart.Massless = true

		-- Apply BodyVelocity
		local bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(0, -2, 0) -- VERY slow fall
		bv.MaxForce = Vector3.new(0, math.huge, 0) -- Apply force in Y only
		bv.P = 1250
		bv.Name = "SlowFall"
		bv.Parent = primaryPart

		-- Optional: Keep it upright
		local bg = Instance.new("BodyGyro")
		bg.CFrame = primaryPart.CFrame
		bg.MaxTorque = Vector3.new(400000, 400000, 400000)
		bg.P = 3000
		bg.Parent = primaryPart

		-- Remove after 2 seconds
		task.delay(2, function()
			if bv and bv.Parent then bv:Destroy() end
			if bg and bg.Parent then bg:Destroy() end
		end)
	end

	WeaponModule.activeSpawns[arenaName] = WeaponModule.activeSpawns[arenaName] or {}
	table.insert(WeaponModule.activeSpawns[arenaName], clone)

	-- Optionally handle weapon pickup/despawn → respawn logic
	-- You can customize this for when a player picks up the weapon
end

-- Spawns weapons repeatedly with cooldown
function WeaponModule.enableSpawningWeapons(arenaInstance: Model, arenaName: string)
	coroutine.wrap(function()
		while arenaInstance and arenaInstance.Parent do
			print("spawning weapon")
			WeaponModule.spawnWeapon(arenaInstance, arenaName)
			task.wait(WeaponModule.spawnCooldown)
		end
	end)()
end

-- Optional cleanup function
function WeaponModule.cleanupWeapons(arenaName: string)
	if WeaponModule.activeSpawns[arenaName] then
		for _, weapon in ipairs(WeaponModule.activeSpawns[arenaName]) do
			if weapon and weapon.Parent then
				weapon:Destroy()
			end
		end
		WeaponModule.activeSpawns[arenaName] = nil
	end
end


function WeaponModule.createCarrier(model, startOffset, fallSpeed, targetY)
	startOffset = startOffset or Vector3.new(0, 10, 0)
	fallSpeed = fallSpeed or 5
	targetY = targetY or 5

	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then
		warn("Model has no PrimaryPart or BasePart for carrier")
		return
	end

	-- Create carrier part
	local carrier = Instance.new("Part")
	carrier.Size = Vector3.new(4, 1, 4)
	carrier.Position = primaryPart.Position + startOffset
	carrier.Transparency = 1
	carrier.Anchored = true
	carrier.CanCollide = false
	carrier.Name = "CarrierPart"
	carrier.Parent = workspace

	-- Weld model’s primary part to carrier
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = carrier
	weld.Part1 = primaryPart
	weld.Parent = carrier

	-- Position model relative to carrier (optional)
	primaryPart.CFrame = carrier.CFrame * CFrame.new(0, 1, 0)

	-- Smoothly move carrier down to targetY

	local connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		if carrier.Position.Y > targetY then
			carrier.CFrame = carrier.CFrame - Vector3.new(0, fallSpeed * deltaTime, 0)
		else
			-- Stop moving
			connection:Disconnect()

			-- Remove weld to free the model
			weld:Destroy()

			-- Unanchor model part so it behaves normally
			primaryPart.Anchored = false

			-- Clean up carrier
			carrier:Destroy()
		end
	end)
end


return WeaponModule
