local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local TimeFormatterModule = require(ReplicatedStorage.Shared.Modules.TimeFormatterModule)
local Databases = require(ServerScriptService.Server.Database.Databases)
local PlayerLeaderboardTemplate =
	require(StarterPlayer.StarterPlayerScripts.Client.Modules.Teamplates.PlayerLeaderboardTemplate)

local Leaderboard = {}
Leaderboard.__index = Leaderboard

function Leaderboard.new(db: OrderedDataStore, folderInstance)
	assert(folderInstance and folderInstance:IsA("Folder"), "Leaderboard folder must be provided")

	local self = setmetatable({}, Leaderboard)
	self.database = db

	-- Get PodiumKills model
	self.podium = folderInstance:FindFirstChild("Podium")
	assert(self.podium, "Podium not found in folder")

	-- Get Leaderboard part → SurfaceGui → ScrollingFrame
	local leaderboardPart = folderInstance:FindFirstChild("Leaderboard")
	assert(leaderboardPart, "Leaderboard part not found in folder")

	local gui = leaderboardPart:FindFirstChildOfClass("SurfaceGui")
	assert(gui, "SurfaceGui not found in Leaderboard part")

	local scrollingFrame = gui:FindFirstChild("ScrollingFrame")
	assert(scrollingFrame, "ScrollingFrame not found in SurfaceGui")

	self.gui = gui
	self.scrollFrame = scrollingFrame

	return self
end

function Leaderboard:clear()
	local children = self.scrollFrame:GetChildren()

	for i = 1, #children do
		local child = children[i]

		-- Skip UIListLayout and Header
		if child.Name ~= "UIListLayout" and child.Name ~= "Header" then
			child:Destroy()
		end
	end
end

-- Example method to add an entry
function Leaderboard:addEntity(rank: number, userId: number, value)
	if self.database == Databases.minutes then
		value = TimeFormatterModule.formatMinutes(value)
	end
	local template = PlayerLeaderboardTemplate.new(rank, userId, value)
	template.templateCloned.Parent = self.scrollFrame

	if rank == 1 then
		self:bindPodium(userId)
	end
end

function Leaderboard:refresh()
	self:clear()

	local pages = self.database:GetSortedAsync(false, 12, 1, nil)
	local entries = pages:GetCurrentPage()
	for rank, entry in ipairs(entries) do
		local userId = tonumber(entry.key)
		local value = entry.value -- not Value

		self:addEntity(rank, userId, value)
	end
end

function Leaderboard:bindPodium(playerId: number?)
	if playerId then
		local rig = self.podium.Rig
		local humanoid = rig:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local success, description = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(playerId)
			end)

			-- Remove all accessories first
			for _, acc in ipairs(rig:GetDescendants()) do
				if acc:IsA("Accessory") or acc:IsA("Hat") then
					acc:Destroy()
				end
			end
			-- Remove all existing hair (MeshParts)
			for _, mesh in ipairs(rig:GetDescendants()) do
				if mesh:IsA("MeshPart") and mesh.Name:lower():find("hair") then
					mesh:Destroy()
				end
			end

			if success and description then
				humanoid:ApplyDescription(description)
			else
				warn("Failed to get HumanoidDescription for userId:", playerId)
			end
		end
	end
end
return Leaderboard
