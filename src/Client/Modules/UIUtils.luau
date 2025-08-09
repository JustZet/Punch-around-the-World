local TweenService = game:GetService("TweenService")

local UIUtils = {}

function UIUtils.fadeCanvas(canvasGroup, targetAlpha, duration)
	if not canvasGroup then return end
	TweenService:Create(canvasGroup, TweenInfo.new(duration or 0.3), {
		Alpha = targetAlpha
	}):Play()
end

function UIUtils.setTransparencyAllDescendants(instance, transparency)
	for _, child in ipairs(instance:GetDescendants()) do
		if child:IsA("ImageLabel") or child:IsA("TextLabel") then
			child.TextTransparency = transparency
			child.ImageTransparency = transparency
		end
	end
end

function UIUtils.tweenTextTransparency(target, goalTransparency, duration)
	if not target then return end
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local goal = { TextTransparency = goalTransparency }
	local tween = TweenService:Create(target, tweenInfo, goal)
	tween:Play()
end

function UIUtils.playZoomInOutAnimation(view: GuiObject): Tween?
	local originalSize: UDim2 = view.Size
	local currentTween: Tween? = nil

	-- Cancel any existing tween stored in view
	if view:FindFirstChild("__CurrentTween") then
		local tag = view:FindFirstChild("__CurrentTween")
		local tween = tag.Value
		if tween and tween:IsA("Tween") then
			tween:Cancel()
		end
		tag:Destroy()
	end

	-- Compute animation parameters
	local scaleBoost = math.clamp(1 + (15 - 10) * 0.02, 1, 1.3)
	local tweenTime = math.clamp(0.3 - (15 - 10) * 0.01, 0.1, 0.3)

	-- Create tweens
	local pulseOut = TweenService:Create(view, TweenInfo.new(tweenTime), {
		TextScaled = true,
		Size = UDim2.new(originalSize.X.Scale * scaleBoost, 0, originalSize.Y.Scale * scaleBoost, 0),
	})

	local pulseIn = TweenService:Create(view, TweenInfo.new(tweenTime), {
		Size = originalSize,
	})

	currentTween = pulseOut
	pulseOut:Play()

	-- Store the current tween inside view (optional temp value)
	local tag = Instance.new("ObjectValue")
	tag.Name = "__CurrentTween"
	tag.Value = currentTween
	tag.Parent = view

	pulseOut.Completed:Once(function()
		currentTween = pulseIn
		pulseIn:Play()
		tag.Value = pulseIn
	end)

	return currentTween
end

return UIUtils
