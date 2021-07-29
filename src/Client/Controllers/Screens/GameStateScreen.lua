local GameStateScreen = {}

local wfc = game.WaitForChild
local playerGui = game:GetService "Players".LocalPlayer:WaitForChild "PlayerGui"

local GameStateController, GameEnum, Maid, TimeSyncController, Thread, SongDatabase

function GameStateScreen:_setText(text)
    self._gameStateLabel.Text = text
end

function GameStateScreen:Start()
    self._gameStateLabel = wfc(wfc(playerGui, "GameStateScreenGui"), "GameStateLabel")

    local onStateChanged = {
        [GameEnum.GameStateType.INTERMISSION] = function(lastTick, countdown)
            local lagDifference = TimeSyncController:GetTime() - lastTick

            countdown = countdown - lagDifference

            if countdown < 0 then
                self:_setText("Intermission: 0")

                return
            end

            self._timer = math.ceil(countdown)
            self._maid:GiveTask(
                Thread.DelayRepeat(
                    1,
                    function()
                        self:_setText("Intermission: " .. self._timer)
                        self._timer = self._timer - 1
                    end
                )
            )
        end,
        [GameEnum.GameStateType.NEWSONG] = function(lastTick, songName)
            local lagDifference = TimeSyncController:GetTime() - lastTick

            local songData = SongDatabase:Get(songName)

            local countdown = songData.Sound.TimeLength - lagDifference

            if countdown < 0 then
                self:_setText("Song Playing: " .. songName .. ",   Time Left: 0")

                return
            end

            self._timer = math.ceil(countdown)
            self._maid:GiveTask(
                Thread.DelayRepeat(
                    1,
                    function()
                        self:_setText("Song Playing: " .. songName .. ",   Time Left: " .. self._timer)
                        self._timer = self._timer - 1
                    end
                )
            )
        end
    }

    GameStateController:ConnectEvent(
        "OnStateChanged",
        function(newState, lastTick, ...)
            self._maid:DoCleaning()

            onStateChanged[newState](lastTick, ...)
        end
    )
end

function GameStateScreen:Init()
    GameStateController = self.Controllers.GameState
    GameEnum = self.Shared.Game.GameEnum
    Maid = self.Shared.Maid
    TimeSyncController = self.Controllers.TimeSync
    Thread = self.Shared.Thread
    SongDatabase = self.Shared.Game.SongDatabase

    self._maid = Maid.new()
    self._timer = 0
end

return GameStateScreen
