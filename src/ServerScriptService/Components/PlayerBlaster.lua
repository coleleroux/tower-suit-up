local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local assets = ReplicatedStorage.Game.assets
local vfx = assets:FindFirstChild("vfx")
local anims = assets.blaster.anims



local fastcast = require(script.Parent.Parent.Modules.FastCast)
local partcache = require(script.Parent.Parent.Modules.PartCache)
local reflect = require(script.Parent.Parent.Modules.Reflect)
local raypierce = require(script.Parent.Parent.Modules.RayPierce)



local DEBUG, PIERCE_DEMO = false, false
local PART_CACHE_SIZE = 100
local RNG = Random.new()
local TAU = math.pi * 2

local cosmeticsBulletsFolder, cosmeticBullet, cosmeticPartProvider;

local added = Players.PlayerAdded
local removed = Players.PlayerRemoving


local PlayerBlaster = {}
PlayerBlaster.__index = PlayerBlaster


local 		constants = {
    BULLET_SPEED = 200;
    BULLET_MAXDIST = 1000;
    BULLET_GRAVITY = Vector3.new(0, workspace.Gravity^0.70*-1, 0),
    MIN_BULLET_SPREAD_ANGLE = 0;
    MAX_BULLET_SPREAD_ANGLE = 0;
    FIRE_DELAY = 0.05;
    BULLETS_PER_SHOT = 1;
    AUTOMATIC_MODE = true;
}


function PlayerBlaster.new(playerObj)
    local self = setmetatable({ Player = playerObj }, PlayerBlaster)
    self._trove = Trove.new()

    for index, value in constants do
		self[index] = value
	end

    self:setup()
    return self
end



local firedSound = Instance.new("Sound")
firedSound.Volume = 0.30-- lower volume so i don't go insane lol
firedSound.SoundId = "rbxassetid://7680757322"
-- A function to play fire sounds.
function PlayerBlaster:PlayFiredSound(handle)
	if not handle then return end
	
	local newSound = firedSound:Clone()
	newSound.Parent = handle
	newSound:Play()
	
	game:GetService("Debris"):AddItem(newSound, newSound.TimeLength)
end



local splashSound = Instance.new("Sound")
splashSound.Volume = 0.20
splashSound.SoundId = "rbxassetid://2846734837"
-- A function to play splash sounds.
function PlayerBlaster:playSplashedSound(handle)
	if not handle then return end

	local newSound = splashSound:Clone()
	newSound.Parent = handle
	newSound:Play()

	game:GetService("Debris"):AddItem(newSound, newSound.TimeLength)
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
    if not player or not player.Character then return end
	player.DevEnableMouseLock = false

	self.canFire = true
	self.caster = fastcast.new()--//create a new caster object

	local castParams = RaycastParams.new()
	castParams.IgnoreWater = true
	castParams.FilterType = Enum.RaycastFilterType.Exclude
	castParams.FilterDescendantsInstances = {player.Character, cosmeticsBulletsFolder}

	self.castParams = castParams
	self.cosmeticPartProvider = partcache.new(cosmeticBullet, PART_CACHE_SIZE, cosmeticsBulletsFolder)

	local castBehavior = fastcast.newBehavior()
	castBehavior.RaycastParams = self.castParams
	castBehavior.MaxDistance = self.BULLET_MAXDIST
	castBehavior.HighFidelityBehavior = fastcast.HighFidelityBehavior.Default
	--CastBehavior.CosmeticBulletTemplate = CosmeticBullet --//uncomment if you just want a simple template part and aren't using PartCache
	castBehavior.CosmeticBulletProvider = self.cosmeticPartProvider --//comment out if you aren't using PartCache.
	castBehavior.CosmeticBulletContainer = cosmeticsBulletsFolder
	castBehavior.Acceleration = self.BULLET_GRAVITY
	castBehavior.AutoIgnoreContainer = false

	self.castBehavior = castBehavior

	self.caster.RayHit:Connect(function(...)
		return self:onRayHit(...)
	end)
	self.caster.RayPierced:Connect(function(...)
		return self:onRayPierced(...)
	end)
	self.caster.LengthChanged:Connect(function(...)
		return self:onRayUpdated(...)
	end)
	self.caster.CastTerminating:Connect(function(...)
		return self:onRayTerminated(...)
	end)
end



return PlayerBlaster