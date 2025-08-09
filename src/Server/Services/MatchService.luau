local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local GameModeEnum = require(ReplicatedStorage.Shared.Enums.GameModeEnum)
local MatchQueueModule = require(script.Parent.Parent.Modules.MatchQueueModule)
local ClasicGameModes = require(ReplicatedStorage.Shared.Assets.GameModes.ClasicGameModes)
local ArenaService = require(script.Parent.ArenaService)
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local EventModule = require(ReplicatedStorage.Shared.Modules.EventModule)
local PartyModule = require(script.Parent.Parent.Modules.PartyModule)

local Shared = {}

function Shared.init()
end

function Shared.start()
	ReplicatedStorage.RemoteEvents.Lobby.GameSelectionConfirmed.OnServerEvent:Connect(function(player, mode: GameMode.GameMode)
		for _, definedMode: GameMode.GameMode in pairs(ClasicGameModes) do
			if mode.Id == definedMode.Id then
				local leaderId, party = PartyModule.getPartyByPlayer(player)

		
				if mode.TeamPlayerCount > 1 then
					EventModule.Remote.PartyShow:FireClient(player, mode)
					if party then
						EventModule.Remote.PartyUpdated:FireClient(player, party.Members, mode)
					else
						EventModule.Remote.PartyUpdated:FireClient(player, { player }, mode)
					end
				else
					Shared.handleMatchmakingForMode(player, definedMode)
				end
				break
			end
		end
	end)

	ReplicatedStorage.RemoteEvents.Lobby.MatchQueueStarted.OnServerEvent:Connect(function(player, gameMode: GameMode.GameMode)
		Shared.handleMatchmakingForMode(player, gameMode)
	end)
	ReplicatedStorage.RemoteEvents.Lobby.MatchQueueCanceled.OnServerEvent:Connect(function(player, gameMode: GameMode.GameMode)
		MatchQueueModule.removeFromQueue(gameMode.Value, player)
	end)
end

-- function Shared.handleMatchmakingForMode(player: Player, gameMode: GameMode.GameMode)
-- 	if MatchQueueModule.addToQueue(gameMode.Value, player) then
-- 		ReplicatedStorage.RemoteEvents.Lobby.MatchQueueStarted:FireClient(player, gameMode)

-- 		local queue = MatchQueueModule.getQueue(gameMode.Value)
-- 		local requiredPlayers = gameMode.MinPartySize * 2

-- 		print("Queue players: ", #queue, " for ", gameMode.Name)

-- 		-- ✅ Only start match if enough players are available
-- 		if #queue >= requiredPlayers then
-- 			local team1 = {}
-- 			local team2 = {}
-- 			local players = {}

-- 			for i = 1, requiredPlayers do
-- 				local queuedPlayer = MatchQueueModule.popFromQueue(gameMode.Value)
-- 				if queuedPlayer then
-- 					table.insert(players, queuedPlayer)
-- 					ReplicatedStorage.RemoteEvents.Lobby.MatchQueueCanceled:FireClient(queuedPlayer, gameMode)
-- 					ReplicatedStorage.RemoteEvents.Lobby.MatchFoundVisibility:FireClient(queuedPlayer, true)
-- 				end
-- 			end

-- 			-- Divide into teams
-- 			for i, p in ipairs(players) do
-- 				if i % 2 == 1 then
-- 					table.insert(team1, p)
-- 				else
-- 					table.insert(team2, p)
-- 				end
-- 			end

-- 			-- Start match after a short delay
-- 			task.delay(3, function()
-- 				for _, p in ipairs(players) do
-- 					ReplicatedStorage.RemoteEvents.Lobby.MatchFoundVisibility:FireClient(p, false)
-- 				end
-- 				ArenaService.createMatch(gameMode, team1, team2)
-- 			end)
-- 		else
-- 			print("Not enough players to start a match yet.")
-- 		end
-- 	end
-- end



function Shared.handleMatchmakingForMode(player: Player, gameMode: GameMode.GameMode)
	if MatchQueueModule.addToQueue(gameMode.Value, player) then
		ReplicatedStorage.RemoteEvents.Lobby.MatchQueueStarted:FireClient(player, gameMode)

		local queue = MatchQueueModule.getQueue(gameMode.Value)
		print("Queue players: ", #queue, " for ", gameMode.Name)

		local team1 = {}
		local team2 = {}
		local players = {}
		for i = 1, gameMode.MinPartySize * 2 do
			local queuedPlayer = MatchQueueModule.popFromQueue(gameMode.Value)
			if queuedPlayer then
				table.insert(players, queuedPlayer)
				ReplicatedStorage.RemoteEvents.Lobby.MatchQueueCanceled:FireClient(queuedPlayer, gameMode)
				ReplicatedStorage.RemoteEvents.Lobby.MatchFoundVisibility:FireClient(queuedPlayer, true)
			end
		end
		for i, player in ipairs(players) do
			if i % 2 == 1 then
				table.insert(team1, player)
			else
				table.insert(team2, player)
			end
		end

		task.delay(3, function()
			for _, p in ipairs(players) do
				ReplicatedStorage.RemoteEvents.Lobby.MatchFoundVisibility:FireClient(p, false)
			end

			ArenaService.createMatch(gameMode, team1, team2)
		end)

	end
end


return Shared
