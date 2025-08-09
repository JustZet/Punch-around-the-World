-- PlayerDataModule.lua
local ProfileModule = {}

export type Profile = {
	DisplayName: string,
	AvatarId: number,
}

export type GameData = {
	Match: any?,
	Team: string?,
	Kills: number,
	Deaths: number,
	Lives: number,
}

export type PlayerData = {
	Player: Player,
	Coins: number,
	Level: number,
	Profile: Profile,
	Game: GameData,
}

-- Constructor
function ProfileModule.new(player: Player): PlayerData
	local self: PlayerData = {
		Player = player,
		Coins = 0,
		Level = 1,
		Profile = {
			DisplayName = player.DisplayName,
			AvatarId = player.UserId,
		},
		Game = {
			Match = nil,
			Team = nil,
			Kills = 0,
			Deaths = 0,
			Lives = 3,
		},
	}

	return self
end

return ProfileModule
