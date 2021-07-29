--[[
    Rhythm Controller
    Matthew Younatan
    2021-07-27

    Sends note hits and receives feedback from server
]]
local Rhythm = {}

local tagservice = game:GetService "CollectionService"
local SoundService = game:GetService "SoundService"

local RhythmService, GameEnum, Settings, TimeSyncController, GameStateController, Maid, SongDatabase

local SOUND_PART = tagservice:GetTagged("SoundPart")[1]

function Rhythm:SendNoteHit(fretId)
    if GameStateController:GetState() == GameEnum.GameStateType.INTERMISSION then
        if Settings.Debug then
            warn("Cannot send note hit during intermission")
        end
        return
    end

    RhythmService.NoteHit:Fire(TimeSyncController:GetTime(), fretId)
end

function Rhythm:Start()
    RhythmService.SendNoteFeedback:Connect(
        function(fretId, noteQualityTypeValue, estimatedNoteId)
            local noteQualityType = GameEnum.NoteQualityType[noteQualityTypeValue]

            if Settings.Debug then
                warn("OnNoteFeedback::", fretId, noteQualityType, estimatedNoteId)
            end

            self:FireEvent("OnNoteFeedback", fretId, noteQualityType, estimatedNoteId)
        end
    )

    local onStateChanged = {
        [GameEnum.GameStateType.INTERMISSION] = function(_, _)
            self._maid["song"] = nil
        end,
        [GameEnum.GameStateType.NEWSONG] = function(lastTick, songName)
            local song = SongDatabase:Get(songName).Sound:Clone()

            local lagDifference = TimeSyncController:GetTime() - lastTick

            song.TimePosition = lagDifference
            song.Parent = SOUND_PART
            song:Play()

            if Settings.Debug then
                warn("STARTED PLAYING PHYSICAL SONG")
            end

            self._maid["song"] = song
        end
    }

    -- listen for game state changes to play/stop music
    GameStateController:ConnectEvent(
        "OnStateChanged",
        function(newState, lastTick, ...)
            onStateChanged[newState](lastTick, ...)
        end
    )

    -- preload sounds
    game:GetService "ContentProvider":PreloadAsync(SoundService:GetChildren())
end

function Rhythm:Init()
    RhythmService = self.Services.Rhythm
    GameEnum = self.Shared.Game.GameEnum
    Settings = self.Shared.Game.Settings
    TimeSyncController = self.Controllers.TimeSync
    GameStateController = self.Controllers.GameState
    Maid = self.Shared.Maid
    SongDatabase = self.Shared.Game.SongDatabase

    self._maid = Maid.new()

    self:RegisterEvent "OnNoteFeedback"
end

return Rhythm
