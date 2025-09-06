-- ModuleScript: TimeFormatter
local TimeFormatter = {}

-- Formats minutes into "Xd Yh Zm" but always keeps at least 2 levels
function TimeFormatter.formatMinutes(minutes: number): string
	if minutes <= 0 then
		return "0m"
	end

	local days = math.floor(minutes / 1440) -- 60*24
	local hours = math.floor((minutes % 1440) / 60)
	local mins = minutes % 60

	local parts = {}

	if days > 0 then
		table.insert(parts, days .. "d")
		if hours > 0 then
			table.insert(parts, hours .. "h")
		else
			table.insert(parts, mins .. "m") -- fallback to show days + minutes
		end
	elseif hours > 0 then
		table.insert(parts, hours .. "h")
		if mins > 0 then
			table.insert(parts, mins .. "m")
		else
			table.insert(parts, "0m") -- force minutes if missing
		end
	else
		table.insert(parts, mins .. "m")
	end

	return table.concat(parts, " ")
end

return TimeFormatter
