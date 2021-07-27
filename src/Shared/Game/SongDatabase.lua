--[[
    Song Database
    Matthew Younatan
    2021-07-24

    Holds data on the songs and their hittable notes
]]
local SongDatabase = {}

local ffc = game.FindFirstChild

local SoundService = game:GetService "SoundService"

function SongDatabase:Init()
    self._database = {
        ["almostnever"] = {
            Notes = {
                [1] = {Time = 4.5, Fret = 1},
                [2] = {Time = 5, Fret = 1},
                [3] = {Time = 5.5, Fret = 1},
                [4] = {Time = 6, Fret = 1},
                [5] = {Time = 6.5, Fret = 1},
                [6] = {Time = 7, Fret = 1},
                [7] = {Time = 7.5, Fret = 1},
                [8] = {Time = 8, Fret = 1},
                [9] = {Time = 8.5, Fret = 1},
                [10] = {Time = 9, Fret = 1}
            }
        }
    }

    -- setup sounds as objects
    for songName, data in next, self._database do
        local sound = ffc(SoundService, "song_" .. songName)

        self._database[songName].Sound = sound
    end
end

function SongDatabase:Get(k)
    return self._database[k]
end

function SongDatabase:GetAll()
    return self._database
end

return SongDatabase
