local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClasicGameModes = require(ReplicatedStorage.Shared.Assets.GameModes.ClasicGameModes)

return {
	GameModes = {
		ClasicGameModes.Solo,
		ClasicGameModes.Duo,
		ClasicGameModes.Squad,
	},

	Positions = {
		UDim2.new(0.25, 0, 0.5, 0), -- Solo
		UDim2.new(0.5, 0, 0.5, 0), -- Duo
		UDim2.new(0.75, 0, 0.5, 0), -- Squad
	},

	OriginalSize = UDim2.new(0.2, 0, 0.55, 0),
	SelectedSize = UDim2.new(0.21, 0, 0.56, 0),
}
