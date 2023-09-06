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
end



return PlayerBlaster