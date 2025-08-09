-- Types.lua

export type WeaponType = {
	Id: number,
	Name: string,
	Color: Color3,
}

local Types: { [string]: WeaponType } = {
	Melee = {
		Id = 1,
		Name = "Melee",
		Color = Color3.fromRGB(255, 100, 100), -- red
	},
	Ranged = {
		Id = 2,
		Name = "Ranged",
		Color = Color3.fromRGB(100, 150, 255), -- blue
	},
	Healing = {
		Id = 3,
		Name = "Healing",
		Color = Color3.fromRGB(100, 255, 150), -- green
	},
	Utility = {
		Id = 4,
		Name = "Utility",
		Color = Color3.fromRGB(255, 255, 100), -- yellow
	},
}

local function getById(id: number): WeaponType?
	for _, weaponType in pairs(Types) do
		if weaponType.Id == id then
			return weaponType
		end
	end
	return nil
end

local function getByName(name: string): WeaponType?
	return Types[name]
end

return {
	Types = Types,
	getById = getById,
	getByName = getByName,
}
