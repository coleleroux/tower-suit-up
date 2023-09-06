local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local PlayerBlaster = require(ServerScriptService.Game.Components.PlayerBlaster)



local PlayerBlasterService = Knit.CreateService {
    Name = "PlayerBlasterService",
    PlayerSessions = {},
    -- Define some properties:
    Client = {
        EquipEvent = Knit.CreateSignal(),
        FireEvent = Knit.CreateSignal(),
    },
}



function PlayerBlasterService:KnitInit()
    self.Client.EquipEvent:Connect(function(player, gunName)
        local playerBlaster = self.PlayerSessions[player]
        if playerBlaster then
            playerBlaster:Destroy()
        end
        playerBlaster = PlayerBlaster.new(player)
        playerBlaster:NewModel()

        self.PlayerSessions[player] = playerBlaster

        self.Client.EquipEvent:Fire(player, gunName:lower())
	end)


    self.Client.FireEvent:Connect(function(player, args)
        if not self.PlayerSessions[player] then return warn("no player blaster session found for", player) end
        if type(args)~="table" then return warn("invalid arguments for blaster event") end
        

        return self.PlayerSessions[player]:EventFireGun(args)
    end)
end



function PlayerBlasterService:KnitStart()
    
end



function PlayerBlasterService.Client:TestMethod(player, msg)
	print("TestMethod from client:", player, msg)
	return msg:upper()
end



function PlayerBlasterService:OnPlayerAdded()
    Players.PlayerAdded:Connect(function(player:Player)
        local playerBlaster
        -- player.CharacterAdded:Connect(function()
        -- if playerBlaster then
        --     playerBlaster:Destroy()
        -- end
        playerBlaster = PlayerBlaster.new(player)
        playerBlaster:NewModel()
        self.PlayerSessions[player] = playerBlaster
        -- end)
    end)
end



return PlayerBlasterService