local Databases = require(game.ServerScriptService.Server.Database.Databases)

local ProfileModel = {}
ProfileModel.__index = ProfileModel

function ProfileModel.new(player: Player, self)
	repeat
		task.wait()
	until player.Character ~= nil
	if self then
		return setmetatable(self, ProfileModel)
	end
	local self = setmetatable({}, ProfileModel)
	self.player = player

	-- Stats
	self.level = 1
	self.kills = 0
	self.wins = 0
	self.minutes = 0

	-- Currency
	self.coins = 0
	return self
end

function ProfileModel:setPlayer(player: Player)
	self.player = player
end
function ProfileModel:setCoins(coins: number)
	self.coins = coins
end
function ProfileModel:setLevel(level: number)
	self.level = level

	pcall(function()
		Databases.level:SetAsync(tostring(self.player.UserId), self.level)
	end)
end
function ProfileModel:setWins(wins: number)
	self.wins = wins

	pcall(function()
		Databases.wins:SetAsync(tostring(self.player.UserId), self.wins)
	end)
end
function ProfileModel:setKills(kills: number)
	self.kills = kills

	pcall(function()
		Databases.kills:SetAsync(tostring(self.player.UserId), self.minutes)
	end)
end
function ProfileModel:setMinutes(minutes: number)
	self.minutes = minutes

	pcall(function()
		Databases.minutes:SetAsync(tostring(self.player.UserId), self.minutes)
	end)
end


function ProfileModel:updateTimePlayed()
    local now = tick()
    local elapsedSeconds = now - (self.joinTime or now)
    local elapsedMinutes = math.floor(elapsedSeconds / 60)
    
    self.minutes = self.minutes + elapsedMinutes
    self.joinTime = now  -- reset joinTime if updating periodically

    -- Save to DataStore
    pcall(function()
        Databases.minutes:SetAsync(tostring(self.player.UserId), self.minutes)
    end)
end

return ProfileModel
