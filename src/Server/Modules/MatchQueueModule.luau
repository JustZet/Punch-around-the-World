local GameModesEnum = require(game.ReplicatedStorage.Shared.Enums.GameModeEnum)
local MatchQueueModule = {}


local queues = {
	[GameModesEnum.SOLO] = {},  -- Each entry: { members = { player1 } }
	[GameModesEnum.DUO] = {},   -- Each entry: { members = { player1, player2 } }
	[GameModesEnum.SQUAD] = {}, -- Each entry: { members = { player1, player2, player3, player4 } }
}

function MatchQueueModule.getQueue(mode: GameModesEnum)
	return queues[mode]
end

function MatchQueueModule.isInQueue(mode: GameModesEnum, player): boolean
	for _, p in ipairs(queues[mode]) do
		if p == player then return true end
	end
	return false
end

function MatchQueueModule.addToQueue(mode: GameModesEnum, player): boolean
	if not MatchQueueModule.isInQueue(mode, player) then
		table.insert(queues[mode], player)
		return true
	end
	return false
end

function MatchQueueModule.addPartyToQueue(mode: GameModesEnum, party: { members: { Player } }): boolean
	for _, entry in ipairs(queues[mode]) do
		for _, member in ipairs(entry.members) do
			for _, newMember in ipairs(party.members) do
				if member == newMember then
					return false -- one of the members is already in queue
				end
			end
		end
	end
	table.insert(queues[mode], party)
	return true
end


function MatchQueueModule.removeFromQueue(mode: GameModesEnum, player)
	for i, p in ipairs(queues[mode]) do
		if p == player then
			table.remove(queues[mode], i)
			break
		end
	end
end

function MatchQueueModule.popPartiesForTeam(mode: GameModesEnum, requiredSize: number): { Player }
	local team = {}
	local toRemove = {}

	for i, entry in ipairs(queues[mode]) do
		if #team + #entry.members <= requiredSize then
			for _, member in ipairs(entry.members) do
				table.insert(team, member)
			end
			table.insert(toRemove, i)
		end
		if #team >= requiredSize then
			break
		end
	end

	-- Remove selected parties from queue
	for i = #toRemove, 1, -1 do
		table.remove(queues[mode], toRemove[i])
	end

	return team
end


function MatchQueueModule.popFromQueue(mode: GameModesEnum)
	return table.remove(queues[mode], 1)
end

return MatchQueueModule
