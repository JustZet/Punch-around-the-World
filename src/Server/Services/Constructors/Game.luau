local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Arena = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)

local PlayerModule = require(ServerScriptService.Server.Modules.PlayerModule)
local WeaponModule = require(ServerScriptService.Server.Modules.WeaponModule)
local ArenaService = require(ServerScriptService.Server.Services.Constructors.Arena)

local GameModule = require(ServerScriptService.Server.Modules.GameModule)

local Game = {}
Game.__index = Game
Game.Actions = {
    MATCH_STARTED = "MatchStarted",
    MATCH_ENDED = "MatchEnded",
    PLAYER_JOINED = "PlayerJoined",
    PLAYER_LEFT = "PlayerLeft",
	PLAYER_DIED = "PlayerDied",
}

export type Game = {
    arena: Arena.Arena,
	arenaService: ArenaService.ArenaService,
	team1: { Player },
    team2: { Player },
	duration: number,
    startTime: number?,
	endTime: number?,
}

-- Constructor
function Game.new(data: Game): Game?
	local self = setmetatable({}, Game)
	-- Copy data fields directly

	if not data or not data.arena or not data.team1 or not data.team2 then
		return nil
	end
	self.arena = data.arena
	self.team1 = data.team1
	self.team2 = data.team2
	self.listeners = {}
	-- Now you can use self.arena etc.


	-- local creatorUserId = self.team1[1] and self.team1[1].UserId or 0
	self.arenaService = ArenaService.new(self.arena, self.team1, self.team2)
	if not self.arenaService then 
		return nil 
	end

	self.startTime = os.time()
	self.duration = 300 
	self.endTime = self.startTime + self.duration

	local gameStarted = self:startMatch()
	if gameStarted == true then
		return self
	else
		return nil
	end
end

function Game:Destroy()
	if self.arenaService then
		self.arenaService:Destroy()
		self.arenaService = nil
	end

	self.listeners = nil
    self.team1 = nil
    self.team2 = nil
    self.arena = nil
end

-- region Action listeners
function Game:on(eventName: string, callback: (...any) -> ())
	if not self.listeners[eventName] then
		self.listeners[eventName] = {}
	end
	table.insert(self.listeners[eventName], callback)
end

function Game:emit(eventName: string, ...)
	local callbacks = self.listeners[eventName]
	if callbacks then
		for _, cb in ipairs(callbacks) do
			task.spawn(cb, ...) -- async trigger
		end
	end
end

-- endregion


-- region Actions
function Game:startMatch(): boolean
	self.arenaService:spawnTeams(self.team1, self.team2)

	self:bindDeathHandlers()
	self:startCountDown()
	self:freezePlayers(3)

	for _, team in ipairs({self.team1, self.team2}) do
		for _, player in ipairs(team) do
			PlayerModule.set(player, PlayerEnum.DEATHS, 0)
			PlayerModule.set(player, PlayerEnum.LIVES, 3)
			PlayerModule.set(player, PlayerEnum.HP, 100)
			PlayerModule.set(player, PlayerEnum.KILLS, 0)
			PlayerModule.set(player, PlayerEnum.IN_MATCH, true)
		end
	end

	self:_notifyGameStart()

	task.delay(self.duration, function()
		self:endMatch()
	end)
	return true
end

function Game:endMatch(): boolean
	for _, team in ipairs({self.team1, self.team2}) do
		for _, player in ipairs(team) do
			PlayerModule.set(player, PlayerEnum.DEATHS, nil)
			PlayerModule.set(player, PlayerEnum.LIVES, nil)
			PlayerModule.set(player, PlayerEnum.HP, nil)
			PlayerModule.set(player, PlayerEnum.KILLS, nil)
			PlayerModule.set(player, PlayerEnum.IN_MATCH, false)
		end
	end

	self:_notifyGameEnd()
	self:Destroy()
	return true
end


function Game:startCountDown()
	local countdownTexts = {"3", "2", "1", "Punch!"}

	for i, text in ipairs(countdownTexts) do
		task.delay(i - 1, function()
			for _, player in ipairs(self:getAllPlayers()) do
				ReplicatedStorage.RemoteEvents.Game.CountDown:FireClient(player, true, text)
			end

			-- Hide the label right after "Punch!" for cleaner UI
			if text == "Punch!" then
				task.delay(1, function()
					for _, player in ipairs(self:getAllPlayers()) do
						ReplicatedStorage.RemoteEvents.Game.CountDown:FireClient(player, false)
					end
					self:startGameTimeLeft()
				end)
			end
		end)
	end
end
function Game:startGameTimeLeft()
	task.spawn(function()
		while true do
			local now = os.time()
			local remaining = self.endTime - now
			if remaining <= 0 then break end

			local minutes = math.floor(remaining / 60)
			local seconds = math.floor(remaining % 60)
			local formatted = string.format("%02d:%02d", minutes, seconds)

			for _, player in ipairs(self:getAllPlayers()) do
				ReplicatedStorage.RemoteEvents.Game.GameTimeLeft:FireClient(player, true, formatted)
			end

			task.wait(1)
		end
	end)
end


function Game:freezePlayers(seconds: number)
    for _, team in ipairs({self.team1, self.team2}) do
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
-- endregion


-- region Getters
function Game:getAllPlayers()
	return table.move(self.team1, 1, #self.team1, 1, table.clone(self.team2))
end
-- endregion


-- region Listeners
function Game:_onPlayerDied(player: Player)
	local currentLives = PlayerModule.get(player, PlayerEnum.LIVES) or 0
	local newLives = currentLives - 1
	PlayerModule.set(player, PlayerEnum.LIVES, newLives)

	if newLives > 0 then
		-- Respawn after short delay
		task.delay(3, function()
			if player and player.Parent then
				player:LoadCharacter()
				task.wait(0.5)
				self.arenaService:spawnPlayer(player)
			end
		end)
	else
		PlayerModule.set(player, PlayerEnum.IN_MATCH, false)
		-- TO DO: Add spectator logic
		warn(player.Name .. " is now out of lives!")

		-- Example: Transition to spectator
		-- self:makeSpectator(player)
	end
end
-- endregion


-- region Binders
function Game:bindDeathHandlers()
	for _, team in ipairs({self.team1, self.team2}) do
		for _, player in ipairs(team) do
			local function bind()
				local character = player.Character
				if not character then return end

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Died:Connect(function()
						self:_onPlayerDied(player)
					end)
				end
			end

			-- If character exists now
			if player.Character then
				bind()
			end

			-- In case character spawns later
			player.CharacterAdded:Connect(function()
				task.wait(0.2) -- small wait to ensure humanoid exists
				bind()
			end)
		end
	end
end
-- endregion


-- region Notifiers
function Game:_notifyGameStart()
	GameModule.addGame(self)
	self:emit(Game.Actions.MATCH_STARTED, self)
	for _, team in ipairs({self.team1, self.team2}) do
		for _, player in ipairs(team) do
			ReplicatedStorage.RemoteEvents.Game.GameStarted:FireClient(player, self.team1, self.team2)
		end
	end
	GameModule.addGame(self)
end

function Game:_notifyGameEnd()
	self:emit(Game.Actions.MATCH_ENDED, self)
	for _, team in ipairs({self.team1, self.team2}) do
		for _, player in ipairs(team) do
			ReplicatedStorage.RemoteEvents.Game.GameEnded:FireClient(player, self.team1, self.team2)
		end
	end
	GameModule.removeGame(self)
end
-- endregion
return Game