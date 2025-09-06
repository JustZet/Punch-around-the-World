-- Weapon.lua
local ArenasEnum = require(game.ReplicatedStorage.Shared.Enums.Arena)
local Weapon = require(game.ReplicatedStorage.Shared.Models.Weapon.Weapon)
local Players = game:GetService("Players")


local Arena = {}
Arena.__index = Arena

export type Arena = {
	Id: number,
	Name: string,
	FileName: ArenasEnum,
	TextColor: string,
	MaxPlayerCount: number,
	MinPlayerCount: number,
	Weapons: { Weapon.Weapon }?,
	Icon: string,
	WallpaperWhited: string,
}


function Arena.new(
	id: number,
	name: string,
	fileName: ArenasEnum,
	textColor: string,
	maxPlayer: number,
	minPlayer: number,
	icon: string,
	wallpaperWhited: string,
	weapons: { Weapon.Weapon }?
): Arena
	return setmetatable({
		Id = id,
		Name = name,
		FileName = fileName,
		TextColor = textColor,
		MaxPlayerCount = maxPlayer,
		MinPlayerCount = minPlayer,
		Icon = icon,
		WallpaperWhited = wallpaperWhited,
		Weapons = weapons,
	}, Arena)
end

return Arena
