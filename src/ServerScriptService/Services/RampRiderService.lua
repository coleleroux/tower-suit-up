local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)

local RampRider = require(ServerScriptService.Game.Components.RampRider)

local RampRiderService = Knit.CreateService {
    Name = "RampRiderService",
    -- Define some properties:
    _timer = Timer.new(3)
}


function RampRiderService:KnitInit()
    self._timer.Tick:Connect(function()
        print("Spawning in RampRider")
        for i = 1, 6 do
            RampRider.new()
        end
    end)
    self._timer:Start()
end

function RampRiderService:KnitStart()
    
end

return RampRiderService