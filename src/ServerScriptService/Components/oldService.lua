local RecycleService = {}; RecycleService.__index = RecycleService -- Server

function RecycleService:_IsBusy()
	local isBusy = os.time()-self.lastrecycle < self.thisrange
	if not isBusy then
		self.lastrecycle, self.SEED = os.time(), Random.new()
		self.thisrange = RecycleService:_GenerateDelayRange()
	end
	return isBusy
end
function RecycleService:_GenerateDelayRange()
	return self.SEED:NextNumber(RecycleService.MIN_DELAY, RecycleService.MAX_DELAY)
end

function RecycleService:NewRecycleSession(sessionid:number)
	local self = setmetatable({}, RecycleService)
	self.OUTPUT = workspace.MAP.JunkYard:FindFirstChild("Conveyor").Output -->	Recycle item dispenser
	self.EndOfOutput =	self.OUTPUT:FindFirstChild("EndOfOutput")
	self.lastrecycle, self.thisrange = os.time(), RecycleService:_GenerateDelayRange()
	do -- create recycling pooler
		shared.RunService.Heartbeat:Connect(function()
			if not self:_IsBusy() then
				--warn("recycling not busy set next range:", self.thisrange)
				do -- harmless recycling items
					local HARMLESS:table = RecycleService.MODELS.HARMLESS:GetChildren()
					local countOfHarmless:number = math.floor(self.SEED:NextInteger(RecycleService.MAX_HARMLESS_ITEMS/4, RecycleService.MAX_HARMLESS_ITEMS))
					if #HARMLESS == 0 or countOfHarmless <= 0 then return end
					for curCount:number = 1, countOfHarmless do
						local RecycleHarmlessMaid = shared.Maid.new()
						local THIS_ITEM = HARMLESS[Random.new():NextInteger(1, #HARMLESS)]
						THIS_ITEM = THIS_ITEM and THIS_ITEM:Clone()
						THIS_ITEM.Position = self.OUTPUT.Position + Vector3.new(
							self.SEED:NextNumber(-THIS_ITEM.Size.X, THIS_ITEM.Size.X),
							self.SEED:NextNumber(-THIS_ITEM.Size.Y, THIS_ITEM.Size.Y),
							self.SEED:NextNumber(-THIS_ITEM.Size.Z, THIS_ITEM.Size.Z)
						)
						table.foreach(script.Constraints.HARMLESS:GetChildren(), function(i,v)
							v:Clone().Parent = THIS_ITEM -- load constraint into Part
						end)
						THIS_ITEM.BodyPosition.Position = Vector3.new(self.EndOfOutput.Position.X,THIS_ITEM.Position.Y,THIS_ITEM.Position.Z)
						THIS_ITEM.BodyPosition.MaxForce = Vector3.new(math.random(math.random(5,25),25), math.random(50,100), 0, self.SEED:NextNumber(-5,5))
						if not THIS_ITEM then continue end
						THIS_ITEM.Parent = self.OUTPUT
						THIS_ITEM.CanCollide = true
						THIS_ITEM.CanTouch = true
						THIS_ITEM.Anchored = false
						THIS_ITEM.AssemblyLinearVelocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))
						THIS_ITEM.AssemblyAngularVelocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))
						local gyro = THIS_ITEM.BodyGyro
						local FULL_PI = math.pi
						local TWO_PI = FULL_PI * 2
						local rotateFactor = FULL_PI*.25
						RecycleHarmlessMaid:GiveTask(shared.RunService.Stepped:Connect(function(delta: number)
							if not THIS_ITEM or not THIS_ITEM.Parent then return RecycleHarmlessMaid:Destroy() end
							local sign = math.sign(THIS_ITEM.Velocity.Y) -- direction (-1 || 1 || 0)
							local axisSpin = math.rad(THIS_ITEM.Position.Y) * sign * rotateFactor
							gyro.CFrame = CFrame.Angles(0,0,axisSpin) -- specifying our angle axis's
						end))
						shared.Debris:AddItem(THIS_ITEM, 15)
					end
					
				end
			end
		end)
	end
	return self
end

function RecycleService._new()
	RecycleService.RECYCLABLES = shared.ReplicatedStorage:FindFirstChild("RECYCLABLES")
	RecycleService.MODELS = {
		HARMLESS = RecycleService.RECYCLABLES["NON HARMABLES"],
		HARMFULS = RecycleService.RECYCLABLES["HARMFULS"]
	}
	RecycleService.MAX_HARMLESS_ITEMS = 50 -- @type number, 'representing max recycle items between max/min delays'
	RecycleService.MAX_HARMFUL_ITEMS = 15 -- @type number, 'representing max recycle items between max/min delays'
	RecycleService.MAX_DELAY, RecycleService.MIN_DELAY = unpack { 5, 0.5 }
	RecycleService.SEED = Random.new()
	return RecycleService
end

return RecycleService._new()
