local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameMode = require(ReplicatedStorage.Shared.Models.Game.GameMode)
local GameModeEnum = require(ReplicatedStorage.Shared.Enums.GameModeEnum)

local ClasicGameModes = {
	Solo = GameMode.new(1, "Solo Mode", "Solo", GameModeEnum.SOLO, 1, 1, 1),
	Duo = GameMode.new(2, "Duo Mode", "Duo", GameModeEnum.DUO, 2, 2, 2),
	Squad = GameMode.new(3, "Squad Mode", "Squad", GameModeEnum.SQUAD, 4, 4, 4),
}

return ClasicGameModes
