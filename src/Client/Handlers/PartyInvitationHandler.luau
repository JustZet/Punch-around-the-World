local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Player = Players.LocalPlayer

local PlayerPartyInvitationTemplate = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Teamplates.PlayerPartyInvitationTemplate)
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local EventModule = require(ReplicatedStorage.Shared.Modules.EventModule)
local PartyModule = require(script.Parent.Parent.Modules.PartyModule)

local PartyInvitationHandler = {}

local gui, invitationsFrame
function PartyInvitationHandler.init()
	gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InvitationFrame")
	invitationsFrame = gui:WaitForChild("Frame")

	EventModule.Remote.PartyReceivedInvite.OnClientEvent:Connect(function(inviterPlayer: Player, mode: GameMode.GameMode)
		PartyInvitationHandler.addInvite(inviterPlayer, mode)
	end)

	gui.Enabled = true
end

-- rgion Actions

function PartyInvitationHandler.addInvite(player: Player, mode: GameMode.GameMode)
	local template = PlayerPartyInvitationTemplate.new(player, mode)
	template:setOnAccept(function () 
		print("accept")
		EventModule.Remote.PartyAcceptInvite:FireServer(template.player.UserId, template.gameMode)
	end)
	template:setOnDismiss(function () 
		EventModule.Remote.PartyDeclineInvite:FireServer(template.player.UserId, template.gameMode)
	end)
	template.card.Parent = invitationsFrame

	task.delay(10, function()
		if template and template.card then
			template:Destroy()
		end
	end)
end

-- endregion

return PartyInvitationHandler
