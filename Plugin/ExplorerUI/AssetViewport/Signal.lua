-- I did not include debug traceback to make it as light-weight as possible
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

-- Constructor
function Signal.new()
	return setmetatable({
		_bindable = Instance.new("BindableEvent"),
		
		_args = nil,
		_argCount = nil, -- To stay true to _args, even when some indexes are nil
		
	},Signal)
end

function Signal:Fire(...)
	-- I use this method of arguments because when passing it in a bindable event, it creates a deep copy which makes it slower
	self._args = {...}
	self._argCount = select("#", ...)
	
	self._bindable:Fire()
end

function Signal:fire(...)
	return self:Fire(...)
end

function Signal:Connect(handler)
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end
	
	return self._bindable.Event:Connect(function()
		handler(unpack(self._args,1,self._argCount))
	end)
end

function Signal:connect(...)
	return self:Connect(...)
end

function Signal:Wait()
	self._bindableEvent.Event:Wait()
	assert(self._argData, "Missing argument data, likely due to :TweenSize/Position corrupting.")
	return unpack(self._args, 1, self._argCount)
end

function Signal:wait()
	return self:Wait()
end

function Signal:Destroy()
	if self._bindable then
		self._bindable:Destroy()
		self._bindable = nil
	end

	self._args = nil
	self._argCount = nil

	setmetatable(self, nil)
end

function Signal:destroy()
	return self:Destroy()
end

return Signal