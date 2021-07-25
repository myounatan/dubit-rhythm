--[[
    Client Controller
    Matthew Younatan
    2021-07-24

    Sends message to server that client has loaded
]]

local Client = {}

local ClientService

function Client:Start()
    ClientService.ClientLoaded:Fire()
end

function Client:Init()
    ClientService = self.Services.Client
end

return Client