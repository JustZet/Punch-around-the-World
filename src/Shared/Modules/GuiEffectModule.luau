local TweenService = game:GetService("TweenService")

local GuiEffectModule = {}

function GuiEffectModule.ApplyHoverEffect(guiObject, sizeOffset)
	sizeOffset = sizeOffset or UDim2.new(0, 4, 0, 4)
	local originalSize = guiObject.Size
	local hoverSize = originalSize + sizeOffset
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local currentTween = nil

	local function tweenTo(size)
		if currentTween then
			currentTween:Cancel()
		end
		currentTween = TweenService:Create(guiObject, tweenInfo, { Size = size })
		currentTween:Play()
	end

	guiObject.MouseEnter:Connect(function()
		tweenTo(hoverSize)
	end)

	guiObject.MouseLeave:Connect(function()
		tweenTo(originalSize)
	end)
end

return GuiEffectModule
