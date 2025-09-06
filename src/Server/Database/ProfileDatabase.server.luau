local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Databases = require(script.Parent.Databases)
local ForLoops = require(ReplicatedStorage.Shared.Helpers.ForLoops)

    
local ProfileModel = require(ServerScriptService.Server.Database.Models.Profile)

local database = Databases.profiles

local playerClasses = {
    -- [29312932] = {"kills":10,....}
}

local onJoinTable = {
    -- If true then no data is set up
    [true] = function(player, result) 
        local model = ProfileModel.new(player)
        playerClasses[Players:GetUserIdFromNameAsync(player.Name)] = model
        print(model);
    end,

    -- If false then data is set up
    [false] = function(player, result) 
        local model = ProfileModel.new(player, HttpService:JSONDecode(result))
        model:setPlayer(player)
        playerClasses[Players:GetUserIdFromNameAsync(player.Name)] = model

        print(model);
    end,
}


function save(playerId, profile) 
    profile:updateTimePlayed()
    local success, err = pcall(function()  
        local data = HttpService:JSONEncode(profile)
        database:SetAsync(playerId, data)
    end)
end

function playerJoined(player: Player)
    print("Player joined")
    local playerId = Players:GetUserIdFromNameAsync(player.Name);
    local success, result = pcall(function()
        return database:GetAsync(playerId);
    end)

    if not success then
        warn("Data was not loaded")
    end

    onJoinTable[result == nil or result == "null"] (player, result)
end

function playerLeaves(player:Player)
    print("Player leaves")
    local playerId = Players:GetUserIdFromNameAsync(player.Name)
    save(playerId, playerClasses[playerId])
end


Players.PlayerAdded:Connect(playerJoined)
Players.PlayerRemoving:Connect(playerLeaves)

-- Running when server about to shut down
game:BindToClose(function()
    print("Server shut down...")
    -- ForLoops.pairsForLoop(save, playerClasses)
end)

while true do
    task.wait(60) 
    for _, profile in pairs(playerClasses) do
        profile:updateTimePlayed()
    end
end