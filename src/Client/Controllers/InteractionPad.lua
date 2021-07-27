local InteractionPad = {}

local tagservice = game:GetService "CollectionService"

local Thread

local ffc = game.FindFirstChild
local localPlayer = game:GetService "Players".LocalPlayer

local TAG = "InteractionPad"
local CHAR_RADIUS = Vector3.new(2, 3, 2)

local DEBUG = true

local function GetTagsInRadius(rootPart, str, radius)
    local region =
        Region3.new(rootPart.Position - radius, rootPart.Position + radius)

    local taggedparts = tagservice:GetTagged(str)
    local parts = workspace:FindPartsInRegion3WithWhiteList(region, taggedparts)

    return parts
end

function InteractionPad:NewPad(padTag, enterFunction, leaveFunction)
    if DEBUG then
        warn "REGISTERED PAD"
        warn(padTag)
    end

    local data = {}
    data.Enter = enterFunction or function()
        end
    data.Leave = leaveFunction or function()
        end

    self._pads[padTag] = data
end

function InteractionPad:Start()
    Thread.DelayRepeat(
        .1,
        function()
            local char = localPlayer.Character
            if not char then
                return
            end

            local rootPart = ffc(char, "RootPart")
            if not rootPart then
                return
            end

            local guiPad = GetTagsInRadius(rootPart, TAG, CHAR_RADIUS)

            if #guiPad > 0 and not self.ActivePad then
                if #guiPad > 1 then
                    if DEBUG then
                        warn "Found too many InteractionPad!"
                    end
                end

                guiPad = guiPad[1]

                if DEBUG then
                    print("Found InteractionPad: " .. guiPad.Name)
                end

                self.ActivePad = guiPad

                -- grab and iterate through GUIPad part tags
                local guiPadTags = tagservice:GetTags(guiPad)
                for _, tag in next, guiPadTags do
                    print(tag)
                    -- run associated guipad methods
                    if self._pads[tag] then
                        self._pads[tag].Enter(guiPad)
                    end
                end
            elseif #guiPad == 0 then
                --print "Not near an InteractionPad!"

                if self.ActivePad then
                    local guiPadTags = tagservice:GetTags(self.ActivePad)
                    for _, tag in next, guiPadTags do
                        -- run associated guipad disable methods
                        if self._pads[tag] then
                            self._pads[tag].Leave(guiPad)
                        end
                    end
                end

                self.ActivePad = nil
            end
        end
    )
end

function InteractionPad:Init()
    CharacterController = self.Controllers.Character
    Thread = self.Shared.Thread

    self.ActivePad = nil

    self._pads = {}
end

return InteractionPad
