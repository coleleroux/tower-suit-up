local debris = game:GetService("Debris")
local players = game:GetService("Players")
local replicatedstorage = game:GetService("ReplicatedStorage")
local sia = require(replicatedstorage:WaitForChild("sia"))

local profile = sia:utility("profile")
local fastcast = sia:utility("fastcast")
local partcache = sia:utility("partcache")
local reflect = sia:utility("reflect")
local raypierce = sia:utility("raypierce")

local assets = sia:package("assets")
local vfx = sia:package("vfx","assets")

local DEBUG, PIERCE_DEMO = false, false
local PART_CACHE_SIZE = 100
local RNG = Random.new()
local TAU = math.pi * 2

local cosmeticsBulletsFolder, cosmeticBullet, cosmeticPartProvider;

local added = players.PlayerAdded
local removed = players.PlayerRemoving
local animations;


local cast = {} --//fastcast sessions
local sessions = {}
sessions.container = {}

function sessions:get(player)
	if not player then return end

	return sessions.container[player.UserId]
end

function sessions:add(player, class)
	if not class or not player then return end
	
	local plrSession = sessions:get(player)
	if plrSession then
		sessions:remove(player)
	end
	
	sessions.container[player.UserId] = class
end

function sessions:remove(player)
	local plrSession = sessions:get(player)
	if plrSession then
		plrSession:cleanup()
	end

	sessions.container[player.UserId] = nil
end

local gun = {}

function gun:service()
	return {
		name = "gun",
		signals = {
			"EquipGun",
			"FireGun",
		}
	}
end


function gun:new()
	self.service = sia.services:GetService("gun")
end

function gun:setup()
	local player = self.player
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

function gun:cleanup()
	
end

function gun:fetchConfiguration(gunName)
	for index, value in pairs(shared.configurations["weapons"]) do
		if value.name == gunName then
			return value, index
		end
	end
end



function gun:construct(player, gunName)
	local new = setmetatable({}, {__index=gun})
	new.player = player
	new.gunName = gunName
	new.gunData = new:fetchConfiguration(gunName)
	if not new.gunData then return end
	
	for index, value in new.gunData["constants"] do
		new[index] = value
	end
	
	new:setup()
	sessions:add(player, new)
	
	return new
end



local firedSound = Instance.new("Sound")
firedSound.Volume = 0.30-- lower volume so i don't go insane lol
firedSound.SoundId = "rbxassetid://7680757322"
-- A function to play fire sounds.
function gun:playFiredSound(handle)
	if not handle then return end
	
	local newSound = firedSound:Clone()
	newSound.Parent = handle
	newSound:Play()
	
	debris:AddItem(newSound, newSound.TimeLength)
end



local splashSound = Instance.new("Sound")
splashSound.Volume = 0.20
splashSound.SoundId = "rbxassetid://2846734837"
-- A function to play splash sounds.
function gun:playSplashedSound(handle)
	if not handle then return end

	local newSound = splashSound:Clone()
	newSound.Parent = handle
	newSound:Play()

	debris:AddItem(newSound, newSound.TimeLength)
end



function gun:makeSplashParticleFX(position, normal)
	-- This is a trick I do with attachments all the time.
	-- Parent attachments to the Terrain - It counts as a part, and setting position/rotation/etc. of it will be in world space.
	-- UPD 11 JUNE 2019 - Attachments now have a "WorldPosition" value, but despite this, I still see it fit to parent attachments to terrain since its position never changes.
	local rateofemit = math.random(1,4)
	
	local splashPartFX = vfx["1"].splash:Clone()
	splashPartFX.CanCollide = false
	splashPartFX.Anchored = true
	splashPartFX.CFrame = CFrame.new(position, position + normal)*CFrame.Angles(math.rad(-90),math.rad(-90),0) --+Vector3.new(0,splashPartFX.Size.Y,0)
	
	splashPartFX.Parent = cosmeticsBulletsFolder
	
	for index, value in pairs(splashPartFX:GetDescendants()) do
		if value:IsA("ParticleEmitter") then
			value.Enabled = false
			value:Emit(rateofemit)
		end
	end
	debris:AddItem(splashPartFX, 1) -- Automatically delete the particle effect after its maximum lifetime.
end



