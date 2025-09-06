local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Databases = require(ServerScriptService.Server.Database.Databases)
local Leaderboard = require(ServerScriptService.Server.Services.Constructors.Leaderboard)
local PlayerLeaderboardTemplate =
	require(StarterPlayer.StarterPlayerScripts.Client.Modules.Teamplates.PlayerLeaderboardTemplate)

local REFRESH_INTERVAL = 30 -- seconds


local Shared = {}

function Shared.init() end

function Shared.start()
    local killsLeaderboard = Leaderboard.new(Databases.kills, Workspace.Lobby.Leaderboards.Kills);
    local timeLeaderboard = Leaderboard.new(Databases.minutes, Workspace.Lobby.Leaderboards.Time);
    local winsLeaderboard = Leaderboard.new(Databases.wins, Workspace.Lobby.Leaderboards.Wins);

    winsLeaderboard:refresh();
    timeLeaderboard:refresh();
    killsLeaderboard:refresh();

    while true do
        task.wait(REFRESH_INTERVAL)
        winsLeaderboard:refresh();
        timeLeaderboard:refresh();
        killsLeaderboard:refresh();
    end
end

return Shared
