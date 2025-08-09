local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameModeConfig = require(script.Parent.Parent.Modules.GameModeConfig)
local GameModeUIManager = require(script.Parent.Parent.Modules.GameModeUIManager)

local GameModes = GameModeConfig.GameModes
local POSITIONS = GameModeConfig.Positions
local ORIGINAL_SIZE = GameModeConfig.OriginalSize
local SELECTED_SIZE = GameModeConfig.SelectedSize

local GameModeHandler = {}

local selectedButton = nil


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


function GameModeHandler.setupDismissButton()
	local dismissButton = GameModeHandler.gui.Frame.Dialog.DismissButton:FindFirstChild("DismissButton")
	if dismissButton then
		dismissButton.MouseButton1Click:Connect(function()
			GameModeHandler.gui.Enabled = false
		end)
	end
end

function GameModeHandler.init()
	local screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameModeFrame")
	GameModeHandler.gui = screenGui

	ReplicatedStorage.RemoteEvents.Lobby.ShowGameSelect.OnClientEvent:Connect(function(isShow)
		GameModeHandler.gui.Enabled = isShow
	end)

	GameModeHandler.bindButtons()
	GameModeHandler.setupDismissButton()
end

return GameModeHandler
