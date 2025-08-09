-- Weapons.lua

local TypesModule = require(game.ReplicatedStorage.Shared.Models.Weapon.Types)
local RarityModule = require(game.ReplicatedStorage.Shared.Models.Weapon.Rarity)
local Weapon = require(game.ReplicatedStorage.Shared.Models.Weapon.Weapon)

local Types = TypesModule.Types
local Rarities = RarityModule.Rarities

local Weapons = {
	Pizza = Weapon.new(1, "Pizza", Rarities.Common, Types.Melee, "rbxassetid://..."),
	RedWine = Weapon.new(2, "Red Wine", Rarities.Common, Types.Melee, "rbxassetid://..."),
	PastaSpoon = Weapon.new(3, "Pasta Spoon", Rarities.Common, Types.Melee, "rbxassetid://..."),
	Baguette = Weapon.new(4, "Baguette", Rarities.Common, Types.Melee, "rbxassetid://..."),
	Cheese = Weapon.new(5, "Cheese", Rarities.Common, Types.Melee, "rbxassetid://..."),
	Parfume = Weapon.new(6, "Explosive Parfume", Rarities.Common, Types.Melee, "rbxassetid://..."),
	Bamboo = Weapon.new(7, "Bamboo", Rarities.Common, Types.Melee, "rbxassetid://..."),
	Fan = Weapon.new(8, "Fan", Rarities.Common, Types.Melee, "rbxassetid://..."),
	TeaCup = Weapon.new(9, "Tea Cup", Rarities.Common, Types.Melee, "rbxassetid://..."),
}

return Weapons
