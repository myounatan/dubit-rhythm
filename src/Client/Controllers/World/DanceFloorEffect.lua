--[[
    DanceFloorEffect Controller
    Matthew Younatan
    2021-07-24

    Creates a rainbow effect on the dance floor
]]
local DanceFloorEffect = {}

local CollectionService = game:GetService "CollectionService"
local Maid, Thread

local FLOOR_TAG = "DanceFloorTiles"
local GREY = Color3.fromRGB(143, 143, 143)
local RED = Color3.fromRGB(255, 0, 0)
local RANDOM = {
    Color3.fromRGB(255, 119, 65),
    Color3.fromRGB(220, 255, 65),
    Color3.fromRGB(65, 255, 75),
    Color3.fromRGB(65, 255, 246),
    Color3.fromRGB(78, 65, 255),
    Color3.fromRGB(255, 65, 255),
    Color3.fromRGB(255, 65, 113)
}
local NUM_RANDOM = 7

local random = Random.new()

local floorTiles = CollectionService:GetTagged(FLOOR_TAG)[1] -- get first tagged instance

local maid

-- constantly animates random rainbow pattern
local function startRainbow()
    maid:DoCleaning()
    
    for _, tile in next, floorTiles:GetChildren() do
        tile.Material = Enum.Material.Neon
        tile.Color = RANDOM[random:NextInteger(1, NUM_RANDOM)]
    end

    maid:GiveTask(
        Thread.DelayRepeat(
            1,
            function()
                for _, tile in next, floorTiles:GetChildren() do
                    tile.Material = Enum.Material.Neon
                    tile.Color = RANDOM[random:NextInteger(1, NUM_RANDOM)]
                end
            end
        )
    )
end

-- turn tiles red
local function turnRed()
    maid:DoCleaning()

    for _, tile in next, floorTiles:GetChildren() do
        tile.Material = Enum.Material.Neon
        tile.Color = RED
    end
end

-- turn off tiles
local function turnOff()
    maid:DoCleaning()

    for _, tile in next, floorTiles:GetChildren() do
        tile.Material = Enum.Material.SmoothPlastic
        tile.Color = GREY
    end
end


function DanceFloorEffect:Rainbow()
    startRainbow()
end

function DanceFloorEffect:Red()
    turnRed()
end

function DanceFloorEffect:Off()
    turnOff()
end

function DanceFloorEffect:Start()
    maid = Maid.new()

    startRainbow()
end

function DanceFloorEffect:Init()
    Maid = self.Shared.Maid
    Thread = self.Shared.Thread
end

return DanceFloorEffect
