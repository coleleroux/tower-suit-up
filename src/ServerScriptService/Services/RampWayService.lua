local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)


local RampWayService = Knit.CreateService {
    Name = "RampWayService",
    -- Define some properties:
    _timer = Timer.new(2),
}


function RampWayService:KnitInit()
    
end

function RampWayService:KnitStart()
    
end

return RampWayService