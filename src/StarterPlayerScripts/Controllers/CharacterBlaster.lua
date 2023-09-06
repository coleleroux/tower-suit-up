local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = Knit.Player
local Mouse = Player:GetMouse()
local PlayerCamera = workspace.CurrentCamera

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spring = require(script.Parent.Parent.Modules.Spring)

local assets = ReplicatedStorage.Game.assets

local trove = Trove.new()
local subTrove = trove:Extend()
local blasterTrove = trove:Extend()--//janitor for connections

local BlasterController = Knit.CreateController({
	Name = "BlasterController",
})


function BlasterController:EquipBlaster()
	self.CameraController:ChangeFirstPerson()
end



function BlasterController:KnitInit()
	-- MyService.TestProperty:Observe(function(value)
	-- 	print("TestProperty value:", value)
	-- end)
end


function BlasterController:KnitStart()
	self.CameraController = Knit.GetController("CameraController")
	self.expectingInput = false
	self.state = "none" --// states; "none", idle", "walk", "sprint"

	self:setup()


	local MyService = Knit.GetService("PlayerBlasterService")
	MyService.EquipEvent:Connect(function(msg)
		print("Got event from server:", msg)
		self:EquipBlaster()
	end)
	MyService.EquipEvent:Fire("Hello")
	MyService:TestMethod("Hello world from client"):andThen(function(result)
		print("Result from server:", result)
	end)
end



function BlasterController:cleanup()
	blasterTrove:Destroy()
end



function BlasterController:fetchConfiguration(gunName)
	for index, value in pairs(shared.configurations["weapons"]) do
		if value.name == gunName then
			return value, index
		end
	end
end



function BlasterController:setup(gunName)
	-- if not gunName then return end
	self:cleanup()
	--! movementController:setup()
	-- self.gunData = self:fetchConfiguration(gunName)
	-- self.fireDelay = self.gunData.constants["FIRE_DELAY"]
	-- self.isAutomatic = self.gunData.constants["AUTOMATIC_MODE"]

	--! fakearmservice.Setup:Fire()
	
	local gunModel = assets.blaster.model:Clone()
	gunModel.Name = "gun"
	gunModel.Parent = PlayerCamera
	local root = gunModel:WaitForChild("root")
	local localRight = root:WaitForChild("localRight")
	--//find the fake arm
	local armsModel;
	repeat task.wait() until PlayerCamera:FindFirstChild("fakearms")
	armsModel = PlayerCamera:WaitForChild("fakearms")
	if not armsModel then return end
	--//set the gun's weld to the fakearm hand
	localRight.Part1 = armsModel:WaitForChild("right")
	
	local expectingInput = true
	self.gunModel = gunModel
	self.gunFirePoint = root:WaitForChild("gunFirePoint")
	self.mouseIsDown = false
	
	-- blasterTrove:GiveTask(uis.InputBegan:Connect(function(input, gameHandledEvent)
	-- 	if gameHandledEvent or not expectingInput then
	-- 		return
	-- 	end

	-- 	if input.UserInputType == Enum.UserInputType.MouseButton1 and mouse ~= nil then
	-- 		self.mouseIsDown = true
	-- 	end
	-- end))
	
	-- blasterTrove:GiveTask(uis.InputEnded:Connect(function(input, gameHandledEvent)
	-- 	if gameHandledEvent or not expectingInput then
	-- 		return
	-- 	end

	-- 	if input.UserInputType == Enum.UserInputType.MouseButton1 and mouse ~= nil then
	-- 		self.mouseIsDown = false
	-- 	end
	-- end))
	
	Mouse.TargetFilter = PlayerCamera
end

function BlasterController:canShoot()
	if not self.nextshot then
		self.nextshot = 0
	end
	if tick()>self.nextshot then
		self.nextshot = tick()+self.fireDelay
		
		return true
	end
	
end

function BlasterController:update()
	if self.mouseIsDown and self:canShoot() then
		-- movementController:startShooting()
		
		if not self.isAutomatic then --//only shoot once
			self.mouseIsDown = false
		end
		
		--! gunservice.FireGun:Fire({ self.gunFirePoint.WorldPosition, mouse.Hit.Position })
		--! fakearmservice.Recoil:Fire(self.mouseIsDown and self.isAutomatic)
		
		-- if not self.stopsprint then
		-- 	self.stopsprint = true
		-- 	task.spawn(function()
		-- 		task.wait(tick()-self.nextshot+0.75)
				
		-- 		movementController:cancelShooting()
		-- 		self.stopsprint = false
		-- 	end)
		-- end
	end
end



return BlasterController