-- InputLayout
-- Matthew Younatan
-- February 7, 2020

--[[

manages binding and unbinding when enabled/disabled

--]]
local InputLayout = {}
InputLayout.__index = InputLayout

local contextaction = game:GetService "ContextActionService"

function InputLayout.new(name, isEnabled)
	local self = {}

	self.Name = name
	self.Enabled = isEnabled

	self._actions = {} -- actionName -> actionData

	return setmetatable(self, InputLayout)
end

function InputLayout:BindAction(actionName, func, touchbutton, ...)
	if self._actions[actionName] then
		return
	end

	local actionData = {}
	actionData.Binded = false
	actionData.TouchButton = touchbutton
	actionData.InputTypes = {...}

	actionData.Function = function(name, inputState, inputObj)
		return func(name, inputState, inputObj) or Enum.ContextActionResult.Pass -- pass by default
	end

	self._actions[actionName] = actionData

	if self.Enabled then
		actionData.Binded = true
		contextaction:BindAction(self.Name .. "_" .. actionName, actionData.Function, touchbutton, ...)
	end
end

function InputLayout:BindActionAtPriority(actionName, func, touchbutton, priority, ...)
	if self._actions[actionName] then
		return
	end

	local actionData = {}
	actionData.Binded = false
	actionData.TouchButton = touchbutton
	actionData.InputTypes = {...}

	actionData.Priority = priority

	actionData.Function = function(name, inputState, inputObj)
		return func(name, inputState, inputObj) or Enum.ContextActionResult.Pass -- pass by default
	end

	self._actions[actionName] = actionData

	if self.Enabled then
		actionData.Binded = true
		contextaction:BindActionAtPriority(self.Name .. "_" .. actionName, actionData.Function, touchbutton, priority, ...)
	end
end

function InputLayout:UnbindAction(actionName)
	local actionData = self._actions[actionName]
	if actionData then
		contextaction:UnbindAction(self.Name .. "_" .. actionName)

		self._actions[actionName] = nil
	end
end

function InputLayout:Enable()
	for actionName, actionData in next, self._actions do
		if not actionData.Binded then
			actionData.Binded = true

			if actionData.Priority then
				contextaction:BindActionAtPriority(
					self.Name .. "_" .. actionName,
					actionData.Function,
					actionData.TouchButton,
					actionData.Priority,
					unpack(actionData.InputTypes)
				)
			else
				--[[warn(
					self.Name .. " binding: " .. actionName .. "::",
					actionData.Function,
					actionData.TouchButton,
					actionData.InputTypes
				)]]
				contextaction:BindAction(
					self.Name .. "_" .. actionName,
					actionData.Function,
					actionData.TouchButton,
					unpack(actionData.InputTypes)
				)
			end
		end
	end

	self.Enabled = true
end

function InputLayout:Disable()
	for actionName, actionData in next, self._actions do
		if actionData.Binded then
			actionData.Binded = false
			contextaction:UnbindAction(self.Name .. "_" .. actionName)
		end
	end

	self.Enabled = false
end

function InputLayout:UnbindAll()
	for actionName, actionData in next, self._actions do
		if actionData.Binded then
			actionData.Binded = false
			contextaction:UnbindAction(self.Name .. "_" .. actionName)
		end
	end
	self._actions = {}
end

function InputLayout:Destroy()
	print("Destroyed Input Layout:",self.Name)
	self:UnbindAll()
	self.Enabled = false
	self.Name = nil

	self._actions = {}

	self = nil
end

return InputLayout
