local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlayerModule = require(ServerScriptService.Server.Modules.PlayerModule)
local WeaponModule = require(ServerScriptService.Server.Modules.WeaponModule)

local Arena = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)

local ArenaService = {}
ArenaService.__index = ArenaService

export type ArenaService = {
	arena: Arena.Arena,
	fileName: string,
	creator: Player,
	team1: { Player },
	team2: { Player },
	arenaTemplate: Instance?,
	arenaInstance: Instance?,
	gameFolder: Folder?,
}

ArenaService.Actions = {
	MATCH_STARTED = "MatchStarted",
	MATCH_ENDED = "MatchEnded",
	PLAYER_JOINED = "PlayerJoined",
	PLAYER_LEFT = "PlayerLeft",
	PLAYER_DIED = "PlayerDied",
}

function ArenaService.new(arena: Arena.Arena, team1: { Player }, team2: { Player })
	local self = setmetatable({}, ArenaService)

	self.listeners = {}
	self.team1 = team1
	self.team2 = team2
	self.arena = arena
	self.creator = self.team1[1] and self.team1[1] or nil
	if not self.arena then
		return nil
	end
	if not self.creator then
		return nil
	end
	self.arenaTemplate = ServerStorage.Arenas:FindFirstChild(arena.FileName)
	self.arenaInstance = nil
	self.gameFolder = self:createFolder()
	if not self.gameFolder then
		return nil
	end

	WeaponModule.enableSpawningWeapons(self.arenaInstance, self.arena.FileName)
	self:enableKillSurfaces()

	return self
end

function ArenaService:Destroy()
	if self.arenaInstance then
		self.arenaInstance:Destroy()
		self.arenaInstance = nil
	end
	if self.gameFolder then
		self.gameFolder:Destroy()
		self.gameFolder = nil
	end
end

-- region Action listeners
function ArenaService:on(eventName: string, callback: (...any) -> ())
	if not self.listeners[eventName] then
		self.listeners[eventName] = {}
	end
	table.insert(self.listeners[eventName], callback)
end

function ArenaService:emit(eventName: string, ...)
	local callbacks = self.listeners[eventName]
	if callbacks then
		for _, cb in ipairs(callbacks) do
			task.spawn(cb, ...) -- async trigger
		end
	end
end
-- endregion

function ArenaService:createFolder(): Folder?
	if not self.arenaTemplate then
		warn("Arena template not found:", self.arenaTemplate)
		return nil
	end

	self.fileName = "Game_" .. self.arena.FileName .. "_" .. tostring(self.creator.UserId)

	local gamesFolder = workspace:FindFirstChild("Games")
	if not gamesFolder then
		gamesFolder = Instance.new("Folder")
		gamesFolder.Name = "Games"
		gamesFolder.Parent = workspace
	end

	local existing = gamesFolder:FindFirstChild(self.fileName)
	if existing then
		warn("Arena already active:", self.fileName)
		return nil
	end

	local folder = Instance.new("Folder")
	folder.Name = self.fileName
	folder.Parent = gamesFolder

	local arenaClone = self.arenaTemplate:Clone()
	arenaClone.Name = "ActiveArena"
	arenaClone.Parent = folder

	self.arenaInstance = arenaClone
	self.gameFolder = folder

	return folder
end

function ArenaService:spawnTeam(players: { Player }, spawnFolder: Folder)
	local spawnPoints = spawnFolder:GetChildren()
	table.sort(spawnPoints, function(a, b)
		return a.Name < b.Name
	end)

	for i, player in ipairs(players) do
		local spawn = spawnPoints[i]
		if spawn then
			PlayerModule.moveCharacterTo(player, spawn.Position)
		end
	end
end
function ArenaService:spawnTeams(team1: { Player }, team2: { Player })
	if not self.arenaInstance then
		return
	end

	local spawnsFolder = self.arenaInstance:FindFirstChild("SpawnSurfaces")
	if not spawnsFolder then
		warn("Missing spawns folder in arena:", self.FileName)
		return
	end

	local team1Spawns = spawnsFolder:FindFirstChild("Team1")
	local team2Spawns = spawnsFolder:FindFirstChild("Team2")

	if not team1Spawns or not team2Spawns then
		warn("Missing team spawns in arena:", self.FileName)
		return
	end

	self:spawnTeam(team1, team1Spawns)
	self:spawnTeam(team2, team2Spawns)
end

function ArenaService:spawnPlayer(player: Player)
	local spawnFolder = self:getPlayerTeamFolder(player)
	if spawnFolder then
		local spawnPoints = spawnFolder:GetChildren()
		local spawn = spawnPoints[1]
		if spawn then
			player:LoadCharacter()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character:MoveTo(spawn.Position)
			end
			-- PlayerModule.moveCharacterTo(player, spawn.Position)
		end
	else
		warn("Spawn folder not found for player:", player.Name)
	end
end

function ArenaService:enableKillSurfaces()
	if not self.arenaInstance then
		return
	end

	local killFolder = self.arenaInstance:FindFirstChild("KillSurfaces")
	if not killFolder then
		return
	end

	for _, part in ipairs(killFolder:GetChildren()) do
		if part:IsA("BasePart") and not part:GetAttribute("KillTouchConnected") then
			part.Touched:Connect(function(hit)
				local character = hit:FindFirstAncestorOfClass("Model")
				if character and character:FindFirstChild("Humanoid") then
					local player = Players:GetPlayerFromCharacter(character)
					if player then
						character.Humanoid.Health = 0
						task.delay(2, function()
							self:spawnPlayer(player)
						end)
					end
				end
			end)
			part:SetAttribute("KillTouchConnected", true)
		end
	end
end

function ArenaService:freezePlayers(seconds: number)
	for _, team in ipairs({ self.team1, self.team2 }) do
		for _, player in ipairs(team) do
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					-- Store original speeds to restore later
					local originalWalkSpeed = humanoid.WalkSpeed
					local originalJumpPower = humanoid.JumpPower

					-- Freeze movement
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0

					task.delay(seconds, function()
						if humanoid then
							humanoid.WalkSpeed = originalWalkSpeed
							humanoid.JumpPower = originalJumpPower
						end
					end)
				end
			end
		end
	end
end

-- region Getters
function ArenaService:getPlayerTeamFolder(player: Player): Folder?
	if not self.arenaInstance then
		return nil
	end
	local spawnSurfaces = self.arenaInstance:FindFirstChild("SpawnSurfaces")
	if not spawnSurfaces then
		return nil
	end

	if self.team1 and table.find(self.team1, player) then
		return spawnSurfaces:FindFirstChild("Team1")
	elseif self.team2 and table.find(self.team2, player) then
		return spawnSurfaces:FindFirstChild("Team2")
	else
		return nil
	end
end
-- endregion

return ArenaService
