-- PartyModule.lua
local PartyModule = {}

-- Internal storage
local PartyData = {} -- [LeaderUserId] = { Members = {Player, ...} }
local PendingInvites = {} -- [InvitedUserId] = InviterUserId

------------------------------------------------
-- ✅ Accessors
------------------------------------------------
function PartyModule.getPartyData()
	return PartyData
end

function PartyModule.getPendingInvites()
	return PendingInvites
end

function PartyModule.getPartyByPlayer(player)
	for leaderUserId, data in pairs(PartyData) do
		for _, member in ipairs(data.Members) do
			if member == player then
				return leaderUserId, data
			end
		end
	end
	return nil, nil
end

function PartyModule.removePlayerFromParty(player)
	local leaderId, party = PartyModule.getPartyByPlayer(player)
	if leaderId and party then
		for i, member in ipairs(party.Members) do
			if member == player then
				table.remove(party.Members, i)
				break
			end
		end
		-- Disband if leader leaves or no one left
		if #party.Members == 0 or player.UserId == leaderId then
			PartyData[leaderId] = nil
		end
	end
end

function PartyModule.ensurePartyExists(leader)
	local leaderId = leader.UserId

	if not PartyData[leaderId] then
		PartyData[leaderId] = { Members = { leader } }
	end
end

function PartyModule.addPlayerToParty(leader, player)
	PartyModule.removePlayerFromParty(player) 
	PartyModule.ensurePartyExists(leader)
	if not table.find(PartyData[leader.UserId].Members, player) then
		table.insert(PartyData[leader.UserId].Members, player)
	end
end

function PartyModule.setPendingInvite(invitedUserId: number, inviterUserId: number)
	PendingInvites[invitedUserId] = inviterUserId
end

function PartyModule.clearPendingInvite(userId: number)
	PendingInvites[userId] = nil
end
function PartyModule.hasPendingInvite(userId: number): boolean
	return PendingInvites[userId] ~= nil
end

function PartyModule.getPendingInviter(userId: number)
	return PendingInvites[userId]
end
return PartyModule
