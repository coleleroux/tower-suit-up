local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local assets = ReplicatedStorage.Game.assets
local anims = assets.blaster.anims

local PlayerBlaster = {}
PlayerBlaster.__index = PlayerBlaster



function PlayerBlaster.new(playerObj)
    local self = setmetatable({ Player = playerObj }, PlayerBlaster)
    self._trove = Trove.new()
    self:setup()
    return self
end



function PlayerBlaster:NewModel()
    self.Instance = assets.blaster.model:Clone()
    self._trove:Add(self.Instance)
end



function PlayerBlaster:Destroy()
    self._trove:Destroy()
end



function PlayerBlaster:setup()
    local player = self.Player
    local char = player.Character or player.CharacterAdded:Wait()

    player.Character:WaitForChild("Animate")
    local idleAnim = player.Character.Animate:WaitForChild("idle")
    local walkAnim = player.Character.Animate:WaitForChild("walk")
	local runAnim = player.Character.Animate:WaitForChild("run")
	local jumpAnim = player.Character.Animate:WaitForChild("jump")
	local fallAnim = player.Character.Animate:WaitForChild("fall")

    -- local hum = player.Character:WaitForChild("Humanoid")
    -- local animator = hum:FindFirstChild("Animator") or Instance.new("Animator", hum)
    -- local loadIdleAnim = hum:LoadAnimation(anims.hold)
    -- loadIdleAnim:Play()
    idleAnim:WaitForChild("Animation1").AnimationId = anims.hold.AnimationId
    idleAnim:WaitForChild("Animation2").AnimationId = anims.hold.AnimationId
	-- walkAnim:WaitForChild("WalkAnim").AnimationId = anims.walk.AnimationId
	-- runAnim:WaitForChild("RunAnim").AnimationId = anims.walk.AnimationId
	-- jumpAnim:WaitForChild("JumpAnim").AnimationId = anims.jump.AnimationId
end



return PlayerBlaster