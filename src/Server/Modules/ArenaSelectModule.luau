local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArenaEnum = require(ReplicatedStorage.Shared.Enums.Arena)

local ArenaSelectModule = {}

local arenaSelections: { [ArenaEnum]: { number } } = {}

function ArenaSelectModule.getArenaSelections(): { [ArenaEnum]: { number } }
	return arenaSelections
end

function ArenaSelectModule.addPlayerToArena(playerUserId: number, arenaName: ArenaEnum)
	ArenaSelectModule.removePlayerFromAllArenas(playerUserId)

	if not arenaSelections[arenaName]  then
		arenaSelections[arenaName] = {}
	end

	table.insert(arenaSelections[arenaName], playerUserId)
end

function ArenaSelectModule.removePlayerFromAllArenas(playerUserId: number)
	for _, players in pairs(arenaSelections) do
		for i = #players, 1, -1 do
			if players[i] == playerUserId then
				table.remove(players, i)
			end
		end
	end
end

return ArenaSelectModule
