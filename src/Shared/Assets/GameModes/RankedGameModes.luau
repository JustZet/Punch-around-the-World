local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local GameModeEnum = require(ReplicatedStorage.Shared.Enums.GameModeEnum)

local RankedGameModes = {
	Solo = GameMode.new(1, "Solo Mode", "Solo ranked", GameModeEnum.SOLO, 1, 1, 2),
	Duo = GameMode.new(2, "Duo Mode", "Duo ranked", GameModeEnum.DUO, 2, 2, 4),
	Squad = GameMode.new(3, "Squad Mode", "Squad ranked", GameModeEnum.SQUAD, 4, 4, 8),
}

return RankedGameModes
