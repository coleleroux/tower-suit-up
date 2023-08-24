local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Load all services:
for _, v in script.Parent.Services:GetDescendants() do
    if v:IsA("ModuleScript") then
        require(v)
    end
end

Knit.Start():catch(warn)