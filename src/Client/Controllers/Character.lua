--[[
    Character Controller
    Matthew Younatan
    2021-07-27

]]
local Character = {}

local localPlayer = game:GetService "Players".LocalPlayer

function Character:Start()
    if localPlayer.Character then
        self:FireEvent("OnCharacterAdded", localPlayer.Character)
    end

    localPlayer.CharacterAdded:Connect(
        function(char)
            self:FireEvent("OnCharacterAdded", char)
        end
    )
end

function Character:Init()
    self:RegisterEvent "OnCharacterAdded"
end

return Character
