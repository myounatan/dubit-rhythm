-- Input Controller
-- Matthew Younatan
-- February 7, 2020

--[[

interface to UserInputService

]]
local InputController = {}
InputController.__aeroOrder = 1

local inputservice = game:GetService "UserInputService"

local InputLayout, Event

local IS_CONSOLE = game:GetService "GuiService":IsTenFootInterface()

--local MOUSE_INPUTS

local KEYBOARD_DETECTION = {
    [Enum.UserInputType.MouseWheel] = true,
    [Enum.UserInputType.MouseButton1] = true,
    [Enum.UserInputType.MouseButton2] = true,
    [Enum.UserInputType.MouseButton3] = true,
    [Enum.UserInputType.MouseMovement] = true,
    [Enum.UserInputType.Keyboard] = true
}

--[[function InputController:GetIcon(keycode)
    local keycodeenum
    if type(keycode) == "string" then
        keycodeenum = MOUSE_INPUTS(keycode) and Enum.UserInputType[keycode] or Enum.KeyCode[keycode]
    else
        keycodeenum = keycode
    end
    return InputIcons:Get(keycodeenum)
end]]
function InputController:NewLayout(layoutName, enabled)
    self._layouts[layoutName] = InputLayout.new(layoutName, enabled)

    return self._layouts[layoutName]
end

function InputController:IsDown(keycode)
    return self._keysdown[keycode]
end

function InputController:KeyboardEnabled()
    return inputservice.KeyboardEnabled
end

function InputController:GamepadEnabled()
    return inputservice.GamepadEnabled
end

function InputController:GetLastInputType()
    return inputservice:GetLastInputType()
end

function InputController:GetGamepads()
    return inputservice:GetConnectedGamepads()
end

function InputController:IsKeyDown(key)
    return inputservice:IsKeyDown(key)
end

function InputController:ShowMouseCursor()
    self._mouseIconEnabled = true
    inputservice.MouseIconEnabled = true
end

function InputController:HideMouseCursor()
    self._mouseIconEnabled = false
    inputservice.MouseIconEnabled = false
end

function InputController:Start()
    -- events
    inputservice.InputBegan:connect(
        function(inputobject)
            if self._typing then
                return
            end

            local keycode = inputobject.KeyCode
            if keycode ~= Enum.KeyCode.Unknown then
                self._keysdown[keycode] = true
            end
        end
    )

    inputservice.InputEnded:connect(
        function(inputobject)
            if self._typing then
                return
            end

            local keycode = inputobject.KeyCode
            if keycode ~= Enum.KeyCode.Unknown then
                self._keysdown[keycode] = false
            end
        end
    )

    inputservice.TextBoxFocused:connect(
        function(textbox)
            self._typing = true
            for _, keycode in next, self._keys do
                self._keysdown[keycode] = false
            end
        end
    )

    inputservice.TextBoxFocusReleased:connect(
        function(textbox)
            self._typing = false
        end
    )

    local prev = false

    local function ConnectGamepad(gamepadNum)
        prev = self.IsGamepadConnected -- prev

        inputservice.MouseIconEnabled = false
        self.IsGamepadConnected = true
        self.Gamepad = gamepadNum

        inputservice:SetNavigationGamepad(gamepadNum, true)

        if prev ~= self.IsGamepadConnected then -- if there was a considerable change in input type, notify script
            self.OnGamepadConnected:Fire(gamepadNum)
        end
    end

    local function DisconnectGamepad()
        prev = self.IsGamepadConnected -- prev

        if self.Gamepad ~= Enum.UserInputType.None then
            inputservice:SetNavigationGamepad(self.Gamepad, false)
        end

        inputservice.MouseIconEnabled = self._mouseIconEnabled
        self.IsGamepadConnected = false
        self.Gamepad = Enum.UserInputType.None

        if prev ~= self.IsGamepadConnected then -- if there was a considerable change in input type, notify script
            self.OnGamepadDisconnected:Fire()
        end
    end

    local function InputTypeChanged(lastInputType)
        --print('lastinput type:', lastInputType)
        prev = self.IsGamepadConnected -- prev

        if lastInputType == Enum.UserInputType.Gamepad1 then
            ConnectGamepad(Enum.UserInputType.Gamepad1)
        elseif KEYBOARD_DETECTION[lastInputType] then
            DisconnectGamepad()
        end

        if prev ~= self.IsGamepadConnected --[[ or FIRST_RUN]] then -- if there was a considerable change in input type, notify script
            print "FIRED INPUT TYPE CHANGED"
            self.InputTypeChanged:Fire(lastInputType)
        end
    end

    -- handle gamepad connection
    inputservice.LastInputTypeChanged:Connect(InputTypeChanged)
    inputservice.GamepadConnected:Connect(ConnectGamepad)
    inputservice.GamepadDisconnected:Connect(DisconnectGamepad)

    -- check on start
    local gamepads = self:GetGamepads()
    if #gamepads > 0 and self:GetLastInputType() == Enum.UserInputType.Gamepad1 then
        print "gamepad enabled"
        ConnectGamepad(gamepads[1])
    --else
    --if IS_CONSOLE then
    --end
    end
end

function InputController:Init()
    InputLayout = self.Modules.InputLayout
    Event = self.Shared.Signal

    -- public
    self.IsGamepadConnected = false
    self.Gamepad = Enum.UserInputType.None

    self.InputTypeChanged = Event.new()

    self.OnGamepadConnected = Event.new()
    self.OnGamepadDisconnected = Event.new()

    --MOUSE_INPUTS = self.Shared.Core.Collections.LIST {"MouseButton1", "MouseButton2", "MouseButton3", "MouseWheel"}

    -- private
    self._mouseIconEnabled = true

    self._layouts = {}

    self._keys = {}
    self._keysdown = {}
    for _, enum in next, {Enum.KeyCode, Enum.UserInputType} do
        for _, item in pairs(enum:GetEnumItems()) do
            self._keys[item.Name] = item
            self._keysdown[item] = false
        end
    end

    self._typing = false
end

return InputController
