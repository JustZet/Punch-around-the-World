local ReplicatedStorage = game:GetService("ReplicatedStorage")



local PlayerPartyTemplate = {}
PlayerPartyTemplate.__index = PlayerPartyTemplate

-- Constructor
function PlayerPartyTemplate.new(playerID: number, playerName: string)
	local self = setmetatable({}, PlayerPartyTemplate)
	self.playerToInviteTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("PlayerInvite")
    self.view = self.playerToInviteTemplate:Clone()
    self.playerID = playerID
    self.playerName = playerName
    self.cooldownSeconds = 5
    
    self:bindPlayer(playerID, playerName)
	return self
end


function PlayerPartyTemplate:bindPlayer(playerID: number, playerName: string)
	local avatarImage = self.view:FindFirstChild("Avatar")
	local inviteButton = self.view:FindFirstChild("Invite")
	local nameLabel = self.view:FindFirstChild("Name")

	if avatarImage and inviteButton and nameLabel then
		avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
			.. playerID
			.. "&width=150&height=150&format=png"
		inviteButton.Text = "Invite"
		nameLabel.Text = playerName or ""

		-- Connect invite button click
		inviteButton.MouseButton1Click:Connect(function()
			inviteButton.Text = "Invited"
			inviteButton.BackgroundTransparency = 0.7

            inviteButton.Active = false -- disable input
        	if self.onInviteClicked then
				self.onInviteClicked(self.playerID)
			end

            task.delay(5, function()
				inviteButton.Text = "Invite"
				inviteButton.BackgroundTransparency = 0
				inviteButton.AutoButtonColor = true
				inviteButton.Active = true
			end)
		end)
	end
end

function PlayerPartyTemplate:setOnInviteClicked(callback: (number) -> ())
    self.onInviteClicked = callback
end

return PlayerPartyTemplate