local PageManager = {}

local Input, TableUtil, GuiSettings, Event, Maid

--[[ Page

handles showing/hiding of a page, either a frame or screengui
gets assigned to a controller

]]
local Page = {}

local function newPage(name, frame)
    local self = TableUtil.Assign({}, Page)

    self._maid = Maid.new()

    self._backFunction = function()
        self:Hide()
    end

    --
    self.Name = name

    self.InputLayout = Input:NewLayout(name, false)
    self._maid:GiveTask(self.InputLayout)

    self.Frame = frame
    self._maid:GiveTask(self.Frame)

    self.OnShow = Event.new()
    self._maid:GiveTask(self.OnShow)
    self.OnHide = Event.new()
    self._maid:GiveTask(self.OnHide)

    -- fires only when showing and input is changed
    self.OnInputChanged = Event.new() -- isGamepadConnected
    self._maid:GiveTask(self.OnInputChanged)

    self._maid:GiveTask(
        Input.InputTypeChanged:Connect(
            function()
                if self:IsVisible() then
                    self.OnInputChanged:Fire(Input.IsGamepadConnected)
                end
            end
        )
    )

    --
    self._maid:GiveTask(
        self.OnShow:Connect(
            function()
                self.InputLayout:BindAction(
                    name .. "Back",
                    function(actionName, inputState, inputObj)
                        if inputState == Enum.UserInputState.Begin then
                            self._backFunction()

                            return Enum.ContextActionResult.Sink
                        end
                    end,
                    false,
                    GuiSettings.KeyboardBackBtn,
                    GuiSettings.GamepadBackBtn
                )
            end
        )
    )
    self._maid:GiveTask(
        self.OnHide:Connect(
            function()
                self.InputLayout:UnbindAction(name .. "Back")
            end
        )
    )

    return self
end

function Page:_toggle(bool)
    if self.Frame:IsA "Frame" then
        self.Frame.Visible = bool
    elseif self.Frame:IsA "ScreenGui" then
        self.Frame.Enabled = bool
    end
end

function Page:IsVisible()
    if self.Frame:IsA "Frame" then
        return self.Frame.Visible
    elseif self.Frame:IsA "ScreenGui" then
        return self.Frame.Enabled
    end
end

function Page:Hide()
    self:_toggle(false)

    self.OnHide:Fire()

    self.InputLayout:Disable()
end

function Page:Show(backFuncOverride)
    backFuncOverride = backFuncOverride or function()
        end

    self:_toggle(true)

    self._backFunction = function()
        self:Hide()

        backFuncOverride(self)
    end

    self.OnShow:Fire()

    self.OnInputChanged:Fire(Input.IsGamepadConnected)

    self.InputLayout:Enable()
end

function Page:Destroy()
    self._maid:Destroy()

    PageManager:_removePage(self)
end

-- create and store new page
function PageManager:NewPage(controller, name, frame)
    if self._pages[name] then
        warn("PageManager::", name, "page already exists!")
        return
    end

    -- create page
    local page = newPage(name, frame)

    -- assign to controller
    TableUtil.Assign(controller, page)

    self._pages[name] = page
end

function PageManager:GetPage(name)
    return self._pages[name]
end

function PageManager:_removePage(page)
    self._pages[page.Name] = nil
end

function PageManager:Start()
end

function PageManager:Init()
    Input = self.Controllers.Input
    TableUtil = self.Shared.TableUtil
    GuiSettings = self.Modules.Gui.Settings
    Event = self.Shared.Signal
    Maid = self.Shared.Maid

    self._pages = {} -- name -> page
end

return PageManager
