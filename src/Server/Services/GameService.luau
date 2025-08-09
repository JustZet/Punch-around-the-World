local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Arenas = require(ReplicatedStorage.Shared.Modules.Arenas)
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local ArenaModule = require(ServerScriptService.Server.Modules.ArenaModule)
local WeaponModule = require(ServerScriptService.Server.Modules.WeaponModule)

local Game = require(ServerScriptService.Server.Services.Constructors.Game)
local PlayerModule = require(ServerScriptService.Server.Modules.PlayerModule)

local GameService = {}

local gamesFolder

function GameService.init()
    gamesFolder = Workspace:FindFirstChild("Games")
    if not gamesFolder then
        gamesFolder = Instance.new("Folder")
        gamesFolder.Name = "Games"
        gamesFolder.Parent = Workspace
    end
end

function GameService.start()

end

function GameService.startMatch(arenaID: string, gameMode: GameMode.GameMode, team1: { Player }, team2: { Player })
	local arenaData = Arenas.get(arenaID)
	if not arenaData then
		warn("Arena not found:", arenaID)
		return
	end
	
	local arenaModel = ServerStorage.Arenas:FindFirstChild(arenaID)
	if not arenaModel then
		warn("Arena model not found:", arenaID)
		return
	end
	local match: Game.Game? = Game.new({
		arena = arenaData,
		team1 = team1,
		team2 = team2,
	})

	if match then
		-- for _, team in ipairs({match.team1, match.team2}) do
		-- 	for _, player in ipairs(team) do
		-- 		ReplicatedStorage.RemoteEvents.Game.GameStarted:FireClient(player, match.team1, match.team2)
		-- 	end
		-- end
	
		
		-- match:on(Game.Actions.MATCH_ENDED, function(instance: Game.Game)
		-- 	for _, team in ipairs({instance.team1, instance.team2}) do
		-- 		for _, player in ipairs(team) do
		-- 			ReplicatedStorage.RemoteEvents.Game.GameEnded:FireClient(player, instance.team1, instance.team2)
		-- 		end
		-- 	end
		-- 	-- GameModule.removeGame(instance)
		-- end)
	end
end

return GameService
