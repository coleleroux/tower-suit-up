local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)

local spr = require(script.Parent.Parent.Modules.spr)


local RampWayService = Knit.CreateService {
    Name = "RampWayService",
    -- Define some properties:
    _timer = Timer.new(2),
}


local findHumanoid = function(part)
    if part and part.Parent then
        while part ~= workspace and not part:FindFirstChild("Humanoid") do
            part = part.Parent
        end
        return part ~= workspace and part:FindFirstChild("Humanoid")
    end
end


function RampWayService:MakeCogsHurt()
    workspace.rampspawn.Touched:Connect(function(hitPart)
        if hitPart:IsA("BasePart") and hitPart:IsDescendantOf(workspace.Balls) then
            if hitPart:GetAttribute("IsDestroying") then
                return
            end
            task.wait(0.5)
            spr.target(hitPart, 1, 10, {Size = Vector3.new(0,0,0)})
            spr.completed(hitPart, function()
                game:GetService("Debris"):AddItem(hitPart, 0)
            end)

            hitPart:SetAttribute("IsDestroying", true)
            SoundService.world.fireball:Play()
        end
        
    end)

    for i,v in pairs(workspace.grinder:GetDescendants()) do
        if not v:IsA("BasePart") then
            continue
        end

        v.Touched:Connect(function(hitPart)
            local humanoid = findHumanoid(hitPart)
            if humanoid then
                humanoid.Health = 0
            elseif hitPart:IsA("BasePart") and hitPart:IsDescendantOf(workspace.Balls) then
                if hitPart:GetAttribute("IsDestroying") then
                    return
                end
                spr.target(hitPart, 1, 10, {Size = Vector3.new(0,0,0)})
                spr.completed(hitPart, function()
                    game:GetService("Debris"):AddItem(hitPart, 0)
                end)
    
                hitPart:SetAttribute("IsDestroying", true)
                SoundService.world.fireball:Play()
            end
        end)
    end
end

function RampWayService:KnitInit()
    
end

function RampWayService:KnitStart()
    self:MakeCogsHurt()
end

return RampWayService