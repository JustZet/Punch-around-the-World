local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")

local LifeTemplate = {}
LifeTemplate.__index = LifeTemplate

-- Constructor
function LifeTemplate.new(): ImageLabel
	local self = setmetatable({}, LifeTemplate)

	-- Clone template
	self.template = ReplicatedStorage.Assets.Gui:WaitForChild("Life")
	self.templateCloned = self.template:Clone()

	return self.templateCloned
end

return LifeTemplate