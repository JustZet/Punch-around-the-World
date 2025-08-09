local GameModeEnum = require(game.ReplicatedStorage.Shared.Enums.GameModeEnum)

local GameMode = {}
GameMode.__index = GameMode

export type GameMode = {
	Name: string,
	DisplayName: string,
	Id: number,
	Value: GameModeEnum,
	MinPartySize: number,
	MaxPartySize: number,
	TeamPlayerCount: number,
}

function GameMode.new(
	id: number,
	name: string,
	displayName: string,
	value: GameModeEnum,
	minPartySize: number,
	maxPartySize: number,
	TeamPlayerCount: number
): GameMode
	return setmetatable({
		Id = id,
		Name = name,
		DisplayName = displayName,
		Value = value,
		MinPartySize = minPartySize,
		MaxPartySize = maxPartySize,
		TeamPlayerCount = TeamPlayerCount,
	}, GameMode)
end

return GameMode
