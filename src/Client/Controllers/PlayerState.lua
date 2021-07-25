--[[
    PlayerState Controller
    Matthew Younatan
    2021-07-24

    Handles sending note hits to server and receiving feedback
]]
local PlayerState = {}

local PlayerStateService

function PlayerState:Start()

end

function PlayerState:Init()
    PlayerStateService = self.Services.PlayerState

end

return PlayerState
