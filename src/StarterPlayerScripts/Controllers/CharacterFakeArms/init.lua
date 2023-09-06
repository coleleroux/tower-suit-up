local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Mouse = Knit.Player:GetMouse()
local PlayerCamera = workspace.CurrentCamera

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spring = require(script.Parent.Parent.Modules.Spring)

local assets = ReplicatedStorage.Game.assets

local trove = Trove.new()
local subTrove = trove:Extend()
local renderTrove = trove:Extend()--//janitor for connections

local FakeArmsController = Knit.CreateController({
	Name = "FakeArmsController",
})

local armsModel


-- viewmodel springs

local ZEROVECTOR=Vector3.new()
local viewmodelSpring = Spring.new(ZEROVECTOR)
viewmodelSpring.Speed = 20
viewmodelSpring.Damper = 0.70 --1 is perfect dampening

--//movement springs

local springSTS = Spring.new(0) --//sts meaning, side to side
springSTS.Speed = 18
springSTS.Damper = 0.65 --1 is perfect dampening

local springJump = Spring.new(ZEROVECTOR) --//spring used to control jump movement
springJump.Speed = 12.0
springJump.Damper = 0.85 --1 is perfect dampening
local springSprint = Spring.new(0) --//spring used to control sprint movement
springSprint.Speed = 15.0
springSprint.Damper = 0.60 --1 is perfect dampening

local RECOIL_RESOLVE = 20.0-- how fast the impulse on the spring is
local springRecoilGun = Spring.new(0) --//spring used to control recoil movement
springRecoilGun.Speed = RECOIL_RESOLVE
springRecoilGun.Damper = 0.90 --1 is perfect dampening

local springRecoilView = Spring.new(0) --//spring used to control recoil movement on the arms viewmodel
springRecoilView.Speed = RECOIL_RESOLVE/2
springRecoilView.Damper = 0.70 --1 is perfect dampening

local springBOBcos = Spring.new(0) --//cosine spring for walking bobbing
springBOBcos.Speed = 40.0
springBOBcos.Damper = 0.90 --1 is perfect dampening

local springBOBsine = Spring.new(0) --//sine spring for walking bobbing
springBOBsine.Speed = 30.0
springBOBsine.Damper = 0.80 --1 is perfect dampening


-- viewmodel helper funcs

function angleBetween(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end

local deltaSensitivity = -1 -- increases force from mouse delta
--if negative force goes in opposite direction, viewmodel is lagging behind
local maxAngle = 20 --degrees

local previousGoalCFrame = CFrame.new()
local previousMovementCFrame = CFrame.new()



function FakeArmsController:KnitInit()
	self.state = "none" --//states: "none","Show"
	self.recoilState = "none" --//states: "none","inuse"
end


function FakeArmsController:KnitStart()
	self:setup()
end


local ARM_TILT_DEG = 9.0 --//degrees for the initial arm tilt
local GUN_OFFSET = CFrame.new(0,0,0)*CFrame.Angles(math.rad(4.0),math.rad(-ARM_TILT_DEG*1.05),math.rad(-2.0))--//cframe offset of just the gun from the camera
local VIEWMODEL_OFFSET = CFrame.new(0,-0.40,0.30)*CFrame.Angles(0,0,0)--//cframe offset of entire viewmodel from camera
--//cframe offset of viewmodel hand from camera
local LEFT_ARM_C1 = CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(ARM_TILT_DEG/2),0) --//C1 joint cframe offset
local RIGHT_ARM_C1 = CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(-ARM_TILT_DEG),0) --//C1 joint cframe offset

