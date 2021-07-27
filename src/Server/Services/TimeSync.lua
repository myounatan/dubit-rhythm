-- Time Sync Service
-- mat852
-- January 19, 2020

local TimeSyncService = {Client = {}}
TimeSyncService.__aeroOrder = 1

local Thread

local testEvent = "TestEvent"

function TimeSyncService.Client:TestRemoteFunction(player, timeThree)
    return TimeSyncService:_handleDelayRequest(timeThree)
end

--- Returns the sycncronized time
-- @treturn number current time
function TimeSyncService:GetTime()
    return tick()
end

--- Starts the sync process with all slave clocks.
function TimeSyncService:Sync()
    local timeOne = self:GetTime()
    self:FireAllClients(testEvent, timeOne)
end

--- Client sends back message to get the SM_Difference.
-- @return slaveMasterDifference
function TimeSyncService:_handleDelayRequest(timeThree)
    local TimeFour = self:GetTime()
    return TimeFour - timeThree -- -offset + SM Delay
end

function TimeSyncService:Start()
    self:ConnectClientEvent(
        testEvent,
        function(player)
            self:FireClientEvent(testEvent, player, self:GetTime())
        end
    )

    Thread.DelayRepeat(
        5,
        function()
            self:Sync()
        end
    )
end

function TimeSyncService:Init()
    Thread = self.Shared.Thread

    self:RegisterClientEvent(testEvent)
end

return TimeSyncService
