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
                [4] = {Time = 6.025, Fret = 1},
                [5] = {Time = 6.55, Fret = 1},
                [6] = {Time = 7.1, Fret = 1},
                [7] = {Time = 7.575, Fret = 1},
                [8] = {Time = 8.1, Fret = 1},
                [9] = {Time = 8.625, Fret = 1},
                [10] = {Time = 9.15, Fret = 1},
                [11] = {Time = 9.675, Fret = 1},
                [12] = {Time = 10.2, Fret = 1},
                [13] = {Time = 10.725, Fret = 1},
                [14] = {Time = 11.25, Fret = 1},
                [15] = {Time = 11.75, Fret = 1},
                [16] = {Time = 12.275, Fret = 1},
                [17] = {Time = 12.8, Fret = 1},
                [18] = {Time = 13.325, Fret = 1},
                [19] = {Time = 13.85, Fret = 1},
                [20] = {Time = 14.375, Fret = 1},
                [21] = {Time = 14.9, Fret = 1},
                [22] = {Time = 15.415, Fret = 1},
                [23] = {Time = 15.93, Fret = 1},
                [24] = {Time = 16.45, Fret = 1},
                [25] = {Time = 16.975, Fret = 1},
                [26] = {Time = 17.5, Fret = 1},
                [27] = {Time = 18, Fret = 1},
                [28] = {Time = 18.55, Fret = 1},
                [29] = {Time = 19.05, Fret = 1},
                [30] = {Time = 19.55, Fret = 1},
                [31] = {Time = 20.075, Fret = 1},
                [32] = {Time = 20.625, Fret = 1},
                [33] = {Time = 21.15, Fret = 1},
                [34] = {Time = 21.675, Fret = 1},
                [35] = {Time = 22.175, Fret = 1},
                [36] = {Time = 22.72, Fret = 1},
                [37] = {Time = 23, Fret = 2}, -- 2
                [38] = {Time = 23.24, Fret = 3}, -- 3
                [39] = {Time = 23.75, Fret = 1},
                [40] = {Time = 24.25, Fret = 1},
                [41] = {Time = 24.8, Fret = 1},
                [42] = {Time = 25.05, Fret = 2}, -- 2
                [43] = {Time = 25.325, Fret = 3}, -- 3
                [44] = {Time = 25.825, Fret = 1},
                [45] = {Time = 26.325, Fret = 1},
                [46] = {Time = 26.875, Fret = 1},
                [47] = {Time = 27.4, Fret = 1},
                [48] = {Time = 27.92, Fret = 1},
                [49] = {Time = 28.45, Fret = 1},
                [50] = {Time = 28.97, Fret = 1},
                [51] = {Time = 29.48, Fret = 1},
                [52] = {Time = 30.02, Fret = 1},
                [53] = {Time = 30.525, Fret = 1},
                [54] = {Time = 31.05, Fret = 1},
                [55] = {Time = 31.05, Fret = 1},
                [56] = {Time = 31.31, Fret = 2}, -- 2
                [57] = {Time = 31.575, Fret = 3}, -- 3
                [58] = {Time = 32.1, Fret = 1},
                [59] = {Time = 32.62, Fret = 1},
                [60] = {Time = 33.15, Fret = 1},
                [61] = {Time = 33.4, Fret = 2}, -- 2
                [62] = {Time = 33.65, Fret = 3}, -- 3
                [63] = {Time = 34.175, Fret = 1},
                [64] = {Time = 34.7, Fret = 1},
                [65] = {Time = 35.225, Fret = 1},
                [66] = {Time = 35.775, Fret = 1}
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
