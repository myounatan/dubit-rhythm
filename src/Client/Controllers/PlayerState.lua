--[[
    PlayerState Controller
    Matthew Younatan
    2021-07-24

    Handles sending note hits to server and receiving feedback
]]
local PlayerState = {}

local PlayerStateService, GameEnum

local players = game:GetService "Players"
local localPlayer = players.LocalPlayer

-- returns player state and last tick
function PlayerState:Get(player)
    return self._states[player], self._lastticks[player]
end

function PlayerState:Start()
    -- listen for player state changes
    PlayerStateService.ReplicatePlayerState:Connect(
        function(player, newPlayerStateTypeValue, lastTick, ...)
            local newState = GameEnum.PlayerStateType[newPlayerStateTypeValue]
            local oldState = self._states[player]

            self._states[player] = newState
            self._lastticks[player] = lastTick

            if player == localPlayer then
                self:FireEvent("OnLocalPlayerStateChanged", oldState, newState, lastTick, ...)
            else -- other player
                self:FireEvent("OnOtherPlayerStateChanged", player, oldState, newState, lastTick, ...)
            end
        end
    )

    players.PlayerRemoving:Connect(
        function(player)
            self._states[player] = nil
            self._lastticks[player] = nil
        end
    )
end

function PlayerState:Init()
    PlayerStateService = self.Services.PlayerState
    GameEnum = self.Shared.Game.GameEnum

    self._states = {} -- player -> GameEnum.PlayerState
    self._lastticks = {} -- player -> number

    self:RegisterEvent "OnLocalPlayerStateChanged"
    self:RegisterEvent "OnOtherPlayerStateChanged"
end

return PlayerState
