--[[
    Game Enums
    Matthew Younatan
    2021-07-24

    Holds Enums that are shared between client and server
]]

local GameEnum = {}

local wfc = game.WaitForChild
local enum = require(wfc(game:GetService("ReplicatedStorage"), 'Aero').Shared.Enum)

-- player states
GameEnum.PlayerStateType = enum("PlayerStateType", {
    "NOTDANCING",
    "DANCING"
})

-- game states
GameEnum.GameStateType = enum("GameStateType", {
    "INTERMISSION",
    "NEWSONG"
})

-- types of note quality hits
GameEnum.NoteQualityType = enum("NoteQualityType", {
    "MISSED",
    "GOOD",
    "GREAT",
    "PERFECT"
})

GameEnum.PlayerScores = {
    [GameEnum.NoteQualityType.GOOD] = 5,
    [GameEnum.NoteQualityType.GREAT] = 10,
    [GameEnum.NoteQualityType.PERFECT] = 50,
}


return GameEnum