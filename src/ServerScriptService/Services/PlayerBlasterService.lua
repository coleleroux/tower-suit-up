local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local PlayerBlaster = require(ServerScriptService.Game.Components.PlayerBlaster)



local PlayerBlasterService = Knit.CreateService {
    Name = "PlayerBlasterService",
    -- Define some properties:
    Client = {
        EquipEvent = Knit.CreateSignal(),
        FireEvent = Knit.CreateSignal(),
    },
}





function PlayerBlasterService:KnitInit()
    self:OnPlayerAdded()

    self.Client.EquipEvent:Connect(function(player, gunName)
		print("Got message from client event:", player, gunName)
		self.Client.EquipEvent:Fire(player, gunName:lower())
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
        player.CharacterAdded:Connect(function()
            if playerBlaster then
                playerBlaster:Destroy()
            end

            playerBlaster = PlayerBlaster.new(player)
            playerBlaster:NewModel()
        end)
    end)
end



return PlayerBlasterService