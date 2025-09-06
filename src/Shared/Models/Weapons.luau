local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
-- Weapons.lua

local TypesModule = require(game.ReplicatedStorage.Shared.Models.Weapon.Types)
local RarityModule = require(game.ReplicatedStorage.Shared.Models.Weapon.Rarity)
local Weapon = require(game.ReplicatedStorage.Shared.Models.Weapon.Weapon)

local Types = TypesModule.Types
local Rarities = RarityModule.Rarities

local Weapons = {
	Pizza = Weapon.new(
		ServerStorage.Weapons.Pizza.WeaponID,
		ServerStorage.Weapons.Pizza,
		"Pizza",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	RedWine = Weapon.new(
		ServerStorage.Weapons.RedWine.WeaponID,
		ServerStorage.Weapons.RedWine,
		"Red Wine",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	PastaSpoon = Weapon.new(
		ServerStorage.Weapons.PastaSpoon.WeaponID,
		ServerStorage.Weapons.PastaSpoon,
		"Pasta Spoon",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	Baguette = Weapon.new(
		ServerStorage.Weapons.Baguette.WeaponID,
		ServerStorage.Weapons.Baguette,
		"Baguette",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	Cheese = Weapon.new(
		ServerStorage.Weapons.Cheese.WeaponID,
		ServerStorage.Weapons.Cheese,
		"Cheese",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	Parfume = Weapon.new(
		ServerStorage.Weapons.Parfume.WeaponID,
		ServerStorage.Weapons.Parfume,
		"Explosive Parfume",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	Bamboo = Weapon.new(
		ServerStorage.Weapons.Bamboo.WeaponID,
		ServerStorage.Weapons.Bamboo,
		"Bamboo",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	Fan = Weapon.new(
		ServerStorage.Weapons.Fan.WeaponID,
		ServerStorage.Weapons.Fan,
		"Fan",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
	TeaCup = Weapon.new(
		ServerStorage.Weapons.TeaCup.WeaponID,
		ServerStorage.Weapons.TeaCup,
		"Tea Cup",
		Rarities.Common,
		Types.Melee,
		"rbxassetid://..."
	),
}

return Weapons
