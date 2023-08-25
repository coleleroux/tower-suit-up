local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local assets = ReplicatedStorage.Game.assets

local ramp = workspace.ramp

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local RampRider = {}
RampRider.__index = RampRider

local FULL_PI = math.pi
local TWO_PI = FULL_PI * 2
RampRider._RotateFactor = FULL_PI*.25
RampRider._Seed = Random.new()

RampRider.Tag = "RampRider"

function RampRider.new()
    local self = setmetatable({}, RampRider)
    self._trove = Trove.new()
    self:_Init()
    return self
end


function RampRider:HarmPlayer(hit: Part)
    if not hit or not hit.Parent then return end

    local char = hit.Parent
    if not char:FindFirstChild("Humanoid") then return end
    local hum = char.Humanoid
    local root = char:FindFirstChild("HumanoidRootPart")
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end

    hum.Health = 0

    return self:Destroy()

end



function RampRider:GetPosition()
    local topRight = ramp:FindFirstChild("top-right")
    local topLeft = ramp:FindFirstChild("top-left")
    local topMiddle = ramp:FindFirstChild("top-middle")

    local x = math.random(topRight.Position.X, topLeft.Position.X)
    local y = assets.rider.Position.Y
    local z = assets.rider.Position.Z

    return Vector3.new(x,y,z)
end



function RampRider:BuildPhysics()
    local endMiddle = ramp:FindFirstChild("end-middle")
    if not self.Instance then return end
    local physics = assets.physics:Clone()

    for index, value in pairs(physics:GetChildren()) do
        if value:IsA("BodyGyro") or value:IsA("BodyPosition") then
            value.Parent = self.Instance
        end
    end

    local gyro = self.Instance:WaitForChild("BodyGyro")
    local bodypos = self.Instance:WaitForChild("BodyPosition")
    bodypos.Position = Vector3.new(endMiddle.Position.X,self.Instance.Position.Y,self.Instance.Position.Z)
    bodypos.MaxForce = Vector3.new(math.random(math.random(5,25),25), math.random(50,100), 0, self._Seed:NextNumber(-5,5))

    self.Instance.CanCollide = true
    self.Instance.CanTouch = true
    self.Instance.Anchored = false
    self.Instance.AssemblyLinearVelocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))
    self.Instance.AssemblyAngularVelocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))


    self._trove:Connect(game:GetService("RunService").Stepped, function()
        -- print(
        --     "trying to update physics"
        -- )
        local sign = math.sign(self.Instance.Velocity.Y) -- direction (-1 || 1 || 0)
        local axisSpin = math.rad(self.Instance.Position.Y) * sign * self._RotateFactor
        gyro.CFrame = CFrame.Angles(0,0,axisSpin) -- specifying our angle axis's
    end)

    game:GetService("Debris"):AddItem(physics, 0)

end



function RampRider:_Init()
    local RiderPos = self:GetPosition()
    self.Instance = assets.rider:Clone()
    self.Instance.Position = RiderPos
    self.Instance.Parent = workspace

    self._trove:Add(self.Instance)
    self:BuildPhysics()

    self._trove:Connect(self.Instance.Touched, function(hit)
        return self:HarmPlayer(hit)
    end)
end



function RampRider:Destroy()
    self._trove:Destroy()
end



return RampRider