local RhythmScreen = {}

local wfc = game.WaitForChild
local playerGui = game:GetService "Players".LocalPlayer:WaitForChild "PlayerGui"
local guiObjects = game:GetService "ReplicatedStorage":WaitForChild "GuiObjects"
local userInput = game:GetService "UserInputService"

local RunService = game:GetService "RunService"

local PageManager,
    RhythmController,
    TimeSyncController,
    InputController,
    Thread,
    Maid,
    GameEnum,
    Tween,
    GameStateController,
    SongDatabase

local WHITE = Color3.fromRGB(255, 255, 255)

local NOTE_TRACK_SCALE = userInput.TouchEnabled and 20000 or 40000

local BACK_PADDING = 2 -- seconds

local fretColors

-- bind keyboard numbers 1-3 to fret inputs
local fretMap = {
    [Enum.KeyCode.One] = 1,
    [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3
}

local notePositions = {
    [1] = UDim2.new(0, 0, 0, 0),
    [2] = UDim2.new(0.5, 0, 0, 0),
    [3] = UDim2.new(1, 0, 0, 0)
}

function RhythmScreen:_hitFretEffect(fretFrame)
    fretFrame.BackgroundColor3 = WHITE

    self._effectMaid:GiveTask(
        Thread.Delay(
            0.05,
            function()
                fretFrame.BackgroundColor3 = fretColors[tonumber(fretFrame.Name)]
            end
        )
    )
end

function RhythmScreen:_hitFret(fretId)
    local fretFrame = self.Frame.InputNotes.Inputs[fretId .. ""]

    self:_hitFretEffect(fretFrame)

    RhythmController:SendNoteHit(fretId)
end

function RhythmScreen:_noteFeedback(fretId, noteQualityType, optionalNoteId)
    local fretFrame = self.Frame.InputNotes.NoteQuality[fretId .. ""]

    if optionalNoteId then
        self.Frame.InputNotes.Notes["Note" .. optionalNoteId].BackgroundTransparency = 1
    end

    local feedbackObj = guiObjects.NoteQualityType[noteQualityType.Name]:Clone()
    if noteQualityType.Value > 1 then
        feedbackObj.Text = feedbackObj.Text .. " +" .. GameEnum.PlayerScores[noteQualityType]
    end
    feedbackObj.Parent = fretFrame

    local tween =
        Tween.new(
        TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0),
        function(n)
            feedbackObj.TextTransparency = n
            feedbackObj.TextStrokeTransparency = n
            feedbackObj.Position = UDim2.new(0.5, 0, 1 + (2 * n), 0)
        end
    )

    local conn
    conn =
        tween.Completed:Connect(
        function()
            conn:Disconnect()
            conn = nil

            tween = nil

            feedbackObj:Destroy()
            feedbackObj = nil
        end
    )

    tween:Play()
end

function RhythmScreen:Start()
    PageManager:NewPage(self, "RhythmScreenGui", wfc(playerGui, "RhythmScreenGui"))

    self.OnShow:Connect(
        function()
        end
    )
    self.OnHide:Connect(
        function()
        end
    )

    self.InputLayout:BindAction(
        "HitFret",
        function(actionName, inputState, inputObj)
            if inputState == Enum.UserInputState.Begin then
                local fretId = fretMap[inputObj.KeyCode]

                self:_hitFret(fretId)
            end
        end,
        false,
        Enum.KeyCode.One,
        Enum.KeyCode.Two,
        Enum.KeyCode.Three
    )

    local touchEnabled = userInput.TouchEnabled

    -- connect finger taps on frets
    for _, inputFrame in next, self.Frame.InputNotes.Inputs:GetChildren() do
        inputFrame.Button.TouchTap:Connect(
            function()
                local fretId = tonumber(inputFrame.Name)

                self:_hitFret(fretId)
            end
        )

        -- show/hide keyboard input
        inputFrame.KeyboardInput.Visible = not touchEnabled
    end

    -- note feedback animation
    RhythmController:ConnectEvent(
        "OnNoteFeedback",
        function(fretId, noteQualityType, estimatedNoteId)
            self:_noteFeedback(fretId, noteQualityType, estimatedNoteId)
        end
    )

    -- animate notes
    local onStateChanged = {
        [GameEnum.GameStateType.INTERMISSION] = function(_, _)
            self._noteMaid:DoCleaning()
        end,
        [GameEnum.GameStateType.NEWSONG] = function(lastTick, songName)
            local songData = SongDatabase:Get(songName)

            local currentTick = TimeSyncController:GetTime()

            local timeSinceSongStart = currentTick - lastTick

            for noteId, noteData in ipairs(songData.Notes) do
                local noteFrame = guiObjects.Frets[noteData.Fret]:Clone()
                noteFrame.Parent = self.Frame.InputNotes.Notes
                noteFrame.Name = "Note" .. noteId

                local ratioFromNote = (noteData.Time - timeSinceSongStart) / songData.Sound.TimeLength
                print("Note" .. noteId .. ", distance from 0: " .. (ratioFromNote * NOTE_TRACK_SCALE))

                self._noteMaid["Note" .. noteId] = noteFrame
            end

            self._noteMaid:GiveTask(
                RunService.Heartbeat:Connect(
                    function()
                        --[[local ]] currentTick = TimeSyncController:GetTime()

                        --[[local ]] timeSinceSongStart = currentTick - lastTick

                        for noteId, noteData in ipairs(songData.Notes) do
                            local noteFrame = self._noteMaid["Note" .. noteId]
                            if noteFrame then
                                local noteTick = lastTick + noteData.Time

                                -- add back padding to check so the notes don't just disappear when they hit the target, and lets
                                -- them go through backwards for a bit
                                if noteTick + BACK_PADDING < currentTick then
                                    self._noteMaid["Note" .. noteId]:Destroy()
                                    self._noteMaid["Note" .. noteId] = nil
                                else
                                    local ratioFromNote =
                                        (noteData.Time - timeSinceSongStart) / songData.Sound.TimeLength

                                    noteFrame.Position =
                                        notePositions[noteData.Fret] +
                                        UDim2.new(0, 0, 0, NOTE_TRACK_SCALE * ratioFromNote)
                                end
                            end
                        end
                    end
                )
            )
        end
    }

    GameStateController:ConnectEvent(
        "OnStateChanged",
        function(newState, lastTick, ...)
            onStateChanged[newState](lastTick, ...)
        end
    )

    -- auto hide
    self:Hide()
end

function RhythmScreen:Init()
    PageManager = self.Modules.Gui.PageManager
    RhythmController = self.Controllers.Rhythm
    InputController = self.Controllers.Input
    Thread = self.Shared.Thread
    Maid = self.Shared.Maid
    GameEnum = self.Shared.Game.GameEnum
    Tween = self.Modules.Tween
    GameStateController = self.Controllers.GameState
    TimeSyncController = self.Controllers.TimeSync
    SongDatabase = self.Shared.Game.SongDatabase

    self._effectMaid = Maid.new()
    self._songMaid = Maid.new()

    self._tweenMaid = Maid.new()

    self._noteMaid = Maid.new()

    fretColors = {
        [1] = Color3.fromRGB(255, 75, 75),
        [2] = Color3.fromRGB(75, 255, 75),
        [3] = Color3.fromRGB(75, 75, 255)
    }
end

return RhythmScreen
