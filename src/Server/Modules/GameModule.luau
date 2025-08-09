local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArenaEnum = require(ReplicatedStorage.Shared.Enums.Arena)

local GameModule = {}

local games: {} = {}


function GameModule.getGames()
	return games
end

function GameModule.addGame(instance)
    table.insert(games, instance)
end
function GameModule.removeGame(instance)
    for i, game in ipairs(games) do
		if game.arena.FileName == instance.arena.FileName then
			table.remove(games, i)
			break
		end
	end
end

return GameModule
