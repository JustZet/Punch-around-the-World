local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerModule = require(script.Parent.Parent.Modules.PlayerModule)

local Shared = {}

function Shared.init()
    Players.PlayerAdded:Connect(Shared._onPlayerAdded)
	Players.PlayerRemoving:Connect(Shared._onPlayerRemoving)
end

function Shared._onPlayerAdded(player: Player)
	PlayerModule.init(player)
end

function Shared._onPlayerRemoving(player: Player)
	PlayerModule.cleanup(player)
end

function Shared.addCoins(player: Player, amount: number)
	PlayerModule.increment(player, "Coins", amount)
end

return Shared