function FakeArmsController:setup()
	renderTrove:Clean()--//cleanup connections
	self.state = "Show"
	
	armsModel = assets:WaitForChild("fakearms"):Clone()
	--//gun offset setup
	local gunModel = PlayerCamera:WaitForChild("gun")
	local gunHRP = gunModel:WaitForChild("root")
	local weldLocalRight = gunHRP:WaitForChild("localRight")
	weldLocalRight.C1*=GUN_OFFSET
	self.rightGunWeld = weldLocalRight
	self.rightGunC1 = weldLocalRight.C1
	
	--//arms offset setup
	local psuedoHRP = armsModel:WaitForChild("root")
	local weldViewLeft = psuedoHRP:WaitForChild("left")
	local weldViewRight = psuedoHRP:WaitForChild("right")
	weldViewLeft.C1*=LEFT_ARM_C1
	weldViewRight.C1*=RIGHT_ARM_C1

	--//connections setup
    renderTrove:BindToRenderStep("Test", Enum.RenderPriority.Last.Value, function(step)
        return self:render(step)
    end)
	--//cleanup management
	renderTrove:Add(function()
		return self:cleanup()
	end)
end

function FakeArmsController:cleanup()
    if not armsModel then return end

    game:GetService("Debris"):AddItem(armsModel,0) --//destroy arms model
end

--//number spring stuff
local RNG = Random.new()
local laststep = tick()
--//constant variables for sprigns
local SWAY_STS = 4.0 --//degrees for side to side swaying
local WALK_BOB_DEG = 0.40 --//degrees for bobbing whilst walking
local JUMP_OFFSET = Vector3.new(0,-1,0)--//vector offset for when player has jumped
local SPRINT_TILT = -12.0--//rotation offset for player sprinting with gun
local RECOIL_DEG_MIN = 6.0 --//degrees for recoil rotation movement
local RECOIL_DEG_MAX = 10.0 --//degrees for recoil rotation movement

