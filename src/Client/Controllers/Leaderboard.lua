--[[
    Leaderboard Controller
    Matthew Younatan
    2021-07-24

    Listens for score changes and emits them as events
]]

local Leaderboard = {}



function Leaderboard:Start()
    
end

function Leaderboard:Init()
    self:RegisterEvent "OnScoreUpdated"
end

return Leaderboard