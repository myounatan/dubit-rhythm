--[[
    Leaderboard Controller
    Matthew Younatan
    2021-07-24

    Listens for score changes and emits them as events
]]
local Leaderboard = {}

local wfc = game.WaitForChild

local Players = game:GetService "Players"

local Maid

function Leaderboard:Get(player)
    return self._leaderboard[player]
end

function Leaderboard:Start()
    Players.PlayerAdded:Connect(
        function(player)
            self._playerMaids[player] = Maid.new()

            local leaderboard = wfc(player, "leaderboard")

            for _, valObj in next, leaderboard:GetChildren() do
                self._playerMaids[player][valObj.Name] =
                    valObj:GetPropertyChangedSignal(
                    "Value",
                    function(value)
                        self:FireEvent("OnEntryChanged", valObj.Name, value)
                    end
                )
            end

            self._leaderboard[player] = leaderboard
        end
    )

    Players.PlayerRemoving:Connect(
        function(player)
            self._playerMaids[player]:Destroy()
            self._playerMaids[player] = nil

            self._leaderboard[player] = nil
        end
    )
end

function Leaderboard:Init()
    Maid = self.Shared.Maid

    self._playerMaids = {}
    self._leaderboard = {}

    self:RegisterEvent "OnEntryChanged"
end

return Leaderboard
