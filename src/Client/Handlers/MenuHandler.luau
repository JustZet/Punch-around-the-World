local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PartyModule = require(script.Parent.Parent.Modules.PartyModule)
local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)

local MenuHandler = {}

local gui, gameModeGui
local startButton
function MenuHandler.init()
	gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuFrame")
	gameModeGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameModeFrame")
	startButton = gui:WaitForChild("Start")

	startButton.MouseButton1Click:Connect(function()
		gameModeGui.Enabled = true
	end)

	Player:GetAttributeChangedSignal(PlayerEnum.IN_MATCH):Connect(function()
		MenuHandler.updateGuiVisibility()
	end)
	
	MenuHandler.updateGuiVisibility()
end


function MenuHandler.updateGuiVisibility()
	local inMatch = Player:GetAttribute(PlayerEnum.IN_MATCH)
	gui.Enabled = inMatch == false or inMatch == nil
end

return MenuHandler
