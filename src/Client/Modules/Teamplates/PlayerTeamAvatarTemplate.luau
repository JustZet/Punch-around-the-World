local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerTeamAvatarTemplate = {}
PlayerTeamAvatarTemplate.__index = PlayerTeamAvatarTemplate

-- Define the class type
export type View = {
	view: ImageButton,
	player: Player,
	logo: ImageLabel,
	lifeImage: Frame,
	lifeCount: TextLabel,
	
	bindLifes: (self: View, count: number) -> (),
	showGameOver: (self: View) -> (),
}

-- Constructor
function PlayerTeamAvatarTemplate.new(player: Player): View
	local self = setmetatable({}, PlayerTeamAvatarTemplate)

	-- Clone template
	local lifeTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("PlayerAvatarGame") :: ImageButton
	self.view = lifeTemplate:Clone()

	-- Reference inner elements
	self.logo = self.view:WaitForChild("Logo") :: ImageLabel
	self.lifeImage = self.view:WaitForChild("Life") :: Frame
	self.lifeCount = self.lifeImage:WaitForChild("Count") :: TextLabel

	-- Set player avatar
	local userId = player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100

	local content, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	self.logo.Image = content

	-- Default state
	self.lifeCount.Text = "3"
	self.player = player

	return self
end

-- Update life count
function PlayerTeamAvatarTemplate:bindLifes(count: number)
	self.lifeCount.Text = tostring(count)

	if count <= 0 then
		self:showGameOver()
	end
end

-- Handle player out of lives
function PlayerTeamAvatarTemplate:showGameOver()
	self.lifeCount.Text = "☠" -- or use an icon if you prefer
	self.logo.ImageColor3 = Color3.fromRGB(100, 100, 100) -- grayscale avatar
	self.logo.ImageTransparency = 0.4 -- fade effect
end

return PlayerTeamAvatarTemplate
