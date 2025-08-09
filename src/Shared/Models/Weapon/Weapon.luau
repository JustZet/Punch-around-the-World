-- Weapon.lua
local Types = require(game.ReplicatedStorage.Shared.Models.Weapon.Types)
local Rarities = require(game.ReplicatedStorage.Shared.Models.Weapon.Rarity)

local Weapon = {}
Weapon.__index = Weapon

export type Weapon = {
	ID: number,
	Name: string,
	Rarity: Rarities.Rarity,
	Type: Types.WeaponType,
	Icon: string,
}

function Weapon.new(
	id: number,
	name: string,
	rarity: Rarities.Rarity,
	weaponType: Types.WeaponType,
	icon: string
): Weapon
	return setmetatable({
		ID = id,
		Name = name,
		Rarity = rarity,
		Type = weaponType,
		Icon = icon,
	}, Weapon)
end

return Weapon
