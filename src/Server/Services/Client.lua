--[[
    Client Service
    Matthew Younatan
    2021-07-24

    Handles registering loaded clients
]]
local Client = {Client = {}}

local Maid, Settings

local players = game:GetService "Players"

function Client:IsPlayerLoaded(player)
    return self._clientsLoaded[player]
end

function Client:GetLoadedClients()
    return self._clientsLoaded
end

function Client:ProcessPlayer(player, f)
    if self:IsPlayerLoaded(player) then
        f(player)
    else
        if not self._playerMaids[player] then
            self._playerMaids[player] = Maid.new()
        end

        local index
        index =
            self._playerMaids[player]:GiveTask(
            self:ConnectEvent(
                "OnClientLoaded",
                function(client)
                    if player == client then
                        f(player)

                        if Settings.Debug then
                            warn("Client Service::", player.Name, "client loaded from queue")
                        end

                        self._playerMaids[player][index] = nil
                    end
                end
            )
        )
    end
end

function Client:Start()
    self._playerMaids = {}

    self:ConnectClientEvent(
        "ClientLoaded",
        function(player)

            if Settings.Debug then
                warn("Client Service::", player.Name, "client loaded")
            end

            if self._clientsLoaded[player] then
                player:Kick("Client can only load once")
            else
                self:Fire("OnClientLoaded", player)

                self._clientsLoaded[player] = true
            end
        end
    )

    players.PlayerRemoving:Connect(
        function(player)
            self._playerMaids[player] = nil
            self._clientsLoaded[player] = nil
        end
    )
end

function Client:Init()
    Maid = self.Shared.Maid
    Settings = self.Shared.Game.Settings

    self._clientsLoaded = {}

    self._maid = Maid.new()

    self:RegisterEvent "OnClientLoaded"

    self:RegisterClientEvent "ClientLoaded"
end

return Client
