local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage.Game.assets

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local RampRider = {}
RampRider.__index = RampRider

RampRider.Tag = "RampRider"

function RampRider.new()
    local self = setmetatable({}, RampRider)
    self._trove = Trove.new()
    self:_Init()
    return self
end

function RampRider:_Init()
    self.Instance = assets.rider:Clone()
    self.Instance.Parent = workspace
end

function RampRider:Destroy()
    self._trove:Destroy()
end

return RampRider