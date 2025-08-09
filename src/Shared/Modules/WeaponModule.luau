local Weapons = require(game.ReplicatedStorage.Shared.Models.Weapons)
local Weapon = require(game.ReplicatedStorage.Shared.Models.Weapon.Weapon)


local WeaponModule = {}

function WeaponModule.getWeaponInfoFromInstance(tool: Instance): Weapon.Weapon?
	if not tool or not tool:IsA("Tool") then
		warn("Invalid tool passed")
		return nil
	end

	local toolName = tool.Name
	local weaponData = Weapons[toolName]
    print(weaponData)

	if weaponData then
		return weaponData
	else
		warn("Weapon info not found for tool name:", toolName)
		return nil
	end
end




return WeaponModule
