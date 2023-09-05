local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local CameraController = Knit.CreateController({
	Name = "CameraController",
})
local CurrentCamera = workspace.CurrentCamera


function CameraController:ChangeFirstPerson()
	CurrentCamera.CameraType = Enum.CameraType.Custom
	Knit.Player.CameraMode = Enum.CameraMode.LockFirstPerson
end



function CameraController:ChangeBackClassic()
	CurrentCamera.CameraType = Enum.CameraType.Custom
	Knit.Player.CameraMode = Enum.CameraMode.Classic
end


return CameraController