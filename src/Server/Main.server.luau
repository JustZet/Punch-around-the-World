local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

Players.CharacterAutoLoads = false 

local services = {}

-- Load services
services.MatchService = require(script.Parent.Services.MatchService)
services.ArenaService = require(script.Parent.Services.ArenaService)
services.GameService = require(script.Parent.Services.GameService)
services.PartyService = require(script.Parent.Services.PartyService)
services.LeaderboardService = require(script.Parent.Services.LeaderboardService)

-- Initialize all
for _, service in pairs(services) do
	if type(service.init) == "function" then
		service.init(services) -- Pass the entire service table
	end
end

-- You can also start services if they need it
for _, service in pairs(services) do
	if type(service.start) == "function" then
		task.spawn(service.start)
	end
end


-- for _, surface in ipairs(CollectionService:GetTagged("SpawnSurface")) do
--     print("Found tagged spawn surface:", surface.Name)
-- end
