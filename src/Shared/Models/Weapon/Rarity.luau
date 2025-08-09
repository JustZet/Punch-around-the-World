-- Rarity.lua

export type Rarity = {
	Name: string,
	Id: number,
	Color: Color3,
}

local Rarities: { [string]: Rarity } = {
	Common = {
		Name = "Common",
		Id = 1,
		Color = Color3.fromRGB(200, 200, 200),
	},
	Rare = {
		Name = "Rare",
		Id = 2,
		Color = Color3.fromRGB(50, 100, 255),
	},
	Epic = {
		Name = "Epic",
		Id = 3,
		Color = Color3.fromRGB(170, 0, 255),
	},
	Legendary = {
		Name = "Legendary",
		Id = 4,
		Color = Color3.fromRGB(255, 215, 0),
	},
}

-- Utility to get rarity by Id
local function getById(id: number): Rarity?
	for _, rarity in pairs(Rarities) do
		if rarity.Id == id then
			return rarity
		end
	end
	return nil
end

-- Utility to get rarity by name (case-insensitive)
local function getByName(name: string): Rarity?
	return Rarities[name]
end

return {
	Rarities = Rarities,
	getById = getById,
	getByName = getByName,
}
