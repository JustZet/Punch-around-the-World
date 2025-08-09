local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerModule = {}

function PlayerModule.getPlayerAvatarIcon(playerId)
	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(playerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)

	if success then
		return result -- result is a valid URL like "rbxthumb://..."
	else
		warn("Failed to get avatar for:", playerId, result)
		return ""
	end
end

return PlayerModule
