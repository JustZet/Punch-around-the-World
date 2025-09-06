local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local ShowGameSelectEvent = ReplicatedStorage.RemoteEvents.Lobby.ShowGameSelect
local GameModeConfig = require(script.Parent.Parent.Modules.GameModeConfig)
local GameModeUIManager = require(script.Parent.Parent.Modules.GameModeUIManager)

local GameModes = GameModeConfig.GameModes
local POSITIONS = GameModeConfig.Positions
local ORIGINAL_SIZE = GameModeConfig.OriginalSize
local SELECTED_SIZE = GameModeConfig.SelectedSize

local GameModeHandler = {}

local selectedButton = nil


function GameModeHandler.init()
	local screenGui = StarterGui.GameModeFrame
	
	GameModeHandler.gui = screenGui
	

	local frame = screenGui.Frame  -- background frame
	local dialog = frame.Dialog  -- the dialog inside

	-- Configuration
	local tweenTime = 1
	local hiddenPosition = UDim2.new(0.5, 0, 1.2, 0) -- offscreen bottom
	local visiblePosition = UDim2.new(0.5, 0, 0.5, 0) -- center


	-- -- Initialize positions
	-- dialog.Position = hiddenPosition
	-- frame.BackgroundTransparency = 1
	-- screenGui.Enabled = false


	ReplicatedStorage.RemoteEvents.Lobby.ShowGameSelect.OnClientEvent:Connect(function(isShow)
		if isShow then
			screenGui.Enabled = true
			-- Tween background transparency to 0.5 or whatever you like
			TweenService:Create(frame, TweenInfo.new(tweenTime), {BackgroundTransparency = 0.5}):Play()
			-- Tween dialog to center
			TweenService:Create(dialog, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = visiblePosition}):Play()
		else
			-- Tween background transparency back to 1
			TweenService:Create(frame, TweenInfo.new(tweenTime), {BackgroundTransparency = 1}):Play()
			-- Tween dialog to bottom
			local tween = TweenService:Create(dialog, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = hiddenPosition})
			tween:Play()
			tween.Completed:Connect(function()
				screenGui.Enabled = false
			end)
		end
	end)
	dialog.DismissButton.MouseButton1Click:Connect(function()
		-- Tween background transparency back to 1
		TweenService:Create(frame, TweenInfo.new(tweenTime), {BackgroundTransparency = 1}):Play()
		-- Tween dialog to bottom
		local tween = TweenService:Create(dialog, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = hiddenPosition})
		tween:Play()
		tween.Completed:Connect(function()
			screenGui.Enabled = false
		end)
	end)

	GameModeHandler.bindButtons()



end

function GameModeHandler.startGame(gameMode: GameMode)
	ReplicatedStorage.RemoteEvents.Lobby.GameSelectionConfirmed:FireServer(gameMode)
	GameModeHandler.gui.Enabled = false

	-- Unselect buttons
	GameModeUIManager.deselectButton(selectedButton)
	selectedButton = nil

end

function GameModeHandler.bindButtons()
	local buttons = {}
	for i, mode in ipairs(GameModes) do

		local btn = GameModeHandler.gui.Frame.Dialog.Body:FindFirstChild(mode.DisplayName)
		if btn then
			local stroke = btn:FindFirstChildOfClass("UIStroke")
			if stroke then stroke.Transparency = 1 end

			btn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if selectedButton ~= btn then
						-- New selection
						-- GameModeUIManager.deselectButton(selectedButton)
                        -- GameModeUIManager.selectButton(btn)
						-- selectedButton = btn

						GameModeHandler.startGame(GameModes[i])
					end
				end
			end)

			table.insert(buttons, btn)
		end
	end
end



return GameModeHandler