--//bobbing formula from: https://en.wikipedia.org/wiki/Lissajous_curve
function FakeArmsController:render(step)
	if self.state == "Show" then
		if not Knit.Player.Character then return end
		if not Knit.Player.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		
		armsModel.Parent = PlayerCamera
		local fakearmsCamera = armsModel:WaitForChild("camera")
		local psuedoHRP = armsModel:WaitForChild("root")

		local plrRoot = Knit.Player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = Knit.Player.Character:WaitForChild("Humanoid")
		--// walk/movement stuff
		local isRecoiling = self.recoilState=="inuse"
		local isMoving, isJumping, isSprinting;
		isSprinting = humanoid:GetAttribute("Sprinting")
		if humanoid.MoveDirection.Magnitude > 0.1 then
			isMoving = true --//character is moving
		end
		isJumping = humanoid.Jump==true
		
		local goalCFrame, movementCFrame = PlayerCamera.CFrame, CFrame.new()
		
		local moveDirection = workspace.CurrentCamera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
		local movementDifferenceCF = previousGoalCFrame
		if math.round(moveDirection.X) == -1 then --//walking left
			springSTS.Target = SWAY_STS
		elseif math.round(moveDirection.X) == 1 then --//walking right
			springSTS.Target = -SWAY_STS
		elseif math.round(moveDirection.Z) == -1 then --//walking forwards
			springSTS.Target = 0
		elseif math.round(moveDirection.Z) == 1 then --//walking backwards
			springSTS.Target = 0
		else
			springSTS.Target = 0
		end
		
		--// jump spring bobbing
		local jumpOffsetCFrame = CFrame.new(ZEROVECTOR)
		if isJumping and (humanoid.FloorMaterial==Enum.Material.Air) then --//player is jumping set spring
			springJump.Target = JUMP_OFFSET
		else
			springJump.Target = ZEROVECTOR --// Vector.new(0,0,0)
		end
		jumpOffsetCFrame = CFrame.new(springJump.Position) --//convert vector to cframe for offset
		--// walking spring bobbing
		if isMoving then
			local bobbingSpeed = math.floor(humanoid.WalkSpeed * 0.70)
			springBOBcos.Target = WALK_BOB_DEG*math.cos(bobbingSpeed*tick())
			springBOBsine.Target = (WALK_BOB_DEG*0.30)*math.sin(bobbingSpeed*tick())
		else
			springBOBcos.Target,springBOBsine.Target = 0.00, 0.00 --//reset bobbing springs
		end
		
		local sprintOffsetCFrame = CFrame.new(ZEROVECTOR);
		if isSprinting then --//player is sprinting
			springSprint.Target = SPRINT_TILT
			local sprintZAxisDistance = SPRINT_TILT/math.abs(SPRINT_TILT)
			sprintOffsetCFrame *= CFrame.new(0,0,0.60*sprintZAxisDistance)
		else
			springSprint.Target = 0
		end
		
		local recoilArmsOffsetCFrame = CFrame.new(ZEROVECTOR)
		local recoilGunOffsetCFrame = CFrame.new(ZEROVECTOR)
		

		if isRecoiling then
			local recoilGunRNG = RNG:NextInteger(RECOIL_DEG_MIN*0.45,RECOIL_DEG_MAX*0.45)
			local recoilViewRNG = RNG:NextInteger(RECOIL_DEG_MIN*1.10,RECOIL_DEG_MAX*1.20)
			self.recoilState = "none"
		

			if isMoving then--//is walking
				recoilGunRNG*=-5.0
				recoilViewRNG*=-2.75
			else
				recoilGunRNG*=-1.0
				recoilViewRNG*=-1.0
			end
			
			springRecoilGun.Target = -1.00*recoilGunRNG
			springRecoilView.Target = recoilViewRNG
		else
			springRecoilView.Target = 0
			springRecoilGun.Target = 0
		end
		

		
		recoilArmsOffsetCFrame*=CFrame.Angles(math.rad(springRecoilView.Position),0,0)--//recoil; apply rotation tilt to viewmodel including gun
		recoilGunOffsetCFrame*=CFrame.Angles(math.rad(springRecoilGun.Position),0,0)--//recoil; apply rotation tilt to gun
		if self.rightGunWeld then
			self.rightGunWeld.C1 = self.rightGunC1*recoilGunOffsetCFrame
		end
		
		
		sprintOffsetCFrame*=CFrame.Angles(math.rad(springSprint.Position),0,0)--//whilst sprinting; apply rotation tilt to gun on the x axis
		local goalMovementCFrame = CFrame.Angles(
			0,
			0,
			math.rad(springSTS.Position)
		);
		local goalBobbingCFrame = CFrame.new(0,0,0)*CFrame.Angles(
			math.rad(springBOBcos.Position),
			0,
			math.rad(springBOBsine.Position)
		);
		
		previousMovementCFrame = goalMovementCFrame*goalBobbingCFrame
		goalCFrame = goalCFrame*previousMovementCFrame --//offset displaced character movement to viewmodel spring
		psuedoHRP.CFrame = goalCFrame*VIEWMODEL_OFFSET*(recoilArmsOffsetCFrame*sprintOffsetCFrame*jumpOffsetCFrame)
		
		--///spring stuff
		local differenceCF = previousGoalCFrame:ToObjectSpace(goalCFrame)
		local axis, angle = differenceCF:ToAxisAngle()
		local angularDisplacement = axis*angle

		previousGoalCFrame = goalCFrame
		previousMovementCFrame = movementCFrame

		local springForce = angularDisplacement*deltaSensitivity
		viewmodelSpring:Impulse(springForce)

		local partSpringOffset = viewmodelSpring.Position
		local axis = partSpringOffset.Unit
		local angle = partSpringOffset.Magnitude

		--clamp the angle don't want it to speen 360 degrees unless you want it to
		--velocity goes wild though
		angle = math.deg(angle)
		if angle > maxAngle then
			local currentViewModelVelocity = viewmodelSpring.Velocity
			local collision = math.sign(currentViewModelVelocity:Dot(axis))
			--1 is colliding, -1 is going away from colliding wall normal
			if collision > 0 then
				local reactionAngle = angleBetween(currentViewModelVelocity.Unit,axis)
				local resolve = math.cos(reactionAngle)
				local reactionForce = -axis*currentViewModelVelocity.Magnitude*resolve
				viewmodelSpring:Impulse(reactionForce)
			end
		end
		angle = math.clamp(angle,0,maxAngle)
		angle = math.rad(angle)
		if angle > 0.001 then--Nan check checking if there is no spring caused rotation
			psuedoHRP.CFrame *= CFrame.fromAxisAngle(axis,angle)
		end
		--psuedoHRP.CFrame *= movementDisplacement
	elseif self.state == "none" then

	end
end



return FakeArmsController