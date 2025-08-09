local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Arenas = require(ReplicatedStorage.Shared.Modules.Arenas)
local ArenaModel = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local PlayerModule = require(ReplicatedStorage.Shared.Modules.PlayerModule)

local ArenaUIUtils = require(script.Parent.Parent.Modules.ArenaUIManager)
local ArenaConfig = require(script.Parent.Parent.Modules.ArenaConfig)
local Arena = require(ReplicatedStorage.Shared.Models.Arena.Arena)
local UIUtils = require(script.Parent.Parent.Modules.UIUtils)

local ArenaHandler = {}

local Player = Players.LocalPlayer
local gui, frame, mapFrame, mapsItemsGrid, mapsFrame, mapsBodyFrame, mapNameLabel, mapDateLabel, mapWallpaper
local arenaTemplate, playerTemplate
local countDown 

local arenaButtons = {}
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
		ArenaHandler.updateArenaPlayerIcons(selection)
	end)

	ReplicatedStorage.RemoteEvents.Lobby.ArenaSelectCountdown.OnClientEvent:Connect(function(time)
		countDown.Text = tostring(time)
		UIUtils.playZoomInOutAnimation(countDown)
	end)
end

function ArenaHandler.clearCarousel()
	ArenaUIUtils.clearCarousel(mapsItemsGrid)
	arenaButtons = {}
end

function ArenaHandler.createArenaCard(arena: Arena.Arena, index)
	local card = arenaTemplate:Clone()
	card.Name = "ArenaCard_" .. index
	card.Parent = mapsItemsGrid
	card.Visible = true

	local name: TextLabel = card.Frame:FindFirstChild("Name")
	local wallpaper: ImageLabel = card.Frame:FindFirstChild("ImageLabel")

	wallpaper.Image = arena.Icon or ""
	name.Text = arena.Name or ""

	ArenaUIUtils.clearPlayerIcons(card.Frame.PlayerIconsFrame)

	arenaButtons[index] = card

	card.MouseButton1Click:Connect(function()
		if selectedIndex ~= index then
			selectedIndex = index
			ArenaHandler.updateSelection()

			local selectedArena: ArenaModel.Arena = ArenaConfig.arenaList[selectedIndex]
			if selectedArena then
				ReplicatedStorage.RemoteEvents.Lobby.ArenaSelection:FireServer(selectedArena.FileName)
			end
		end
	end)

	return card
end

function ArenaHandler.populateCarousel()
	ArenaHandler.clearCarousel()
	for i, arena in ipairs(ArenaConfig.arenaList) do
		ArenaHandler.createArenaCard(arena, i)
	end
end

function ArenaHandler.updateSelection()
	for i, button in ipairs(arenaButtons) do
		local frame = button:WaitForChild("Frame")
		local imageLabel = frame:WaitForChild("ImageLabel")
		local stroke = frame:FindFirstChildOfClass("UIStroke")

		imageLabel.ImageColor3 = (i == selectedIndex) and Color3.fromHex("#ffffff") or Color3.fromHex("#aaaaaa")

		if stroke then
			stroke.Enabled = (i == selectedIndex)
		end
	end

	local selectedCard = arenaButtons[selectedIndex]
	if selectedCard then
		local relativeX = selectedCard.AbsolutePosition.X - mapsItemsGrid.AbsolutePosition.X
		TweenService:Create(mapsItemsGrid, TweenInfo.new(0.3), { CanvasPosition = Vector2.new(relativeX, 0) }):Play()
	end

	local selectedArena = ArenaConfig.arenaList[selectedIndex]
	ReplicatedStorage.RemoteEvents.Lobby.ShowGameSelect:FireServer(selectedArena.Name)

	mapNameLabel.Text = selectedArena.Name or ""
	mapNameLabel.TextColor3 = Color3.fromHex(selectedArena.TextColor)
	mapWallpaper.Image = selectedArena.Icon
end

-- selectionList: { { Arena = "PISA_TOWER", UserId = 123 }, ... }
function ArenaHandler.updateArenaPlayerIcons(selectionList)
	for i, arena: ArenaModel.Arena in ipairs(ArenaConfig.arenaList) do
		local card = arenaButtons[i]
		if card then
			local iconsFrame = card.Frame.PlayerIconsFrame
			ArenaUIUtils.clearPlayerIcons(iconsFrame)
			local arenaName = tostring(arena.FileName)
			local playerIDs = selectionList[arenaName]

			if playerIDs then
				for _, pid in ipairs(playerIDs) do
					local icon = playerTemplate:Clone()
					icon.Name = "Player_" .. pid
					icon.Visible = true
					icon.Parent = iconsFrame

					if pid == Players.LocalPlayer.UserId then
						icon.ImageColor3 = Color3.fromRGB(255, 255, 0)
					end

					icon.ImagePlayerAvatar.Image = PlayerModule.getPlayerAvatarIcon(pid)
				end
			end
		end
	end
end

return ArenaHandler
