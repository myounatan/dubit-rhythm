--[[
    Leaderboard Service
    Matthew Younatan
    2021-07-24

    Creates a score entry for each new player
]]
local Leaderboard = {Client = {}}

local ffc = game.FindFirstChild

local Players = game:GetService "Players"
local Client

local NAME = "leaderstats"

local function setupPlayer(player)
    local leaderstats = Instance.new "Folder"
    leaderstats.Name = NAME
    leaderstats.Parent = player

    local score = Instance.new "IntValue"
    score.Name = "Score"
    score.Value = 0
    score.Parent = leaderstats
end

-- increment player score by amount
function Leaderboard:IncScore(player, amount)
    local playerStats = ffc(player, NAME)
    if not playerStats then
        return
    end

    local score = ffc(playerStats, "Score")
    if not score then
        return
    end

    score.Value = score.Value + amount
end

function Leaderboard:Start()
    -- setup player when client loads
    Players.PlayerAdded:Connect(
        function(player)
            Client:ProcessPlayer(player, setupPlayer)
        end
    )
end

function Leaderboard:Init()
    Client = self.Services.Client
end

return Leaderboard
