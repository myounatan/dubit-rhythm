--[[
    Game Enums
    Matthew Younatan
    2021-07-24

    Holds Enums that are shared between client and server
]]

local GameEnum = {}

local wfc = game.WaitForChild
local enum = require(wfc(game:GetService("ReplicatedStorage"), 'Aero').Shared.Enum)

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

GameEnum.NoteQualityTextColor = {
    [GameEnum.NoteQualityType.MISSED] = Color3.fromRGB(255, 0, 0),
    [GameEnum.NoteQualityType.GOOD] = Color3.fromRGB(255, 255, 215),
    [GameEnum.NoteQualityType.GREAT] = Color3.fromRGB(170, 255, 255),
    [GameEnum.NoteQualityType.PERFECT] = Color3.fromRGB(99, 255, 117)
}

GameEnum.NoteQualityTextStrokeColor = {
    [GameEnum.NoteQualityType.MISSED] = Color3.fromRGB(0, 0, 0),
    [GameEnum.NoteQualityType.GOOD] = Color3.fromRGB(130, 134, 93),
    [GameEnum.NoteQualityType.GREAT] = Color3.fromRGB(44, 68, 134),
    [GameEnum.NoteQualityType.PERFECT] = Color3.fromRGB(55, 143, 28)
}


return GameEnum