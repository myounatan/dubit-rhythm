--[[
    GameState Service
    Matthew Younatan
    2021-07-24

    Controls the state of the game
]]
local GameState = {Client = {}}

local Players = game:GetService "Players"
local ClientService, GameEnum, Settings

function GameState:SetState(newState, ...)
    self._state = newState
    self._lasttick = tick()
    self._lastParams = {...}

    if Settings.Debug then
        warn("Set game state to ", newState, "params:", ...)
    end

    self:Fire("OnStateChanged", self._state, self._lasttick, ...)

    self:FireAllClients("ReplicateGameState", self._state.Value, self._lasttick, ...)
end

function GameState:GetState()
    return self._state
end

function GameState:GetLastTick()
    return self._lasttick
end

function GameState:Start()
    -- replicate current game state when client loads
    ClientService:ConnectEvent(
        "OnClientLoaded",
        function(player)
            if Settings.Debug then
                warn "Replicating game state on join"
            end

            if not self._state then
                return
            end

            self:FireClient("ReplicateGameState", player, self._state.Value, self._lasttick, unpack(self._lastParams))
        end
    )
end

function GameState:Init()
    ClientService = self.Services.Client
    GameEnum = self.Shared.Game.GameEnum
    Settings = self.Shared.Game.Settings

    self._lastParams = {}
    self._lasttick = 0
    self._state = nil

    self:RegisterClientEvent "ReplicateGameState"

    self:RegisterEvent "OnStateChanged"
end

return GameState
