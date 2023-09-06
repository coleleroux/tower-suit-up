local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)


local GearCogController = Knit.CreateController({
	Name = "GearCogController",
})
local CurrentCamera = workspace.CurrentCamera
local GearCogs = workspace:WaitForChild("grinder")

GearCogController.COG_SPEED_AMP = 1.25

function GearCogController:CreateMovements()
	self.SEED = Random.new()
	do -- every cog(s) pooler
		if #self.Pool <= 0 then
			RunService.Heartbeat:Connect(function()
				if #self.Pool <= 0 then return end
				for index, cog:table in self.Pool do
					if not cog or not (cog.MODEL):IsA("BasePart") then continue end
					local COG_SPEED_AMP = GearCogController.COG_SPEED_AMP
					local COG,THIS_ANGLE,LERP_STEP = cog.MODEL,cog.THIS_ANGLE,cog.LERP_STEP
					if not THIS_ANGLE or not LERP_STEP then continue end
					local BOOST_ANGLE:number = math.abs(math.sin(tick()))--*(LERP_STEP/2)
					
					local FINAL_ANGLE = math.rad(THIS_ANGLE+(10^LERP_STEP*COG_SPEED_AMP))
					COG.CFrame = COG.CFrame:Lerp(COG.CFrame*CFrame.Angles(0,0,BOOST_ANGLE % FINAL_ANGLE), LERP_STEP)
				end
			end)
		end
	end
	for _, Gear in GearCogs:GetChildren() do
		if Gear.Name ~= "Gears" then continue end
		table.foreach(Gear:GetChildren(),
			function(key, Cog)
				table.insert(self.Pool, {
					MODEL = Cog,
					LERP_STEP = self.SEED:NextNumber(0.5,0.75);
					THIS_ANGLE = self.SEED:NextNumber(0.75,3);
				})
			end
		)
	end
end



function GearCogController:KnitStart()
	self.Pool = {}
	self:CreateMovements()
end


return GearCogController
