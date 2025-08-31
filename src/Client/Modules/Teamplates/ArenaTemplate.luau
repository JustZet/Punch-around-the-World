local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PlayerModule = require(ReplicatedStorage.Shared.Modules.PlayerModule)

-- Constructor
local ArenaTemplate = {}
ArenaTemplate.__index = ArenaTemplate

export type ArenaTemplate = typeof(setmetatable(
	{} :: {
		arena: any,
		card: Frame,
		setSelected: (self: any, isSelected: boolean) -> (),
		setPlayers: (self: any, playerIds: { number }) -> (),
	},
	ArenaTemplate
))

function ArenaTemplate.new(arena): ArenaTemplate
	local self = setmetatable({}, ArenaTemplate)
	self.arena = arena
	self.card = ReplicatedStorage.Assets.Gui.ArenaButtonNew:Clone()
	self.soundHover = ReplicatedStorage.Assets.Sounds.Hover:Clone()
	self.soundHover.Parent = self.card

	self:init()
	return self
end

function ArenaTemplate:init()
	self.nameLabel = self.card.Canvas.TextLabel
	self.wallpaper = self.card.Canvas.ImageLabel
	self.iconsFrame = self.card.Canvas.PlayerIconsFrame
	self.stroke = self.card.UIStroke
	self.uiScale = self.card.UIScale

	self.nameLabel.Text = self.arena.Name or ""
	self.wallpaper.Image = self.arena.Icon or ""
	self:setSelected(false)

	self.card.AnchorPoint = Vector2.new(0.5, 0.5)
	self.card.Position = UDim2.fromScale(0.5, 0.5)
	-- Hover effect
	self.card.MouseEnter:Connect(function()
		self:onHover(true)
		self.soundHover:Play()
	end)

	self.card.MouseLeave:Connect(function()
		self:onHover(false)
	end)
end

function ArenaTemplate:setSelected(isSelected)
	self.wallpaper.ImageColor3 = isSelected and Color3.fromHex("#ffffff") or Color3.fromHex("#aaaaaa")
	if self.stroke then
		self.stroke.Enabled = isSelected
	end
end

function ArenaTemplate:setPlayers(playerIds)
	-- Clear first
	for _, child in pairs(self.iconsFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end

	for _, pid in ipairs(playerIds) do
		local icon = ReplicatedStorage.Assets.Gui:WaitForChild("ArenaPlayerButton"):Clone()
		icon.Name = "Player_" .. pid
		icon.Visible = true
		icon.Parent = self.iconsFrame

		if pid == Players.LocalPlayer.UserId then
			icon.ImageColor3 = Color3.fromRGB(255, 255, 0)
		end

		icon.ImagePlayerAvatar.Image = PlayerModule.getPlayerAvatarIcon(pid)
	end
end

function ArenaTemplate:onHover(isHovering)
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = { Scale = isHovering and 1.05 or 1 }

	TweenService:Create(self.uiScale, tweenInfo, goal):Play()
end
return ArenaTemplate
