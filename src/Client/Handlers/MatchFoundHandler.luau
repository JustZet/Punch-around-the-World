local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MatchFoundHandler = {}

function MatchFoundHandler.init()
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("MatchFound") 
	
	ReplicatedStorage.RemoteEvents.Lobby.MatchFoundVisibility.OnClientEvent:Connect(function(isShowed)
		gui.Enabled = isShowed
	end)
end

return MatchFoundHandler
