local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local PartyModule = require(script.Parent.Parent.Modules.PartyModule)
local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)

local MenuHandler = {}

local gui, gameModeGui
local startButton
function MenuHandler.init()
	gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuFrame")
	gameModeGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameModeFrame")

	startButton = gui:WaitForChild("Start")


	Player:GetAttributeChangedSignal(PlayerEnum.IN_MATCH):Connect(function()
		MenuHandler.updateGuiVisibility()
	end)
	


	local screenGui = PlayerGui:WaitForChild("GameModeFrame")


	local frame = screenGui:WaitForChild("Frame")  -- background frame
	local dialog = frame:WaitForChild("Dialog")  -- the dialog inside

	-- Configuration
	local tweenTime = 0.4
	local hiddenPosition = UDim2.new(0.5, 0, 1.2, 0) -- offscreen bottom
	local visiblePosition = UDim2.new(0.5, 0, 0.5, 0) -- center

	startButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = true
		-- Tween background transparency to 0.5 or whatever you like
		TweenService:Create(frame, TweenInfo.new(tweenTime), {BackgroundTransparency = 0.5}):Play()
		-- Tween dialog to center
		TweenService:Create(dialog, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = visiblePosition}):Play()
	end)


	MenuHandler.updateGuiVisibility()
end


function MenuHandler.updateGuiVisibility()
	local inMatch = Player:GetAttribute(PlayerEnum.IN_MATCH)
	gui.Enabled = inMatch == false or inMatch == nil
end

return MenuHandler
