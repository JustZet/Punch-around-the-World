local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PartyModule = {}

PartyModule.SELECTED_TAB_SIZE = UDim2.new(0, 175, 0, 45)
PartyModule.ORIGINAL_TAB_SIZE = UDim2.new(0, 155, 0, 40)
PartyModule.SELECTED_COLOR = Color3.fromHex("#f9dfbb")
PartyModule.UNSELECTED_COLOR = Color3.fromHex("#f9f2d8")
PartyModule.PLACEHOLDER_AVATAR = "rbxassetid://90301368462487"

function PartyModule.tweenTab(guiObject: GuiObject, targetSize: UDim2, targetColor: Color3, duration)
	local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local goal = {
		Size = targetSize,
		BackgroundColor3 = targetColor
	}
	
	local tween = TweenService:Create(guiObject, tweenInfo, goal)
	tween:Play()
end

function PartyModule.getLobbyPlayers(player: Player): {Player}
	local lobbyPlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(lobbyPlayers, player)
	end
	return lobbyPlayers
end

function PartyModule.getFriends(player: Player)
	local success, pages = pcall(function()
		return Players:GetFriendsAsync(player.UserId)
	end)

	if success then
		local friends = {}
		while true do
			for _, friend in pairs(pages:GetCurrentPage()) do
				table.insert(friends, friend)
			end
			if pages.IsFinished then break end
			pages:AdvanceToNextPageAsync()
		end
		return friends
	else
		warn("Failed to get friends")
		return {}
	end
end

return PartyModule
