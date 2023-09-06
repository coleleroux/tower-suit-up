local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local TeleportController = Knit.CreateController({
	Name = "TeleportController",
})

local Portal = workspace.Portal
local TouchPart = Portal:WaitForChild("TouchPart")
local RampSpawn = workspace:WaitForChild("rampspawn")

local findHumanoid = function(part)
    if part and part.Parent then
        while part ~= workspace and not part:FindFirstChild("Humanoid") do
            part = part.Parent
        end
        return part ~= workspace and part:FindFirstChild("Humanoid")
    end
end


function TeleportController:Teleport()
    if workspace:FindFirstChild("WelcomeBeam") then
        game:GetService("Debris"):AddItem(workspace:FindFirstChild("WelcomeBeam"), 0.5)
    end
    local char = Knit.Player.Character
    if not char then return warn("could not teleport player") end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local hrp = hum.RootPart
    if not hrp then return end
    
    hum.Parent:PivotTo(RampSpawn.CFrame*CFrame.new(0,3,0))
    hum.Parent:MoveTo(hrp.Position)

    SoundService:WaitForChild("interface"):WaitForChild("teleport"):Play()
end


function TeleportController:KnitInit()
    TouchPart.Touched:Connect(function(hit)
        local hum = findHumanoid(hit)
        if hum then
            local char = hum.Parent
            if not char then return end
            local player = game:GetService("Players"):GetPlayerFromCharacter(char)
            if not player or player.UserId~=Knit.Player.UserId then return end

            self:Teleport()
        end
    end)
end



function TeleportController:KnitStart()
    
end


return TeleportController