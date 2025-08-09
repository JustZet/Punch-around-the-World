local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local services = {}

-- Load services
services.MatchService = require(script.Parent.Services.MatchService)
services.ArenaService = require(script.Parent.Services.ArenaService)
services.GameService = require(script.Parent.Services.GameService)
services.PartyService = require(script.Parent.Services.PartyService)

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
