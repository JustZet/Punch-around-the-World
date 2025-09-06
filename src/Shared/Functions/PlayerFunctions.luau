local Players = game:GetService("Players")

local PlayerFunctions = {}

function PlayerFunctions.getPlayerName(playerID: number): string?
	local success, nameOrErr = pcall(function()
		return Players:GetNameFromUserIdAsync(playerID)
	end)

	if success then
		return nameOrErr
	else
		warn("Failed to get player name:", nameOrErr)
		return nil
	end
end

function PlayerFunctions.getPlayerAvatar(playerID: number): string
    return "https://www.roblox.com/headshot-thumbnail/image?userId=".. playerID.. "&width=150&height=150&format=png"
	
end

return PlayerFunctions