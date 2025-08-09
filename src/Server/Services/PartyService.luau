local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local EventModule = require(ReplicatedStorage.Shared.Modules.EventModule)
local PartyModule = require(script.Parent.Parent.Modules.PartyModule)

local Shared = {}

function Shared.start()
	EventModule.Remote.PartySendInvite.OnServerEvent:Connect(function(inviter, invitedUserId)
		local invitedPlayer = Players:GetPlayerByUserId(invitedUserId)
		if not invitedPlayer or not inviter then
			return
		end

		if invitedPlayer == inviter then
			return
		end

		if PartyModule.hasPendingInvite(invitedUserId) then
			return
		end
		PartyModule.setPendingInvite(invitedUserId, inviter.UserId)

		-- Notify client with UI logic
		EventModule.Remote.PartyReceivedInvite:FireClient(invitedPlayer, inviter)
	end)

	EventModule.Remote.PartyAcceptInvite.OnServerEvent:Connect(function(player, mode: GameMode.GameMode?)
		if not PartyModule.hasPendingInvite(player.UserId) then
			return
		end

		local inviterId = PartyModule.getPendingInviter(player.UserId)
		if not inviterId then
			return
		end

		local inviter = Players:GetPlayerByUserId(inviterId)
		if not inviter then
			return
		end

		PartyModule.clearPendingInvite(player.UserId)
		PartyModule.addPlayerToParty(inviter, player)

		-- Debug print
		local leaderId, party = PartyModule.getPartyByPlayer(player)
		if party then
			for _, member in ipairs(party.Members) do
				local memberPlayer = Players:GetPlayerByUserId(member.UserId)
				if memberPlayer and mode then
					EventModule.Remote.PartyUpdated:FireClient(memberPlayer, party.Members, mode)
				end
			end
		end
	end)

	EventModule.Remote.PartyDeclineInvite.OnServerEvent:Connect(function(player, mode: GameMode.GameMode?)
		local inviterId = PartyModule.getPendingInviter(player.UserId)
		if inviterId then
			local inviter = Players:GetPlayerByUserId(inviterId)
			if inviter then
			end
		end
		PartyModule.clearPendingInvite(player.UserId)
	end)
end

return Shared
