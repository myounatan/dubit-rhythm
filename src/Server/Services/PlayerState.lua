--[[
    PlayerState Service
    Matthew Younatan
    2021-07-26

    Handles player states
]]
-- Player State Service
-- mat852
-- January 15, 2021

local PlayerState = {Client = {}}

local players = game:GetService "Players"

local ClientService, GameEnum

function PlayerState:_setState(player, newState)
    self._states[player] = newState
    self._lastticks[player] = tick()
end

function PlayerState:SetState(player, newState, ...)
    local oldState = PlayerState:GetState(player)

    self:_setState(player, newState)

    self:Fire("OnPlayerStateChanged", player, oldState, newState, ...)

    self:FireClient("ReplicatePlayerState", player, player, self._states[player].Value, self._lastticks[player], ...)

    for client, _ in next, ClientService:GetLoadedClients() do
        if client ~= player then
            self:FireClient("ReplicatePlayerState", client, player, self._states[player].Value, self._lastticks[player])
        end
    end
end

function PlayerState:GetState(player)
    return self._states[player], self._lastticks[player]
end

function PlayerState:Start()
    players.PlayerAdded:Connect(
        function(player)
            self:_setState(player, GameEnum.PlayerStateType.INIT)
        end
    )

    ClientService:ConnectEvent(
        "OnClientLoaded",
        function(player)
            self:SetState(player, GameEnum.PlayerStateType.MENU)

            -- replicate existing states
            for client, _ in next, ClientService:GetLoadedClients() do
                if client ~= player then
                    local lastState, lastTick = self:GetState(client)
                    self:FireClient("ReplicatePlayerState", player, client, lastState.Value, lastTick)
                end
            end
        end
    )

    players.PlayerRemoving:Connect(
        function(player)
            self._states[player] = nil
            self._lastticks[player] = nil
            self._processingStateRequest[player] = nil
        end
    )
end

function PlayerState:Init()
    ClientService = self.Services.Client
    GameEnum = self.Shared.Game.GameEnum

    self._states = {} -- player -> GameEnum.PlayerState
    self._lastticks = {} -- player -> number

    self._processingStateRequest = {} -- player -> bool

    self:RegisterClientEvent "ReplicatePlayerState"

    self:RegisterEvent "OnPlayerStateChanged"
end

return PlayerState
