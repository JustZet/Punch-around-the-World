local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Player = Players.LocalPlayer

local PlayerPartyTemplate = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Teamplates.PlayerPartyTemplate)
local PartyModule = require(script.Parent.Parent.Modules.PartyModule)
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local EventModule = require(ReplicatedStorage.Shared.Modules.EventModule)

local MatchPartyHandler = {}

local gui, background: Frame, partyFrame: Frame, actionsFrame: Frame
local partyTeam: Frame, partyGameMode: Frame, partyMembers: ScrollingFrame, partyTabs: Frame, partyTeam: Frame, partyWallpaper: ImageLabel, partyName: TextLabel
local tabParty: TextButton, tabFriends: TextButton
local userLogo: ImageButton, userName: TextButton, buttonStart: TextButton
local partyWallpaper: ImageLabel, partyName: TextLabel
local dismissButton: ImageButton
local teammateAvatarTemplate, playerToInviteTemplate

function MatchPartyHandler.init()
	gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameParty")
	teammateAvatarTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("PlayerAvatar")
	playerToInviteTemplate = ReplicatedStorage.Assets.Gui:WaitForChild("PlayerInvite")

	background = gui:WaitForChild("Frame")
	partyFrame = background:WaitForChild("FrameParty")
	actionsFrame = background:WaitForChild("FrameActions")
	partyTeam = partyFrame:WaitForChild("Team")
	partyGameMode = partyFrame:WaitForChild("GameMode")
	partyMembers = partyFrame:WaitForChild("Suggested")
	partyTabs = partyFrame:WaitForChild("Tabs")
	partyWallpaper = partyGameMode:WaitForChild("Wallpaper")
	partyName = partyGameMode:WaitForChild("Name")
	tabParty = partyTabs:WaitForChild("Party")
	tabFriends = partyTabs:WaitForChild("Friends")
	userLogo = actionsFrame:WaitForChild("PlayerLogo")
	userName = actionsFrame:WaitForChild("PlayerName")
	buttonStart = actionsFrame:WaitForChild("Start")
	dismissButton = partyFrame:WaitForChild("DismissButton")



	EventModule.Remote.PartyUpdated.OnClientEvent:Connect(function(players: { Player }, gameMode: GameMode.GameMode?)
		if not gameMode then
			warn("Game mode is null")
			return
		end
        print(gameMode)

        
		MatchPartyHandler.bindPartyMembers(players, gameMode.TeamPlayerCount)

		if gameMode then
			partyName.Text = gameMode.DisplayName
		end

		buttonStart.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.Lobby.MatchQueueStarted:FireServer(gameMode, players)
		end)
	end)

    EventModule.Remote.PartyShow.OnClientEvent:Connect(function(mode: GameMode.GameMode)
		gui.Enabled = true

        tabParty.MouseButton1Click:Connect(function()
            MatchPartyHandler.selectTab(tabParty, mode)
        end)
        tabFriends.MouseButton1Click:Connect(function()
            MatchPartyHandler.selectTab(tabFriends, mode)
        end)

        MatchPartyHandler.selectTab(tabFriends, mode)
        MatchPartyHandler.bindPlayer(Player)
        MatchPartyHandler.bindPartyMembers({ Player }, mode.TeamPlayerCount)
	end)

	dismissButton.MouseButton1Click:Connect(function()
		gui.Enabled = false
	end)
end

-- region Actions
function MatchPartyHandler.selectTab(selectedTab, mode: GameMode.GameMode)
	for _, tab in ipairs({ tabParty, tabFriends }) do
		PartyModule.tweenTab(tab, PartyModule.ORIGINAL_TAB_SIZE, PartyModule.UNSELECTED_COLOR)
	end

	PartyModule.tweenTab(selectedTab, PartyModule.SELECTED_TAB_SIZE, PartyModule.SELECTED_COLOR)

	-- Clear the partyMembers list with a quick fade (optional)
	for _, child in ipairs(partyMembers:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	-- Small delay for animation finish (optional: yields briefly)
	task.delay(0.15, function()
		if selectedTab == tabParty then
			MatchPartyHandler.bindLobbyPlayers(Player, mode)
		elseif selectedTab == tabFriends then
			MatchPartyHandler.bindFriends(Player, mode)
		end
	end)
end
-- endregion

-- region Binders
function MatchPartyHandler.bindPartyMembers(players: { Player }, maxTeamSize: number)
	-- Clear previous avatars
	for _, child in ipairs(partyTeam:GetChildren()) do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end

	for i = 1, maxTeamSize do
		local avatarButton = teammateAvatarTemplate:Clone()
		avatarButton.Visible = true
		avatarButton.Name = "TeamMember_" .. i

		if players[i] then
			avatarButton.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
				.. players[i].UserId
				.. "&width=150&height=150&format=png"
			avatarButton.ImageTransparency = 0
		else
			avatarButton.Image = PartyModule.PLACEHOLDER_AVATAR
			avatarButton.ImageTransparency = 0.6
		end

		avatarButton.Parent = partyTeam
	end
end

function MatchPartyHandler.bindPlayer(player: Player)
	userLogo.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
		.. player.UserId
		.. "&width=150&height=150&format=png"
	userName.Text = player.Name
end

function MatchPartyHandler.bindLobbyPlayers(player: Player, mode: GameMode.GameMode)
	local players = PartyModule.getLobbyPlayers(player)
	for _, data in ipairs(players) do
        local template = PlayerPartyTemplate.new(data.UserId, data.Name)
        template:setOnInviteClicked(function(playerID: number) 
            EventModule.Remote.PartySendInvite:FireServer(playerID, mode)
        end)
		template.view.Parent = partyMembers
	end
end

function MatchPartyHandler.bindFriends(player: Player, mode: GameMode.GameMode)
	local friends = PartyModule.getFriends(player)
	for _, friendData in ipairs(friends) do
        local template = PlayerPartyTemplate.new(friendData.Id, friendData.Username)
        template:setOnInviteClicked(function(playerID: number) 
            EventModule.Remote.PartySendInvite:FireServer(playerID, mode)
        end)
		template.view.Parent = partyMembers
	end
end
-- endregion

-- region Templates
function MatchPartyHandler.getPlayerAvatar(player: Player): ImageButton
	local card = teammateAvatarTemplate:Clone()
	card.Visible = true
	card.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
		.. player.UserId
		.. "&width=150&height=150&format=png"
	return card
end
-- endregion

return MatchPartyHandler
