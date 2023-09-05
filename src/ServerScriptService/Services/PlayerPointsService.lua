local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local PointsService = Knit.CreateService {
    Name = "PointsService",
    -- Define some properties:
    PointsPerPlayer = {},
    PointsChanged = Signal.new(),
    Client = {
        -- Expose signals to the client:
        PointsChanged = Knit.CreateSignal(),
        GiveMePoints = Knit.CreateSignal(),
        Points = Knit.CreateProperty(0),
    },
}

-- Client exposed GetPoints method:
function PointsService.Client:GetPoints(player)
    return self.Server:GetPoints(player)
end

-- Add Points:
function PointsService:AddPoints(player, amount)
    local points = self:GetPoints(player)
    points += amount
    self.PointsPerPlayer[player] = points
    if amount ~= 0 then
        self.PointsChanged:Fire(player, points)
        self.Client.PointsChanged:Fire(player, points)
    end
    self.Client.Points:SetFor(player, points)
end

-- Get Points:
function PointsService:GetPoints(player)
    local points = self.PointsPerPlayer[player]
    return points or 0
end

-- Initialize
function PointsService:KnitInit()

    local rng = Random.new()
    
    -- Give player random amount of points:
    self.Client.GiveMePoints:Connect(function(player)
        local points = rng:NextInteger(0, 10)
        self:AddPoints(player, points)
        print("Gave " .. player.Name .. " " .. points .. " points")
    end)

    -- Clean up data when player leaves:
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        self.PointsPerPlayer[player] = nil
    end)

end

return PointsService