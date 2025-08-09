local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local Players = game:GetService("Players")

local MatchQueueHandler = {}

local queueGui
local dismissButton

function MatchQueueHandler.init()
	local player = Players.LocalPlayer
	queueGui = player:WaitForChild("PlayerGui"):WaitForChild("GameQueue")
	dismissButton = queueGui:WaitForChild("Frame"):WaitForChild("DismissButton")

	ReplicatedStorage.RemoteEvents.Lobby.MatchQueueStarted.OnClientEvent:Connect(function(gameMode: GameMode.GameMode)
		queueGui.Enabled = true

		dismissButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.Lobby.MatchQueueCanceled:FireServer(gameMode)
			queueGui.Enabled = false
		end)
	end)

	ReplicatedStorage.RemoteEvents.Lobby.MatchQueueCanceled.OnClientEvent:Connect(function(gameMode: GameMode.GameMode)
		queueGui.Enabled = false
	end)
end

return MatchQueueHandler
