local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArenaCountdownHandler = {}

local countdownLabel
local originalSize
local currentTween = nil

function ArenaCountdownHandler.init()
	local gui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ArenaSelectFrame")
	countdownLabel = gui:WaitForChild("Frame"):WaitForChild("MapCountDown")
	originalSize = countdownLabel.Size

	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectCountdown.OnClientEvent:Connect(function(time)
		countdownLabel.Text = tostring(time)
		if currentTween then
			currentTween:Cancel()
		end

		local scaleBoost = math.clamp(1 + (15 - time) * 0.02, 1, 1.3)
		local tweenTime = math.clamp(0.3 - (15 - time) * 0.01, 0.1, 0.3)

		local pulseOut = TweenService:Create(countdownLabel, TweenInfo.new(tweenTime), {
			TextScaled = true,
			Size = UDim2.new(originalSize.X.Scale * scaleBoost, 0, originalSize.Y.Scale * scaleBoost, 0),
		})

		local pulseIn = TweenService:Create(countdownLabel, TweenInfo.new(tweenTime), {
			Size = originalSize,
		})

		currentTween = pulseOut
		pulseOut:Play()
		pulseOut.Completed:Once(function()
			currentTween = pulseIn
			pulseIn:Play()
		end)
	end)
end

return ArenaCountdownHandler
