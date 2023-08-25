local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local RampWay = {}
RampWay.__index = RampWay

function RampWay.new()
    local self = setmetatable({}, RampWay)

    return self
end


return RampWay