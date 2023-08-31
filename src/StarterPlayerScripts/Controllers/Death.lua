local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerGui = Knit.Player:WaitForChild("PlayerGui")
local spr = require(script.Parent.Parent.Modules.spr)

local gui = PlayerGui:WaitForChild("MainUI")
local blackscreen = gui:WaitForChild("blackscreen")
local wipeout = blackscreen:WaitForChild("wipeout")


local WipeOutMessage = require(script.Parent.Parent.Modules.WipeOutMessages)
local CurrentMessage = 0


local function openDeathMenu()
    spr.stop(blackscreen, "BackgroundTransparency")
    spr.stop(wipeout, "TextTransparency")
    CurrentMessage += 1
    if CurrentMessage > # WipeOutMessage or WipeOutMessage[CurrentMessage]==nil then
        CurrentMessage = 1
    end
    local NewMessage = WipeOutMessage[CurrentMessage]
    if NewMessage then
        wipeout.Text = NewMessage
    end
    spr.target(blackscreen, 0.9, 2, {BackgroundTransparency = 0.75})
    spr.target(wipeout, 0.9, 2, {TextTransparency = 0})
end


local function closeDeathMenu()
    spr.target(blackscreen, 0.9, 2, {BackgroundTransparency = 1})
    spr.target(wipeout, 0.9, 2, {TextTransparency = 1})

end


local function deathUIEvent(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid")
    if not hum then return end
    hum.Died:Connect(function()
        print("died now")
        openDeathMenu()
        task.wait(3)
        closeDeathMenu()
    end)
end

if not Knit.Player.Character then
    Knit.Player.CharacterAdded:Wait()
end

deathUIEvent(Knit.Player.Character)
Knit.Player.CharacterAdded:Connect(deathUIEvent)

return {}