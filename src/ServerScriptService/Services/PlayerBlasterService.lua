local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local PlayerBlaster = require(ServerScriptService.Game.Components.PlayerBlaster)

local PlayerBlasterService = Knit.CreateService {
    Name = "BlasterService",
    -- Define some properties:
}


function PlayerBlasterService:KnitInit()
    Players.PlayerAdded:Connect(function(player:Player)
        local playerBlaster
        player.CharacterAdded:Connect(function()
            if playerBlaster then
                playerBlaster:Destroy()
            end

            playerBlaster = PlayerBlaster.new(player)
            playerBlaster:NewModel()
        end)
    end)
end

function PlayerBlasterService:KnitStart()
    
end

return PlayerBlasterService