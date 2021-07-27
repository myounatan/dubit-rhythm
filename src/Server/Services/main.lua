--[[
    main Service
    Matthew Younatan
    2021-07-25

    Handles game flow logic
]]
local main = {Client = {}}

local Players = game:GetService "Players"
local TimeSyncService, GameStateService, GameEnum, Thread, SongDatabase

-- constants
local SONG = "fx_almostnever"

local INTERMISSION_TIME = 10

--================================
-- MAIN GAME LOGIC
--================================

function main:Start()
    -- state change functions
    local onStateChanged = {
        [GameEnum.GameStateType.INTERMISSION] = function(lastTick, countdown)
            -- play song after some time to cool off
            Thread.Delay(
                countdown,
                function()
                    GameStateService:SetState(GameEnum.GameStateType.NEWSONG, SONG)
                end
            )
        end,
        [GameEnum.GameStateType.NEWSONG] = function(lastTick, songName)
            -- switch to intermission after song ends
            Thread.Delay(
                SongDatabase:Get(songName).Sound.TimeLength, -- length of song
                function()
                    GameStateService:SetState(GameEnum.GameStateType.INTERMISSION, INTERMISSION_TIME)
                end
            )
        end
    }

    -- listen for state changes
    GameStateService:ConnectEvent(
        "OnStateChanged",
        function(newState, lastTick, ...)
            onStateChanged[newState](lastTick, ...)
        end
    )

    -- sync clock with each new player
    Players.PlayerAdded:Connect(
        function(player)
            TimeSyncService:Sync()
        end
    )

    -- start game loop
    Thread.Delay(
        5,
        function()
        end
    )
end

function main:Init()
    TimeSyncService = self.Services.TimeSync
    GameStateService = self.Services.GameState
    GameEnum = self.Shared.Game.GameEnum
    Thread = self.Shared.Thread

    SongDatabase = self.Shared.Game.SongDatabase
end

return main
