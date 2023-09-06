local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerGui = Knit.Player:WaitForChild("PlayerGui")
local spr = require(script.Parent.Parent.Modules.spr)


local Portal = workspace:WaitForChild("Portal")
local TouchPart = Portal:WaitForChild("TouchPart")



local PlayBoard = workspace:WaitForChild("PlayBoard")
local PlayBoardDisplay = PlayBoard:WaitForChild("Display")
local PlayButton = PlayBoardDisplay:WaitForChild("Play")

PlayBoardDisplay.Adornee = PlayBoard
PlayBoardDisplay.Parent = PlayerGui:WaitForChild("MainUI")

local function LoopPlayBoard(inorout)
    spr.target(PlayButton, inorout and 0.9 or 0.6, inorout and 1 or 2, {Size = inorout and UDim2.new(1,0,0.80,0) or UDim2.new(1,0,0.50,0)})
    spr.completed(PlayButton, function()
        LoopPlayBoard(not inorout)
    end)
end

LoopPlayBoard(false)



local WelcomeBeam = workspace:WaitForChild("WelcomeBeam")

task.spawn(function()
    local char = Knit.Player.Character or Knit.Player.CharacterAdded:Wait()
    if char then
        WelcomeBeam.Attachment0 = char:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment")
        WelcomeBeam.Attachment1 = TouchPart:WaitForChild("WelcomeAttachment")
    end
end)




local UIController = Knit.CreateController({
	Name = "UIController",
})



function UIController:KnitStart()
    local TeleportController = Knit.GetController("TeleportController")

    PlayBoardDisplay.Play.MouseEnter:Connect(function()
        SoundService:WaitForChild("interface"):WaitForChild("MouseHover"):Play()
    end)
    PlayBoardDisplay.Play.MouseButton1Click:Connect(function()
        TeleportController:Teleport()
        SoundService:WaitForChild("interface"):WaitForChild("MouseClick"):Play()
    end)

end





return UIController