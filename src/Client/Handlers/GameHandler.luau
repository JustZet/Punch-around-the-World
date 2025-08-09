local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local HpModule = require(script.Parent.Parent.Modules.HpModule)
local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)
local PlayerTeamAvatarTemplate = require(script.Parent.Parent.Modules.Teamplates.PlayerTeamAvatarTemplate)
local LifeTemplate = require(script.Parent.Parent.Modules.Teamplates.LifeTemplate)
local UIUtils = require(script.Parent.Parent.Modules.UIUtils)

local GameHandler = {}

local playerTemplates = {} -- [Player] = PlayerTeamAvatarTemplate

local gui
local livesFrame, hp, hpBar, teams
local team1, team2
local countDown, gameTimeLeft

function GameHandler.init()
	gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameFrame")
	hp = gui:WaitForChild("CanvasGroup")
	teams = gui:WaitForChild("Teams")
	hpBar = hp:WaitForChild("HpBarFill")
	livesFrame = gui:WaitForChild("Lives")
	team1 = teams:WaitForChild("Team1")
	team2 = teams:WaitForChild("Team2")
	countDown = gui:WaitForChild("CountDown")
	gameTimeLeft = gui:WaitForChild("TimeLeft")

	ReplicatedStorage.RemoteEvents.Game.GameStarted.OnClientEvent:Connect(
		function(playersTeam1: { Player }, playersTeam2: { Player })
			gui.Enabled = true
			GameHandler.updateTeams(playersTeam1, playersTeam2)
		end
	)

	ReplicatedStorage.RemoteEvents.Game.GameEnded.OnClientEvent:Connect(
		function(playersTeam1: { Player }, playersTeam2: { Player })
			gui.Enabled = false
		end
	)

	ReplicatedStorage.RemoteEvents.Game.CountDown.OnClientEvent:Connect(function(isVisible: boolean, text: string?)
		if isVisible ~= nil then
			countDown.Visible = isVisible
			if text then
				countDown.Text = text
			end
		else
			countDown.Visible = false
		end
	end)

	ReplicatedStorage.RemoteEvents.Game.GameTimeLeft.OnClientEvent:Connect(function(isVisible: boolean, text: string?)
		if isVisible ~= nil then
			gameTimeLeft.Visible = isVisible
			if text then
				gameTimeLeft.Text = text
			end
		else
			gameTimeLeft.Visible = false
		end
	end)



	Player:GetAttributeChangedSignal(PlayerEnum.IN_MATCH):Connect(function()
		gui.Enabled = Player:GetAttribute(PlayerEnum.IN_MATCH)
	end)

	Player:GetAttributeChangedSignal(PlayerEnum.HP):Connect(function()
		local newHP = Player:GetAttribute(PlayerEnum.HP)
		if newHP then
			GameHandler.bindHp(Player)
		end
	end)

	Player:GetAttributeChangedSignal(PlayerEnum.LIVES):Connect(function()
		local newLives = Player:GetAttribute(PlayerEnum.LIVES)
		if newLives then
			GameHandler.bindLives(Player, newLives)
		end
	end)

	local currentLives = Player:GetAttribute(PlayerEnum.LIVES)
	if currentLives then
		GameHandler.bindLives(Player, currentLives)
	end

	local currentHP = Player:GetAttribute(PlayerEnum.HP)
	if currentHP then
		GameHandler.bindHp(Player)
	end

	local inMatch = Player:GetAttribute(PlayerEnum.IN_MATCH)
	if inMatch then
		gui.Enabled = Player:GetAttribute(PlayerEnum.IN_MATCH)
	end
end

function GameHandler.updateTeams(team1Players: { Player }, team2Players: { Player })
	GameHandler.clearPlayerContainerChildren(team1)
	GameHandler.clearPlayerContainerChildren(team2)

	playerTemplates = {} -- reset

	if team1Players then
		for _, player in ipairs(team1Players) do
			local template = PlayerTeamAvatarTemplate.new(player)
			template.view.Parent = team1
			playerTemplates[player] = template

			GameHandler.connectLifeChange(player)
		end
	end

	if team2Players then
		for _, player in ipairs(team2Players) do
			local template = PlayerTeamAvatarTemplate.new(player)
			template.view.Parent = team2
			playerTemplates[player] = template

			GameHandler.connectLifeChange(player)
		end
	end
end

function GameHandler.clearLifeContainerChildren()
	for _, child in ipairs(livesFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

function GameHandler.clearPlayerContainerChildren(container)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

-- region Connectors
function GameHandler.connectLifeChange(player: Player)
	player:GetAttributeChangedSignal(PlayerEnum.LIVES):Connect(function()
		local newLives = player:GetAttribute(PlayerEnum.LIVES)
		if newLives ~= nil then
			GameHandler.bindLives(player, newLives)
		end
	end)
end

-- endregion

-- region Binders

function GameHandler.bindLives(player: Player, count: number)
	if player.UserId == Player.UserId then
		GameHandler.clearLifeContainerChildren()
		for i = 1, count do
			local view = LifeTemplate.new()
			view.Parent = livesFrame
		end
	end

	local template = playerTemplates[player]
	if template then
		template:bindLifes(count)
	end

	-- Optionally notify the player or others
	-- e.g. show a popup, play a sound, update scoreboard, etc.
end

function GameHandler.bindHp(player: Player)
	if player.Character then
		local humanoid = player.Character:WaitForChild("Humanoid")
		HpModule.bindHpBar(humanoid, hp, hpBar)
	end

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		HpModule.bindHpBar(humanoid, hp, hpBar)
	end)
end

-- endregion

return GameHandler
