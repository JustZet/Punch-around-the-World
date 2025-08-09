local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)

local PlayerPartyInvitationTemplate = {}
PlayerPartyInvitationTemplate.__index = PlayerPartyInvitationTemplate

-- Load template once
local invitationTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("PlayerInvitation")

function PlayerPartyInvitationTemplate.new(player: Player, gameMode: GameMode.GameMode)
	local self = setmetatable({}, PlayerPartyInvitationTemplate)
	self.player = player
    self.gameMode = gameMode
	self.card = invitationTemplate:Clone()
	self.card.Visible = true
	self.card.Name = "Invite_" .. player.UserId

	self:bindPlayer(player)
	return self
end

function PlayerPartyInvitationTemplate:Destroy() 
	if self.acceptConnection then
		self.acceptConnection:Disconnect()
		self.acceptConnection = nil
	end
	if self.dismissConnection then
		self.dismissConnection:Disconnect()
		self.dismissConnection = nil
	end
	if self.card then
		self.card:Destroy()
		self.card = nil
	end
end


function PlayerPartyInvitationTemplate:bindPlayer(player)
	self.avatarImage = self.card:FindFirstChild("Avatar")
	self.inviteButton = self.card:FindFirstChild("Confirm")
	self.dismissButton = self.card:FindFirstChild("DismissButton")
	self.nameLabel = self.card:FindFirstChild("Name")

	if self.avatarImage and self.inviteButton and self.nameLabel and self.dismissButton then
		self.avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
			.. player.UserId
			.. "&width=150&height=150&format=png"
		self.inviteButton.Text = "Accept"
		self.nameLabel.Text = player.Name or ""

		 self.acceptConnection = self.inviteButton.MouseButton1Click:Connect(function()
			self:onAccept()
		end)

		self.dismissConnection = self.dismissButton.MouseButton1Click:Connect(function()
			self:onDismiss()
		end)

	end
end

-- Optional: expose a method to get the UI instance (card)
function PlayerPartyInvitationTemplate:getView()
	return self.card
end

-- region SETTERS
function PlayerPartyInvitationTemplate:setOnAccept(callback: (number) -> ())
    self.onAcceptCallback = callback
end

function PlayerPartyInvitationTemplate:setOnDismiss(callback: (number) -> ())
    self.onDismissCallback = callback
end

function PlayerPartyInvitationTemplate:onAccept()
    if self.onAcceptCallback then
        self.onAcceptCallback(self.player.UserId)
    end
    self:Destroy()
end

function PlayerPartyInvitationTemplate:onDismiss()
    if self.onDismissCallback then
        self.onDismissCallback(self.player.UserId)
    end
    self:Destroy()
end

-- endregion

return PlayerPartyInvitationTemplate