function gun:initialize()
	fastcast.DebugLogging = DEBUG
	fastcast.VisualizeCasts = DEBUG

	cosmeticsBulletsFolder = workspace:FindFirstChild("cosmeticsBulletsFolder") or Instance.new("Folder", workspace)
	cosmeticsBulletsFolder.Name = "cosmeticsBulletsFolder"

	cosmeticBullet = Instance.new("Part")--//this will be cloned every time we fire off a ray.
	cosmeticBullet.Material = Enum.Material.Neon
	cosmeticBullet.Color = Color3.fromRGB(0, 196, 255)
	cosmeticBullet.CanCollide = false
	cosmeticBullet.Anchored = true
	cosmeticBullet.Size = Vector3.new(0.2, 0.2, 2.4)
	
	animations = sia:package("animations","gun")
	
	
	self:onAdded()
	self:onRemoved()
	
	self.service.EquipGun:Connect(function(player,gunName)
		return self:equipGun(player,gunName)
	end)
	
	self.service.FireGun:Connect(function(player, args)
		if type(args)~='table' then return end
		
		local plrSession = sessions:get(player)
		if not plrSession then return end
		
		local pointWorldPos, mousePoint = unpack(args)
		
		if not pointWorldPos or not mousePoint then return end
		if not plrSession.canFire then return end
		plrSession.canFire = false
		
		local mouseDirection = (mousePoint - pointWorldPos).Unit
		for i = 1, plrSession.BULLETS_PER_SHOT do
			self:fireGun(player, pointWorldPos, mouseDirection)
		end
		if plrSession.FIRE_DELAY > 0.03 then wait(plrSession.FIRE_DELAY) end
		plrSession.canFire = true
	end)
end





function gun:coreAnimations(player)
	if not player or player.Character then return end
	
	repeat task.wait() until player.Character:FindFirstChild("Animate")
	
	local walkAnim = player.Character.Animate:WaitForChild("walk")
	local runAnim = player.Character.Animate:WaitForChild("run")
	local jumpAnim = player.Character.Animate:WaitForChild("jump")
	local fallAnim = player.Character.Animate:WaitForChild("fall")
	
	walkAnim:WaitForChild("WalkAnim").AnimationId = animations.walk.AnimationId
	runAnim:WaitForChild("RunAnim").AnimationId = animations.walk.AnimationId
	jumpAnim:WaitForChild("JumpAnim").AnimationId = animations.jump.AnimationId
end



function gun:onRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	local player = self.player
	if not player or not player.Character then return end
	-- This function will be connected to the Caster's "RayHit" event.
	local hitPart = raycastResult.Instance
	local hitPoint = raycastResult.Position
	local normal = raycastResult.Normal
	if hitPart ~= nil and hitPart.Parent ~= nil then -- Test if we hit something
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid") -- Is there a humanoid?
		if humanoid then
			--humanoid:TakeDamage(humanoid.MaxHealth) -- Damage.
			humanoid.Health = 0--//instant-kill
		end
		
		self:makeSplashParticleFX(hitPoint, normal)--//particle splash effects
		
		local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			self:playSplashedSound(humanoidRootPart)
		end
		
	end
end

