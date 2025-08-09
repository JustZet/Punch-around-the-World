-- MatchManagerService.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ArenaEnum = require(ReplicatedStorage.Shared.Enums.Arena)
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local Arenas = require(ReplicatedStorage.Shared.Modules.Arenas)


local GameService = require(ServerScriptService.Server.Services.GameService)
local ArenaSelectorModule = require(script.Parent.Parent.Modules.ArenaSelectModule)

local Shared = {}

-- MatchId -> match data
local activeMatches = {}
local playerToMatch = {}
local matchIdCounter = 0
local ARENA_SELECTION_TIME = 15


function Shared.start()
	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelection.OnServerEvent:Connect(function(player, arenaName)
		Shared.recordArenaSelection(player, arenaName)
	end)

	Players.PlayerRemoving:Connect(function(player)
		Shared.removePlayer(player)
	end)
end


-- Public API
function Shared.createMatch(gameMode: GameMode.GameMode, team1: { Player }, team2: { Player })
	matchIdCounter += 1
	local matchId = matchIdCounter

	local players = {}
	for _, p in ipairs(team1) do table.insert(players, p) end
	for _, p in ipairs(team2) do table.insert(players, p) end

	local match = {
		id = matchId,
		gameMode = gameMode,
		players = players,
		team1 = team1,
		team2 = team2,
		selections = {},
		countdown = ARENA_SELECTION_TIME,
		countdownTask = nil,
	}

	activeMatches[matchId] = match
	for _, player in ipairs(players) do
		playerToMatch[player.UserId] = matchId
	end
	print("Match with id", matchId, "created for", #players, "players")

	Shared.startArenaSelection(matchId)
	return matchId
end



function Shared.getMatchIdForPlayer(player)
	return playerToMatch[player.UserId]
end


function Shared.startArenaSelection(matchId)
	local match = activeMatches[matchId]
	if not match then
		return
	end

	-- Show GUI
	for _, player in ipairs(match.players) do
		ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectVisibility:FireClient(player, true)
	end

	Shared.broadcastSelections(matchId)

	-- Countdown coroutine
	match.countdownTask = task.spawn(function()
		while match.countdown > 0 do
			for _, player in ipairs(match.players) do
				ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectCountdown:FireClient(player, match.countdown)
			end
			task.wait(1)
			match.countdown -= 1

			if Shared.haveAllSelected(matchId) then
				break
			end
		end

		-- Finalize selection
		Shared.finalizeMatch(matchId)
	end)
end

function Shared.recordArenaSelection(player, arenaName: ArenaEnum)
	local matchId = playerToMatch[player.UserId]
	if not matchId then
		return
	end
	local match = activeMatches[matchId]
	if not match then
		return
	end

	ArenaSelectorModule.addPlayerToArena(player.UserId, arenaName)
	match.selections[player.UserId] = arenaName
	Shared.broadcastSelections(matchId)

	if Shared.haveAllSelected(matchId) then
	
		Shared.finalizeMatch(matchId)
	end
end

function Shared.broadcastSelections(matchId)
	local match = activeMatches[matchId]
	if not match then
		return
	end

	local selectionData = ArenaSelectorModule.getArenaSelections()
	for _, player in ipairs(match.players) do
		ReplicatedStorage.RemoteEvents.Lobby.ArenaSelection:FireClient(player, selectionData)
	end
end

function Shared.haveAllSelected(matchId)
	local match = activeMatches[matchId]
	if not match then
		return false
	end
	for _, player in ipairs(match.players) do
		if not match.selections[player.UserId] then
			return false
		end
	end
	return true
end

function Shared.finalizeMatch(matchId)
	local match = activeMatches[matchId]
	if not match then return end

	for _, player in ipairs(match.players) do
		ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectVisibility:FireClient(player, false)
	end

	local voteCounts = {}
	for _, arena in pairs(match.selections) do
		voteCounts[arena] = (voteCounts[arena] or 0) + 1
	end

	local maxVotes = 0

	local chosen = {}
	for arena, count in pairs(voteCounts) do
		if arena ~= ArenaEnum.RANDOM then  -- exclude "Random" votes
			if count > maxVotes then
				maxVotes = count
				chosen = { arena }
			elseif count == maxVotes then
				table.insert(chosen, arena)
			end
		end
	end


	local chosenArenaID: String
	if #chosen > 0 then
		chosenArenaID = chosen[math.random(1, #chosen)]
	else
		local allArenas = {}
		for arenaName, data in pairs(Arenas.getAll()) do
			if data.FileName ~= ArenaEnum.RANDOM then
				table.insert(allArenas, arenaName)
			end
		end
		chosenArenaID = allArenas[math.random(1, #allArenas)]
	end

	for _, player in ipairs(match.players) do
		playerToMatch[player.UserId] = nil
	end
	activeMatches[matchId] = nil

	GameService.startMatch(chosenArenaID, match.gameMode, match.team1, match.team2)
end


function Shared.removePlayer(player)
	local matchId = playerToMatch[player.UserId]
	if not matchId then return end
	local match = activeMatches[matchId]
	if not match then return end

	for i, p in ipairs(match.players) do
		if p == player then
			table.remove(match.players, i)
			break
		end
	end
	match.selections[player.UserId] = nil
	playerToMatch[player.UserId] = nil

	if #match.players == 0 then
		activeMatches[matchId] = nil
	end
end

return Shared
