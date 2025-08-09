local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._listeners = {}
	return self
end

function Signal:Connect(listener)
	table.insert(self._listeners, listener)
	return {
		Disconnect = function()
			for i, l in ipairs(self._listeners) do
				if l == listener then
					table.remove(self._listeners, i)
					break
				end
			end
		end,
	}
end

function Signal:Fire(...)
	for _, listener in ipairs(self._listeners) do
		task.spawn(listener, ...)
	end
end

return Signal
