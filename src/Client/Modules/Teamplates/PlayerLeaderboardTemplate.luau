local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerFunctions = require(ReplicatedStorage.Shared.Functions.PlayerFunctions)

local PlayerLeaderboardTemplate = {}
PlayerLeaderboardTemplate.__index = PlayerLeaderboardTemplate

-- Constructor
function PlayerLeaderboardTemplate.new(rank: number, playerID: number, value)
	local self = setmetatable({}, PlayerLeaderboardTemplate)

	-- Clone template
	self.template = ReplicatedStorage.Assets.Gui.PlayerLeaderboard
	self.templateCloned = self.template:Clone()
	self.playerID = playerID
	self.value = value
	self.rank = rank

	self.nameLabel = self.templateCloned.Name
	self.rankLabel = self.templateCloned.Rank
	self.valueLabel = self.templateCloned.Value

	self:init()
	return self
end

function PlayerLeaderboardTemplate:init()
	self.nameLabel = self.templateCloned.Name
	self.rankLabel = self.templateCloned.Rank
	self.valueLabel = self.templateCloned.Value

	self.rankLabel.Text = "#" .. tostring(self.rank)
	self.valueLabel.Text = tostring(self.value)

	pcall(function()
		self.nameLabel.Text = Players:GetNameFromUserIdAsync(self.playerID)
	end)

	-- PlayerFunctions.getPlayerAvatar(self.playerID)
end

return PlayerLeaderboardTemplate
