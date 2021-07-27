-- Time Sync Controller
-- mat852
-- January 19, 2020

local testEvent = "TestEvent"

local TimeSyncController = {}
TimeSyncController.__aeroOrder = 111

local TimeSyncService

function TimeSyncController:GetTime()
    if not self:IsSynced() then
        warn("[SlaveClock][GetTime] - Slave clock is not yet synced")
        return self:_getLocalTime()
    end

    return self:_getLocalTime() - self._offset
end

function TimeSyncController:IsSynced()
    return self._offset ~= -1
end

function TimeSyncController:_getLocalTime()
    return tick()
end

function TimeSyncController:_handleSyncEvent(timeOne)
    local timeTwo = self:_getLocalTime() -- We can't actually get hardware stuff, so we'll send T1 immediately.
    local masterSlaveDifference = timeTwo - timeOne -- We have Offst + MS Delay

    local timeThree = self:_getLocalTime()
    local slaveMasterDifference = self:_sendDelayRequest(timeThree)

    --[[ From explination link.
        The result is that we have the following two equations:
        MS_difference = offset + MS delay
        SM_difference = ?offset + SM delay
        With two measured quantities:
        MS_difference = 90 minutes
        SM_difference = ?20 minutes
        And three unknowns:
        offset , MS delay, and SM delay
        Rearrange the equations according to the tutorial.
        -- Assuming this: MS delay = SM delay = one_way_delay
        one_way_delay = (MSDelay + SMDelay) / 2
    ]]
    local offset = (masterSlaveDifference - slaveMasterDifference) / 2
    local oneWayDelay = (masterSlaveDifference + slaveMasterDifference) / 2

    self._offset = offset -- Estimated difference between server/client
    self._pneWayDelay = oneWayDelay -- Estimated time for network events to send. (MSDelay/SMDelay)
end

function TimeSyncController:_sendDelayRequest(timeThree)
    return TimeSyncService:TestRemoteFunction(timeThree)
end

function TimeSyncController:Start()
    TimeSyncService[testEvent]:Connect(
        function(timeOne)
            self:_handleSyncEvent(timeOne)
        end
    )

    TimeSyncService[testEvent]:Fire()
end

function TimeSyncController:Init()
    TimeSyncService = self.Services.TimeSync

    self._offset = -1 -- Set uncalculated values to -1
end

return TimeSyncController
