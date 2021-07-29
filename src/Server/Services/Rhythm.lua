--[[
    Rhythm Service
    Matthew Younatan
    2021-07-25

    Handles receiving data on player note hits when songs are playing and
    calculates the accuracy
]]
local Rhythm = {Client = {}}

local Players = game:GetService "Players"
local GameStateService, TimeSyncService, GameEnum, Settings, t, SongDatabase

local noteQualityAccuracy

function Rhythm:_sendNoteFeedback(player, fretId, noteQualityType, estimatedNoteId)
    self:FireClient("SendNoteFeedback", player, fretId, noteQualityType.Value, estimatedNoteId)
end

function Rhythm:Start()
    GameStateService:ConnectEvent(
        "OnStateChanged",
        function(newState, lastTick, songName)
            if newState == GameEnum.GameStateType.NEWSONG then
                self._currentSong = songName
                self._songStartTick = lastTick

                self._playerHitNotes = {}
            else
                self._playerHitNotes = {}
            end
        end
    )

    Players.PlayerRemoving:Connect(
        function(player)
            self._playerHitNotes[player] = nil
        end
    )

    --[[
        hitTime: integer
        fretId: integer (1-3)
    ]]
    local noteHitValidator = t.tuple(t.number, t.integer)
    self:ConnectClientEvent(
        "NoteHit",
        function(player, hitTime, fretId)
            -- there must be a current song playing to process note hits
            local songName = self._currentSong
            if not songName then
                return
            end

            if Settings.Debug then
                warn("NoteHit::", player.Name, hitTime, fretId)
            end

            -- validator must pass
            if not noteHitValidator(hitTime, fretId) then
                if Settings.Debug then
                    warn("Note hit rejected for:", player.Name, "reason:", "Could not validate note hit")
                end
                return
            end

            if fretId < 1 or fretId > 3 then
                if Settings.Debug then
                    warn("Note hit rejected for:", player.Name, "reason:", "Invalid fretId")
                end
                return
            end

            local currentSongTime = hitTime - self._songStartTick

            if hitTime > (self._songStartTick + currentSongTime) then
                if Settings.Debug then
                    warn(
                        "Note hit rejected for:",
                        player.Name,
                        "reason:",
                        "hitTime cannot be greater than current song time (",
                        currentSongTime,
                        ")"
                    )
                end
                return
            end

            local songData = SongDatabase:Get(songName)

            if currentSongTime > songData.Sound.TimeLength then
                if Settings.Debug then
                    warn("Note hit rejected for:", player.Name, "reason:", "Song ended by the time we processed it")
                end
                return
            end

            --[[
                accuracy is calculated as follows:

                player sends the time they hit a fret, we calculate the distance between the hit and
                each note. the smallest distance is the attempted note to hit
            ]]
            local noteDistance = {}

            for noteId, note in next, songData.Notes do
                if note.Fret == fretId then
                    local currentNoteTime = self._songStartTick + note.Time

                    noteDistance[noteId] = math.abs(currentNoteTime - hitTime)
                end
            end

            local noteHitDistance = 999999
            local noteHitId = nil

            for noteId, distance in next, noteDistance do
                if distance < noteHitDistance then
                    noteHitDistance = distance
                    noteHitId = noteId
                end
            end

            if not noteHitId then
                if Settings.Debug then
                    warn("Note hit rejected for:", player.Name, "reason:", "Could not find closest noteId")
                end

                self:_sendNoteFeedback(player, fretId, GameEnum.NoteQualityType.MISSED)

                return
            end

            -- check that we did not already hit the same note twice
            if self._playerHitNotes[player] and self._playerHitNotes[player][noteHitId] then
                if Settings.Debug then
                    warn(
                        "Note hit rejected for:",
                        player.Name,
                        "reason:",
                        "Tried hitting the same note twice (",
                        noteHitId,
                        ")"
                    )
                end

                self:_sendNoteFeedback(player, fretId, GameEnum.NoteQualityType.MISSED)

                return
            end

            local noteHitAccuracy = 0

            print("Closest note:", noteHitId, "distance from hit:", noteHitDistance)

            -- if the distance is less than the required hit accuracy calculate accuracy
            if noteHitDistance < noteQualityAccuracy[1].MaxDistance then
                noteHitAccuracy = noteHitDistance
            end

            if noteHitAccuracy == 0 then -- missed
                self:_sendNoteFeedback(player, fretId, GameEnum.NoteQualityType.MISSED)
            else
                -- calculate quality
                local hitQuality = nil
                for _, data in ipairs(noteQualityAccuracy) do
                    if noteHitAccuracy <= data.MaxDistance then
                        hitQuality = data.Quality
                    end
                end

                self:_sendNoteFeedback(player, fretId, hitQuality, noteHitId)

                self:FireEvent("OnNoteHit", player, fretId, hitQuality, noteHitId)

                if not self._playerHitNotes[player] then
                    self._playerHitNotes[player] = {}
                end
                self._playerHitNotes[player][noteHitId] = true
            end
        end
    )
end

function Rhythm:Init()
    GameStateService = self.Services.GameState
    TimeSyncService = self.Services.TimeSync
    GameEnum = self.Shared.Game.GameEnum
    Settings = self.Shared.Game.Settings
    t = self.Modules.Typecheck

    SongDatabase = self.Shared.Game.SongDatabase

    noteQualityAccuracy = {
        [1] = {Quality = GameEnum.NoteQualityType.GOOD, MaxDistance = 0.2},
        [2] = {Quality = GameEnum.NoteQualityType.GREAT, MaxDistance = 0.1},
        [3] = {Quality = GameEnum.NoteQualityType.PERFECT, MaxDistance = 0.04}
    }

    self.CurrentSong = nil
    self.SongStartTick = nil

    self:RegisterEvent "OnNoteHit"

    self:RegisterClientEvent "NoteHit"
    self:RegisterClientEvent "SendNoteFeedback"
end

return Rhythm
