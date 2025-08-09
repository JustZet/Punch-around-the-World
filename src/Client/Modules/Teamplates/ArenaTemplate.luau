local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerModule = require(ReplicatedStorage.Shared.Modules.PlayerModule)
local Arena = require(ReplicatedStorage.Shared.Models.Arena.Arena)



-- Constructor
local ArenaTemplate = {}
ArenaTemplate.__index = ArenaTemplate

export type ArenaTemplate = typeof(setmetatable({} :: {
	arena: any,
	card: Frame,
	setSelected: (self: any, isSelected: boolean) -> (),
	setPlayers: (self: any, playerIds: {number}) -> ()
}, ArenaTemplate))


function ArenaTemplate.new(arena): ArenaTemplate
	local self = setmetatable({}, ArenaTemplate)
	self.arena = arena
	self.card = script.Parent.ArenaTemplate:Clone() -- or however you clone it
	self:init()
	return self
end

function ArenaTemplate:init()
	self.nameLabel = self.card.Frame:WaitForChild("Name")
	self.wallpaper = self.card.Frame:WaitForChild("ImageLabel")
	self.iconsFrame = self.card.Frame:WaitForChild("PlayerIconsFrame")
	self.stroke = self.card.Frame:FindFirstChildOfClass("UIStroke")

	self.nameLabel.Text = self.arena.Name or ""
	self.wallpaper.Image = self.arena.Icon or ""
	self:setSelected(false)
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

return ArenaTemplate
