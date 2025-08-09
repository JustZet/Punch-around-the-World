local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Arenas = require(game.ReplicatedStorage.Shared.Modules.Arenas)
local ArenaEnum = require(game.ReplicatedStorage.Shared.Enums.Arena)

local ArenaConfig = {
	arenaList = {}
}

function ArenaConfig.getArenas()
	local available = {}

	for _, arena in pairs(Arenas.getAll()) do
		if arena.Value ~= ArenaEnum.RANDOM then
			table.insert(available, arena)
		end
	end

	return available
end

function ArenaConfig.loadArenaList()
	ArenaConfig.arenaList = {}
	for _, arena in pairs(Arenas.getAll()) do
		table.insert(ArenaConfig.arenaList, arena)
	end
	table.sort(ArenaConfig.arenaList, function(a, b)
		return a.Id < b.Id
	end)
end

return ArenaConfig