function gun:onRayPierced(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- You can do some really unique stuff with pierce behavior - In reality, pierce is just the module's way of asking "Do I keep the bullet going, or do I stop it here?"
	-- You can make use of this unique behavior in a manner like this, for instance, which causes bullets to be bouncy.
	local position = raycastResult.Position
	local normal = raycastResult.Normal

	local newNormal = reflect(normal, segmentVelocity.Unit)
	cast:SetVelocity(newNormal * segmentVelocity.Magnitude)

	-- It's super important that we set the cast's position to the ray hit position. Remember: When a pierce is successful, it increments the ray forward by one increment.
	-- If we don't do this, it'll actually start the bounce effect one segment *after* it continues through the object, which for thin walls, can cause the bullet to almost get stuck in the wall.
	cast:SetPosition(position)

	-- Generally speaking, if you plan to do any velocity modifications to the bullet at all, you should use the line above to reset the position to where it was when the pierce was registered.
end

function gun:onRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	if cosmeticBulletObject == nil then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function gun:onRayTerminated(cast)
	if not cast then return end
	
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		-- This code here is using an if statement on CastBehavior.CosmeticBulletProvider so that the example gun works out of the box.
		-- In your implementation, you should only handle what you're doing (if you use a PartCache, ALWAYS use ReturnPart. If not, ALWAYS use Destroy.
		if self.castBehavior.CosmeticBulletProvider ~= nil then
			self.castBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
		else
			cosmeticBullet:Destroy()
		end
	end
end



function gun:charAdded(player)
	if not player then return end
	repeat task.wait() until player.Character
	
	
	task.spawn(function()self:coreAnimations(player)end)
end



function gun:onAdded()
	for index, value in pairs(players:GetPlayers()) do
		self:charAdded(value)
	end

	added:Connect(function(p)
		p.CharacterAdded:Connect(function(c)
			repeat task.wait() until c and c:IsDescendantOf(workspace)

			self:charAdded(p)
		end)
	end)
end



function gun:onRemoved()
	removed:Connect(function(p)
		sessions:remove(p)
	end)
end



function gun:fireGun(player, pointWorldPos, direction)
	if not player or not player.Character then return end

	local plrSession = sessions:get(player)
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not plrSession then return end
	if not humanoidRootPart then return end

	local directionalCF = CFrame.new(Vector3.new(), direction)
	-- Now, we can use CFrame orientation to our advantage.
	-- Overwrite the existing Direction value.
	local direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(plrSession.MIN_BULLET_SPREAD_ANGLE, plrSession.MAX_BULLET_SPREAD_ANGLE)), 0, 0)).LookVector

	-- IF YOU DON'T WANT YOUR BULLETS MOVING WITH YOUR CHARACTER, REMOVE THE THREE LINES OF CODE BELOW THIS COMMENT.
	-- We need to make sure the bullet inherits the velocity of the gun as it fires, just like in real life.
	local myMovementSpeed = humanoidRootPart.Velocity							-- To do: It may be better to get this value on the clientside since the server will see this value differently due to ping and such.
	local modifiedBulletSpeed = (direction * plrSession.BULLET_SPEED)-- + myMovementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.

	if PIERCE_DEMO then
		plrSession.castBehavior.CanPierceFunction = raypierce
	end

	local simBullet = plrSession.caster:Fire(pointWorldPos, direction, modifiedBulletSpeed, plrSession.castBehavior) --//pointWorldPos: FirePointObject.WorldPosition
	if (simBullet and simBullet.RayInfo) and simBullet.RayInfo.CosmeticBulletObject then
		--local cosmeticObject = simBullet.RayInfo.CosmeticBulletObject
		--if not self.lastCachedPart then
		--	self.lastCachedPart = cosmeticObject
		--end
		
		----local currentPartStatus = self.castBehavior.CosmeticBulletProvider:CheckPartStatus(cosmeticObject)
		--local lastPartStatus = plrSession.castBehavior.CosmeticBulletProvider:CheckPartStatus(self.lastCachedPart)
		--print("lastPartStatus",lastPartStatus)
		
		--for index, value in pairs(cosmeticObject:GetChildren())do
		--	if value:IsA("Beam") or value.Name == "trailAttach" then
		--		value:Destroy()
		--	end
		--end
		
		--local tBeam = cosmeticBullet:FindFirstChild("Beam")
		--if not tBeam then
		--	tBeam = vfx["1"].trail.Beam:Clone()
		--	tBeam.Parent = cosmeticObject
		--	tBeam.Enabled = true
		--end
		--local tAttachment = cosmeticBullet:FindFirstChild("trailAttach")
		--if not tAttachment then
		--	tAttachment = Instance.new("Attachment")
		--	tAttachment.Parent = cosmeticObject
		--	tAttachment.Name = "trailAttach"
		--	tAttachment.CFrame = CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(90),0)
		--end
		
		--if lastPartStatus=="Open" and self.lastCachedPart:FindFirstChild("trailAttach") then
		--	tBeam.Attachment0,tBeam.Attachment1 = self.lastCachedPart.trailAttach, tAttachment
		--end
		
		--self.lastCachedPart = cosmeticObject
	end
	self:playFiredSound(humanoidRootPart)
end



function gun:equipGun(player,gunName)
	if not player or not gunName then return end
	
	local playerdata;
	repeat task.wait() playerdata = profile:get(player) until playerdata
	
	if not table.find(playerdata.weapons,gunName) then return end

	playerdata.equippedGun = gunName
	player:WaitForChild("values"):WaitForChild("equippedGun").Value = gunName
	
	local plrSession = self:construct(player, gunName)
end



return gun
