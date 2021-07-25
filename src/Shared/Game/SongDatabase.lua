--[[
    Song Database
    Matthew Younatan
    2021-07-24

    Holds data on the songs and their hittable notes
]]
local SongDatabase = {}

function SongDatabase:Init()
    self._database = {
        ["fx_almostnever"] = {
            Notes = {
                [""] = {}
            }
        }
    }
end

function SongDatabase:Get(k)
    return self._database[k]
end

function SongDatabase:GetAll()
    return self._database
end

return SongDatabase
