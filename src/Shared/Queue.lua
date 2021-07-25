--[[    Queue
        mat852
        January 18, 2020

    
    doubly linked queue
]]
local DoubleQueue = {}
DoubleQueue.__index = DoubleQueue

-- acts as a queue for reward popups

function DoubleQueue.new()
	local self = {}

	self.First = 0
	self.Last = -1

	self.Count = 0

	self.List = {}

	return setmetatable(self, DoubleQueue)
end

function DoubleQueue:Clear()
	self.First = 0
	self.Last = -1

	self.Count = 0
	
	self.List = {}
end

function DoubleQueue:PushLeft(value)
	local first = self.First - 1
	self.First = first
	self.List[first] = value

	self.Count = self.Count + 1
end

function DoubleQueue:PushRight(value)
	local last = self.Last + 1
	self.Last = last
	self.List[last] = value

	self.Count = self.Count + 1
end

function DoubleQueue:PopLeft()
	local first = self.First

	if first > self.Last then
		warn("list is empty")
		return
	end

	local value = self.List[first]
	self.List[first] = nil -- to allow garbage collection
	self.First = first + 1

	self.Count = self.Count - 1

	return value
end

function DoubleQueue:PopRight()
	local last = self.Last

	if self.First > last then
		warn("list is empty")
		return
	end

	local value = self.List[last]
	self.List[last] = nil -- to allow garbage collection
	self.Last = last - 1

	self.Count = self.Count - 1

	return value
end

function DoubleQueue:Destroy()
	self.List = nil

	self.First = nil
	self.Last = nil

	self = nil
end

return DoubleQueue
