--[[
    StateManager
    Matthew Younatan
    2021-07-24

    Simple state manager
]]

local Signal

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new()
	local self = {}

	self._stateList = {}

	return setmetatable(self, StateManager)
end

function StateManager:Register(state, f)
	self._stateList[state] = {Active = false, Function = f, Event = Signal.new()}
end

function StateManager:HasState(state)
	return self._stateList[state] and true or false
end

function StateManager:GetStateSignal(state)
	return self._stateList[state].Event
end

function StateManager:IsStateActive(state)
	return self._stateList[state].Active
end

--[[

calls the defined state function

]]
function StateManager:SetStateActive(state, bool)
	self._stateList[state].Active = bool

	self._stateList[state].Event:Fire(bool)

	if self._stateList[state].Function then
		self._stateList[state].Function(bool)
	end
end

function StateManager:Destroy()
	for _, stateData in next, self._stateList do
		stateData.Event:Destroy()
	end
	self._stateList = nil
end

function StateManager:Init()
	Signal = self.Shared.Utils.Signal
end

return StateManager
