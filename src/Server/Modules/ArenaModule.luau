-- KillSurfaceManager.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local arenaModule = require(ReplicatedStorage.Shared.Modules.Arenas)

local ArenaModule = {}

function ArenaModule.enableKillSurfaces(arenaModel: Model)
    if not arenaModel:IsDescendantOf(game.Workspace) then
		warn("Arena model not parented yet. Kill surfaces may not work.")
	end

	local killFolder = arenaModel:FindFirstChild(arenaModule.KillFolderName)
	if not killFolder then return end

	for _, part in ipairs(killFolder:GetChildren()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)

				local character = hit:FindFirstAncestorOfClass("Model")
				if character and character:FindFirstChild("Humanoid") then
					local player = Players:GetPlayerFromCharacter(character)
					if player then
						character.Humanoid.Health = 0
					end
				end
			end)
		end
	end
end

return ArenaModule
