return function (surfaceNormal, bulletNormal)
	return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
end