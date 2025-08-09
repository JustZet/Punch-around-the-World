local Arena = require(game.ReplicatedStorage.Shared.Models.Arena.Arena)
local Weapons = require(game.ReplicatedStorage.Shared.Modules.Weapons)
local ArenasEnum = require(game.ReplicatedStorage.Shared.Enums.Arena)



local Arenas = {}


Arenas.ArenaList = {
	TowerOfPisa = Arena.new(
		1,
		"Leaning Tower Of Pisa",
		ArenasEnum.PISA_TOWER,
		"#b0c987",
		4,
		2,
		"rbxassetid://75648725718632",
		"rbxassetid://126440805499398",
		{ Weapons.Pizza, Weapons.RedWine, Weapons.PastaSpoon }
	),
	EiffelTower = Arena.new(
		2,
		"Eiffel Tower",
		ArenasEnum.EIFFEL,
		"#9db4d3",
		4,
		2,
		"rbxassetid://127320797924076",
		"rbxassetid://100867874078676",
		{ Weapons.Baguette, Weapons.Cheese, Weapons.Parfume }
	),
	Fuji = Arena.new(
		3,
		"Fuji Mount",
		ArenasEnum.FUJI,
		"#ff989a",
		4,
		2,
		"rbxassetid://111903047610424",
		"rbxassetid://119820847163441",
		{ Weapons.Bamboo, Weapons.Fan, Weapons.TeaCup }
	),
	Random = Arena.new(
		0,
		"Random",
		ArenasEnum.RANDOM,
		"#ffffff",
		4,
		2,
		"rbxassetid://130857035113550",
		"rbxassetid://130857035113550",
		{}
	)
}


Arenas.SpawnFolderName = "SpawnSurfaces"
Arenas.KillFolderName = "KillSurfaces"
Arenas.WeaponSpawnFolderName = "WeaponSpawnSurfaces"

Arenas.Teams = { "Team1", "Team2" }

function Arenas.get(arenaName: string)
	return Arenas.ArenaList[arenaName]
end



function Arenas.getAll(): { [string]: Arena.Arena }
	return Arenas.ArenaList
end


function Arenas.hasEnoughSpawns(arenaModel: Model, team1Count: number, team2Count: number): boolean
	local spawnsFolder = arenaModel:FindFirstChild(Arenas.SpawnFolderName)
	if not spawnsFolder then return false end

	local team1 = spawnsFolder:FindFirstChild(Arenas.Teams[1])
	local team2 = spawnsFolder:FindFirstChild(Arenas.Teams[2])
	if not team1 or not team2 then return false end

	return #team1:GetChildren() >= team1Count and #team2:GetChildren() >= team2Count
end

return Arenas
