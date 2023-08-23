local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.Start():andThen(function()
    print("Knit successfully started")
end):catch(warn)
