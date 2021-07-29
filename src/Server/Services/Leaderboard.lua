--[[
    Leaderboard Service
    Matthew Younatan
    2021-07-24

    Creates and increments player stats
]]
local Leaderboard = {Client = {}}

local ffc = game.FindFirstChild

local Players = game:GetService "Players"

local Client, RhythmService, GameEnum

local NAME = "leaderstats"

local function setupPlayer(player)
    local leaderstats = Instance.new "Folder"
    leaderstats.Name = NAME
    leaderstats.Parent = player

    local score = Instance.new "IntValue"
    score.Name = "Score"
    score.Value = 0
    score.Parent = leaderstats
    leaderstats.Parent = player

    --[[local streak = Instance.new "IntValue"
    streak.Name = "Streak"
    streak.Value = 0
    streak.Parent = leaderstats

    local highscore = Instance.new "IntValue"
    highscore.Name = "Highscore"
    highscore.Value = 0
    highscore.Parent = leaderstats]]
end

-- increment player score by amount
function Leaderboard:Inc(player, entryName, amount)
    local playerStats = ffc(player, NAME)
    if not playerStats then
        return
    end

    local entry = ffc(playerStats, entryName)
    if not entry then
        return
    end

    entry.Value = entry.Value + amount
end

function Leaderboard:Start()
    -- setup player when client loads
    Players.PlayerAdded:Connect(
        function(player)
            Client:ProcessPlayer(player, setupPlayer)
        end
    )

    -- connect to various services to increment score
    RhythmService:ConnectEvent(
        "OnNoteHit",
        function(player, fretId, hitQuality, noteHitId)
            self:Inc(player, "Score", GameEnum.PlayerScores[hitQuality])
        end
    )
end

function Leaderboard:Init()
    Client = self.Services.Client

    RhythmService = self.Services.Rhythm
    GameEnum = self.Shared.Game.GameEnum
end

return Leaderboard
