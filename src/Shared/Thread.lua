-- Thread
-- Stephen Leitnick
-- January 5, 2020

--[[

	Thread.SpawnNow(func, ...)
	Thread.Spawn(func, ...)
	Thread.Delay(waitTime, func, ...)

	SpawnNow(Function func, Arguments...)

		>	Uses a BindableEvent to spawn a new thread
			immediately. More performance-intensive than
			using Thread.Spawn, but will guarantee a
			thread is started immediately.

		>	Use this only if the thread must be executed
			right away, otherwise use Thread.Spawn for
			the sake of performance.

	Spawn(Function func, Arguments...)

		>	Uses RunService's Heartbeat to spawn a new
			thread on the next heartbeat and then
			call the given function.

		>	Better performance than Thread.SpawnNow, but
			will have a short delay of 1 frame before
			calling the function.

	Delay(Number waitTime, Function func, Arguments...)

		>	The same as Thread.Spawn, but waits to call
			the function until the in-game time as elapsed
			by 'waitTime' amount.

		>	Returns the connection to the Heartbeat event,
			so the delay can be cancelled by disconnecting
			the returned connection.

	DelayRepeat(Number intervalTime, Function func, Arguments...)

		>	The same as Thread.Delay, except it repeats
			indefinitely.
		
		>	Returns the Heartbeat connection, thus the
			repeated delay can be stopped by disconnecting
			the returned connection.

		>	Properly bound to the time interval, thus will
			not experience drift.

	
	Examples:

		Thread.Spawn(function()
			print("Hello from Spawn")
		end)

		Thread.Delay(1, function()
			print("Hello from Delay")
		end)

		Thread.SpawnNow(function()
			print("Hello from SpawnNow")
		end)

		local delayConnection = Thread.Delay(5, function()
			print("Hello?")
		end)
		delayConnection:Disconnect()

		local repeatConnection = Thread.DelayRepeat(1, function()
			print("Hello again", tick())
		end)
		wait(5)
		repeatConnection:Disconnect()


	Why:
		
		The built-in 'spawn' and 'delay' functions have the
		potential to be throttled unknowingly. This can cause
		all sorts of problems. Developers need to be certain
		when their code is going to run. This small library
		helps give the same functionality as 'spawn' and 'delay'
		but with the expected behavior.

	Why not coroutines:
		
		Coroutines are powerful, but can be extremely difficult
		to debug due to the ways that coroutines obscure the
		stack trace.

	Credit:
	
		evaera & buildthomas: https://devforum.roblox.com/t/coroutines-v-s-spawn-which-one-should-i-use/368966
		Quenty: FastSpawn (AKA SpawnNow) method using BindableEvent

--]]
local Thread = {}

local heartbeat = game:GetService("RunService").Heartbeat
local wfc = game.WaitForChild
local Queue = require(wfc(game:GetService("ReplicatedStorage"), "Aero").Shared.Queue)

local taskQueue = Queue.new()

heartbeat:Connect(
	function(dt)
		if taskQueue.Count > 0 then
			for _ = 0, taskQueue.Count, 1 do
				local task = taskQueue:PopLeft()
				if task.e and not task.r then
					if tick() - task.t >= task.d then
						task.f(dt)
					end
				end
				if not task.r then
					taskQueue:PushRight(task)
				--else
				--taskQueue.f = nil
				end
			end
		end
	end
)

--[[ Task

data structure for tasks
--]]
local Task = {}
Task.__index = Task

function Task.new(d, f, once)
	local self = {}

	self.s = tick()
	self.e = true
	self.t = tick()
	self.d = d
	self.r = false
	self.f = function(dt)
		self.t = tick() -- reset timer
		f(dt, tick() - self.s)
		if once then
			self.r = true
		end
	end

	self.i = -1 -- index

	return setmetatable(self, Task)
end

--[[function Task:Disable()
	self.e = false
end]]
--[[function Task:Enable()
	self.e = true
end]]
function Task:Destroy()
	self.r = true
end

function Task:Disconnect()
	self.r = true
end

function Thread.SpawnNow(func, ...)
	--[[
		This method was originally written by Quenty and is slightly
		modified for this module. The original source can be found in
		the link below, as well as the MIT license:
			https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Utility/fastSpawn.lua
			https://github.com/Quenty/NevermoreEngine/blob/version2/LICENSE.md
	--]]
	local args = table.pack(...)
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(
		function()
			func(table.unpack(args, 1, args.n))
		end
	)
	bindable:Fire()
	bindable:Destroy()
end

function Thread.Spawn(func, ...)
	local args = table.pack(...)
	local hb
	hb =
		heartbeat:Connect(
		function()
			hb:Disconnect()
			hb = nil

			func(table.unpack(args, 1, args.n))
		end
	)
end

function Thread.Delay(waitTime, func)
	assert(type(waitTime) == "number", "Thread.Delay needs a waitTime thats a number!")
	--[[local args = table.pack(...)
	local executeTime = (tick() + waitTime)
	local hb
	hb =
		heartbeat:Connect(
		function()
			if (tick() >= executeTime) then
				hb:Disconnect()
				func(table.unpack(args, 1, args.n))
			end
		end
	)
	return hb]]
	local task = Task.new(waitTime, func, true)

	taskQueue:PushRight(task)

	return task
end

function Thread.DelayRepeat(intervalTime, func)
	assert(type(intervalTime) == "number", "Thread.DelayRepeat needs an intervalTime thats a number!")
	--[[local args = table.pack(...)
	local nextExecuteTime = (tick() + intervalTime)
	local hb
	hb =
		heartbeat:Connect(
		function()
			if (tick() >= nextExecuteTime) then
				nextExecuteTime = (tick() + intervalTime)
				func(table.unpack(args, 1, args.n))
			end
		end
	)
	return hb]]
	local task = Task.new(intervalTime, func)

	taskQueue:PushRight(task)

	return task
end

return Thread
