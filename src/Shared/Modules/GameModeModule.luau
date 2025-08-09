local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameModesEnum = require(ReplicatedStorage.Shared.Enums.GameModeEnum)

local GameModeUtils = {}

function GameModeUtils.getMaxPlayers(mode)
    if mode == GameModesEnum.SOLO then
        return 1
    elseif mode == GameModesEnum.DUO then
        return 2
    elseif mode == GameModesEnum.SQUAD then
        return 4
    else
        return 8
    end
end
function GameModeUtils.getMinPlayers(mode)
    if mode == GameModesEnum.SOLO then
        return 1
    elseif mode == GameModesEnum.DUO then
        return 2
    elseif mode == GameModesEnum.SQUAD then
        return 4
    else
        return 8
    end
end


return GameModeUtils
