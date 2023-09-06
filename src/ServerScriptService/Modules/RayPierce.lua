return function(cast, rayresult, segmentVelocity)
	local hits = cast.UserData.Hits
	if (hits == nil) then
		cast.UserData.Hits = 1
	else
		cast.UserData.Hits += 1
	end

	if (cast.UserData.Hits > 3) then
		return false
	end

	local hitPart = rayresult.Instance
	if hitPart ~= nil and hitPart.Parent ~= nil then
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(10) -- Damage.
		end
	end
	return true
end
