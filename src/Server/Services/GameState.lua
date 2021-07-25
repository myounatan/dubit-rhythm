--[[
    GameState Service
    Matthew Younatan
    2021-07-24

    Controls the state of the game
]]
local GameState = {Client = {}}

local ClientService, GameEnum, Settings

function GameState:SetState(newState, ...)
    self._state = newState
    self._lasttick = tick()
    self._lastParams = {...}

    if Settings.Debug then
        warn("Set game state to ", newState, "params:", ...)
    end

    self:Fire("OnStateChanged", self._state, self._lasttick, ...)

    self:FireAllClientsEvent("ReplicateGameState", self._state.Value, self._lasttick, ...)
end

function GameState:GetState()
    return self._state
end

function GameState:Start()
    -- replicate current game state when client loads
    ClientService:ConnectEvent(
        "OnClientLoaded",
        function(player)
            self:FireClient(
                "ReplicateGameState",
                player,
                self._state.Value,
                self._lasttick,
                unpack(self._lastParams)
            )
        end
    )
end

function GameState:Init()
    ClientService = self.Services.Client
    GameEnum = self.Shared.Game.GameEnum
    Settings = self.Shared.Game.Settings

    self._lastParams = {}

    self._state = GameEnum.GameStateType.INTERMISSION

    self:RegisterClientEvent "ReplicateGameState"

    self:RegisterEvent "OnStateChanged"
end

return GameState
