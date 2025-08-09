-- HpBarHandler.lua
local HpModule = {}

local COLOR_FULL = Color3.fromRGB(100, 220, 100)
local COLOR_MEDIUM = Color3.fromRGB(240, 220, 100)
local COLOR_LOW = Color3.fromRGB(220, 100, 100)

local function lerpColor(color1, color2, alpha)
	return Color3.new(
		color1.R + (color2.R - color1.R) * alpha,
		color1.G + (color2.G - color1.G) * alpha,
		color1.B + (color2.B - color1.B) * alpha
	)
end

-- Main function: sets up the health bar behavior on a given Humanoid and barFill frame.
-- Optionally you can also pass a CanvasGroup if you want to fade or show/hide the entire UI.
function HpModule.bindHpBar(humanoid, canvasGroup, barFill)
	local MAX_HP = humanoid.MaxHealth or 100
	local currentHp = MAX_HP

	local function updateHp(newHp)
		currentHp = math.clamp(newHp, 0, MAX_HP)
		local fillPercent = currentHp / MAX_HP
		barFill:TweenSize(UDim2.new(fillPercent, 0, 1, 0), "Out", "Quad", 0.3, true)

		local color
		if fillPercent > 0.5 then
			local alpha = (fillPercent - 0.5) * 2
			color = lerpColor(COLOR_MEDIUM, COLOR_FULL, alpha)
		else
			local alpha = fillPercent * 2
			color = lerpColor(COLOR_LOW, COLOR_MEDIUM, alpha)
		end
		barFill.BackgroundColor3 = color

		-- Example: fade CanvasGroup based on HP (optional)
		if canvasGroup then
			canvasGroup.GroupTransparency = 1 - fillPercent  -- visible when HP is full, fades out when HP low
		end
	end

	-- Initialize bar
	updateHp(humanoid.Health)

	-- Connect health change signal
	humanoid.HealthChanged:Connect(updateHp)
end

return HpModule
