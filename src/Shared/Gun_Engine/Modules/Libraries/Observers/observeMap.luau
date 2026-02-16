--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

export type ObserveMap = {
	__index : ObserveMap,
	new : () -> ObserveMap,
	
	Observers : {
		[string] : {
			() -> ()
		}
	},
	
	Add : (self : ObserveMap,
		Eventname : string,
		callback : () -> ()
	) -> () -> (),
	
	Call : (self : ObserveMap, Eventname : string) -> (),
	Clear : (self : ObserveMap) -> ()
}

local ObserveMap = {} :: ObserveMap
ObserveMap.__index = ObserveMap 

function ObserveMap.new()
	local self = setmetatable({
		Observers = {}
	} :: any, ObserveMap) :: ObserveMap
	return self
end

function ObserveMap:Add(eventName: string, callback: () -> ()): () -> ()
	if not eventName then
		warn("No eventName provided")
		return function() end 
	end


	if not self.Observers[eventName] then
		self.Observers[eventName] = {}
	end

	-- Store the callback
	table.insert(self.Observers[eventName], callback)

	-- Return a cleanup function to remove the callback
	return function()
		local observers = self.Observers[eventName]
		if not observers then return end
		task.spawn(function()
			for i, storedCallback in observers do
				if storedCallback == callback then
					table.remove(observers, i)
					break
				end
			end
			if #observers == 0 then
				self.Observers[eventName] = nil
			end
		end)
	end -- oh my god
end -- keep going

function ObserveMap:Call(Eventname : string)
	if not self.Observers[Eventname] then
		warn("No event named : " .. Eventname)
		return
	end
	local observer = self.Observers[Eventname]
	for _, callback in observer do
		task.spawn(callback)
	end
end

function ObserveMap:CallAll()
	for eventName, callbacks in self.Observers do
		for _, callback in callbacks do
			task.spawn(callback)
		end
	end
end

function ObserveMap:Clear()
	self.Observers = {}
end