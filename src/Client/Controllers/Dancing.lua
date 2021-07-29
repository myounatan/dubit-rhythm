--[[
    Dancing Controller
    Matthew Younatan
    2021-07-27

    Animates the player to dance based on player state, location and note feedback
]]
local Dancing = {}

-- imports
local CharacterController,
    GameStateController,
    RhythmController,
    InteractionPadController,
    GameEnum,
    RhythmScreenController,
    Maid,
    Thread

-- constants
local PAD_TAG = "DanceFloorBounds"

-- variables
local wfc = game.WaitForChild
local random = Random.new()
local localPlayer = game:GetService "Players".LocalPlayer

local animations = game:GetService "ReplicatedStorage".Animations

local function changeHumanoidState(state)
    local char = localPlayer.Character
    if not char then
        return
    end

    local humanoid = wfc(char, "Humanoid")
    if not humanoid then
        return
    end

    humanoid:ChangeState(state)
end

function Dancing:_loadAnimations(char)
    local humanoid = wfc(char, "Humanoid")
    for _, animObj in next, animations:GetChildren() do
        if animObj:IsA "Animation" then
            self._loadedAnims[animObj.Name] = humanoid:LoadAnimation(animObj)
        end
    end
end

function Dancing:_startDancing()
    local anim = self._loadedAnims["dancing"]
    if anim.IsPlaying then
        return
    end

    if self._missed then
        return
    end

    anim:Play()
end

function Dancing:_stopDancing()
    local anim = self._loadedAnims["dancing"]
    if not anim.IsPlaying then
        return
    end

    self._loadedAnims["dancing"]:Stop()
end

function Dancing:Start()
    InteractionPadController:NewPad(
        PAD_TAG,
        function()
            self.OnDanceFloor = true

            RhythmScreenController:Show()

            if not self.IsWalking then
                self:_startDancing()
            end
        end,
        function()
            self.OnDanceFloor = false

            RhythmScreenController:Hide()

            self:_stopDancing()
        end
    )

    CharacterController:ConnectEvent(
        "OnCharacterAdded",
        function(char)
            self:_loadAnimations(char)

            self._maid["onStrafing"] =
                wfc(char, "Humanoid").Running:Connect(
                function(running)
                    self.IsWalking = running > 0

                    if self.IsWalking then
                        self:_stopDancing()
                    else
                        if self.OnDanceFloor then
                            self:_startDancing()
                        end
                    end
                end
            )
        end
    )

    RhythmController:ConnectEvent(
        "OnNoteFeedback",
        function(fretId, noteQualityType)
            -- play a random stumble animation
            if noteQualityType == GameEnum.NoteQualityType.MISSED then
                self._missed = true
                self:_stopDancing()
                changeHumanoidState(Enum.HumanoidStateType.FallingDown)

                Thread.Delay(
                    1,
                    function()
                        changeHumanoidState(Enum.HumanoidStateType.GettingUp)

                        self._missed = false
                        
                        if self.OnDanceFloor and not self.IsWalking then
                            self:_startDancing()
                        end
                    end
                )
            end
        end
    )
end

function Dancing:Init()
    CharacterController = self.Controllers.Character
    GameStateController = self.Controllers.GameState
    RhythmController = self.Controllers.Rhythm
    InteractionPadController = self.Controllers.InteractionPad
    GameEnum = self.Shared.Game.GameEnum

    RhythmScreenController = self.Controllers.Screens.RhythmScreen

    Maid = self.Shared.Maid
    Thread = self.Shared.Thread

    self.OnDanceFloor = false
    self.IsWalking = false

    self._missed = false

    self._loadedAnims = {}

    self._maid = Maid.new()
end

return Dancing
