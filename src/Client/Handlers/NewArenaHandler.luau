local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Arenas = require(ReplicatedStorage.Shared.Modules.Arenas)
local ArenaModel = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local PlayerModule = require(ReplicatedStorage.Shared.Modules.PlayerModule)

local ArenaUIUtils = require(script.Parent.Parent.Modules.ArenaUIManager)
local ArenaConfig = require(script.Parent.Parent.Modules.ArenaConfig)
local Arena = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local UIUtils = require(script.Parent.Parent.Modules.UIUtils)

local ArenaTemplate = require(script.Parent.Parent.Modules.Teamplates.ArenaTemplate)

local ArenaHandler = {}

local Player = Players.LocalPlayer
local gui, frame, mapFrame, mapsItemsGrid, mapsFrame, mapsBodyFrame, mapNameLabel, mapDateLabel, mapWallpaper
local arenaTemplate, playerTemplate
local countDown

local arenaButtons: { [number]: ArenaTemplate.ArenaTemplate } = {}
local selectedIndex = nil

function ArenaHandler.init()
	gui = Player:WaitForChild("PlayerGui"):WaitForChild("ArenaSelectFrame")
	frame = gui:WaitForChild("Frame")
	mapFrame = frame:WaitForChild("MapFrame")
	mapsFrame = frame:WaitForChild("Maps")

	mapsBodyFrame = mapsFrame:WaitForChild("Body")
	mapsItemsGrid = mapsBodyFrame:WaitForChild("Items")

	mapNameLabel = mapFrame:WaitForChild("Name")
	mapDateLabel = mapFrame:WaitForChild("Date")
	mapWallpaper = mapFrame:WaitForChild("Wallpaper")

	arenaTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("Arena")
	playerTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("ArenaPlayerButton")
	countDown = frame:WaitForChild("MapCountDown")

	ArenaConfig.loadArenaList()
	ArenaHandler.populateCarousel()

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		if input.KeyCode == Enum.KeyCode.Right then
			selectedIndex = math.clamp(selectedIndex + 1, 1, #arenaButtons)
			ArenaHandler.updateSelection()
		elseif input.KeyCode == Enum.KeyCode.Left then
			selectedIndex = math.clamp(selectedIndex - 1, 1, #arenaButtons)
			ArenaHandler.updateSelection()
		end
	end)

	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectVisibility.OnClientEvent:Connect(function(isVisible: boolean)
		gui.Enabled = isVisible
	end)

	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelection.OnClientEvent:Connect(function(selection)
		print(selection)
		ArenaHandler.updateArenaPlayerIcons(selection)
	end)

	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectCountdown.OnClientEvent:Connect(function(time)
		countDown.Text = tostring(time)
		UIUtils.playZoomInOutAnimation(countDown)
	end)
end

function ArenaHandler.clearCarousel()
	for _, child in pairs(mapsItemsGrid:GetChildren()) do
		if not child:IsA("UIGridLayout") or child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	arenaButtons = {}
end

function ArenaHandler.createArenaCard(arena: Arena.Arena)
	template = ArenaTemplate.new(arena)
	template.card.Parent = mapsItemsGrid
	template.card.MouseButton1Click:Connect(function()
		if selectedIndex ~= arena.Id then
			selectedIndex = arena.Id
			ArenaHandler.updateSelection()

			ReplicatedStorage.RemoteEvents.Lobby.ArenaSelection:FireServer(arena.FileName)
		end
	end)

	arenaButtons[arena.Id] = template
	return template.card
end

function ArenaHandler.populateCarousel()
	ArenaHandler.clearCarousel()
	for i, arena in ipairs(ArenaConfig.arenaList) do
		ArenaHandler.createArenaCard(arena)
	end
end

function ArenaHandler.updateSelection()
	for id, template in pairs(arenaButtons) do
		template:setSelected(id == selectedIndex)
	end

	local selectedTemplate = arenaButtons[selectedIndex]
	if selectedTemplate then
		local selectedCard = selectedTemplate.card
		local relativeX = selectedCard.AbsolutePosition.X - mapsItemsGrid.AbsolutePosition.X
		TweenService:Create(mapsItemsGrid, TweenInfo.new(0.3), {
			CanvasPosition = Vector2.new(relativeX, 0),
		}):Play()

		ReplicatedStorage.RemoteEvents.Lobby.ShowGameSelect:FireServer(selectedTemplate.arena.Name)
		mapNameLabel.Text = selectedTemplate.arena.Name or ""
		mapNameLabel.TextColor3 = Color3.fromHex(selectedTemplate.arena.TextColor)
		mapWallpaper.Image = selectedTemplate.arena.Icon
	end
end

function ArenaHandler.updateArenaPlayerIcons(selectionList)
	for _, arena: ArenaModel.Arena in ipairs(ArenaConfig.arenaList) do
		local template = arenaButtons[arena.Id]
		print(template)
		if template then
			local arenaName = tostring(arena.FileName)
			local playerIDs = selectionList[arenaName] or {}
			template:setPlayers(playerIDs)
		end
	end
end

return ArenaHandler
