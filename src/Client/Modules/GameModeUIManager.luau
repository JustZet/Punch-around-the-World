local TweenService = game:GetService("TweenService")
local GameModeConfig = require(script.Parent.GameModeConfig)

local GameModeUIManager = {}

function GameModeUIManager.selectButton(btn)
	if not btn then return end

	local stroke = btn:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = 0
	end

	TweenService:Create(btn, TweenInfo.new(0.2), {
		Size = GameModeConfig.SelectedSize
	}):Play()
end

function GameModeUIManager.deselectButton(btn)
	if not btn then return end

	local stroke = btn:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = 1
	end

	TweenService:Create(btn, TweenInfo.new(0.2), {
		Size = GameModeConfig.OriginalSize
	}):Play()
end

return GameModeUIManager
