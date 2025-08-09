local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileModule = require(ReplicatedStorage.Shared.Modules.ProfileModule)


local Players = game:GetService("Players")

local PlayerEnum = require(ReplicatedStorage.Shared.Enums.Player)


local PlayerModule = {}

local playerState: { [Player]: {} } = {}
local playerProfiles: { [Player]: { ProfileModule.Profile } } = {}

function PlayerModule.init(player: Player)
	playerProfiles[player] = ProfileModule.new(player)

	playerState[player] = {}

	player:SetAttribute(PlayerEnum.LIVES, 3)
	player:SetAttribute(PlayerEnum.HP, 100)
	player:SetAttribute(PlayerEnum.COINS, 0)
	player:SetAttribute(PlayerEnum.IN_MATCH, false)
end

function PlayerModule.cleanup(player: Player)
	playerProfiles[player] = nil
	playerState[player] = nil
end

function PlayerModule.set(player: Player, key: string, value: any)
	player:SetAttribute(key, value)
end

function PlayerModule.get(player: Player, key: string)
	return player:GetAttribute(key)
end

function PlayerModule.increment(player: Player, key: string, amount: number)
	local value = player:GetAttribute(key) or 0
	player:SetAttribute(key, value + amount)
end

function PlayerModule.decrement(player: Player, key: string, amount: number)
	PlayerModule.increment(player, key, -amount)
end



function PlayerModule.moveCharacterTo(player: Player, position: Vector3)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character:MoveTo(position)
	else
		player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
		player.Character:MoveTo(position)
	end
end

return PlayerModule
