local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Databases = require(script.Parent.Databases)
local PlayerLeaderboardTemplate =
	require(StarterPlayer.StarterPlayerScripts.Client.Modules.Teamplates.PlayerLeaderboardTemplate)

    
local playerCoins = DataStoreService:GetOrderedDataStore("_killsTest")

local Shared = {}

function Shared.init()
  
end

function Shared.start() 
	-- local pages = playerCoins:GetSortedAsync(false, 12, 1, nil)
	-- local entries = pages:GetCurrentPage()

	-- print(entries)

    -- local gui = Workspace.Lobby.Leaderboards.LeaderboardKills.SurfaceGui
    -- if gui then
    --     local scrollFrame = gui.ScrollingFrame
    --     if scrollFrame then
    --         for rank, entry in ipairs(entries) do
    --             local userId = tonumber(entry.key)
    --             local value = entry.value  -- not Value

    --             local template = PlayerLeaderboardTemplate.new(rank, userId, value)
    --             template.templateCloned.Parent = scrollFrame
    --         end
    --     end
    -- end

    -- local podium = Workspace.Lobby.Leaderboards.PodiumKills
    -- if #entries > 0 then
    --     local topEntry = entries[1]
    --     local userId = tonumber(topEntry.key)
    --     if userId then
    --         local rig = podium.Rig
    --         local humanoid = rig:FindFirstChildOfClass("Humanoid")
    --         if humanoid then
    --             local success, description = pcall(function()
    --                 return Players:GetHumanoidDescriptionFromUserId(userId)
    --             end)

    --              -- Remove all accessories first
    --             for _, acc in ipairs(rig:GetDescendants()) do
    --                 if acc:IsA("Accessory") or acc:IsA("Hat") then
    --                     acc:Destroy()
    --                 end
    --             end

    --             -- Remove all existing hair (MeshParts)
    --             for _, mesh in ipairs(rig:GetDescendants()) do
    --                 if mesh:IsA("MeshPart") and mesh.Name:lower():find("hair") then
    --                     mesh:Destroy()
    --                 end
    --             end

                
    --             if success and description then
    --                 humanoid:ApplyDescription(description)
    --                 print("Applied top player appearance to rig!")
    --             else
    --                 warn("Failed to get HumanoidDescription for userId:", userId)
    --             end
    --         end
    --     end
    -- end

end

return Shared
