local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerGui = Knit.Player:WaitForChild("PlayerGui")
local spr = require(script.Parent.Parent.Modules.spr)



local DeathController = Knit.CreateController({
	Name = "DeathController",
})



local gui = PlayerGui:WaitForChild("MainUI")
local blackscreen = gui:WaitForChild("blackscreen")
local wipeout = blackscreen:WaitForChild("wipeout")


local WipeOutMessage = require(script.Parent.Parent.Modules.WipeOutMessages)
local CurrentMessage = 0


function DeathController:OpenMenu()
    self.CameraController:ChangeBackClassic()
    SoundService:WaitForChild("interface"):WaitForChild("death"):Play()

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
    spr.target(blackscreen, 0.9, 2, {BackgroundTransparency = 0.45})
    spr.target(wipeout, 0.9, 2, {TextTransparency = 0})
end


function DeathController:CloseMenu()
    spr.target(blackscreen, 0.9, 2, {BackgroundTransparency = 1})
    spr.target(wipeout, 0.9, 2, {TextTransparency = 1})

    self.CameraController:ChangeFirstPerson()

end


function DeathController:setup()
    if not Knit.Player.Character then return end
    local hum = Knit.Player.Character:WaitForChild("Humanoid")
    if not hum then return end
    hum.Died:Connect(function()
        self:OpenMenu()
        task.wait(3)
        self:CloseMenu()
    end)
end


function DeathController:KnitInit()
    self.CameraController = Knit.GetController("CameraController")

    Knit.Player.CharacterAdded:Connect(function()
        return self:setup()
    end)

    task.spawn(function()
        if not Knit.Player.Character then
            Knit.Player.CharacterAdded:Wait()
        end
        self:setup()
    end)
end




return DeathController