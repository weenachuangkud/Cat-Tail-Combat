--[[
	- Author : Mawin CK
	- Date : 2024
]]

local Math = {}

function Math.clampVector3(vec: Vector3, maxMagnitude: number): Vector3
	if vec.Magnitude > maxMagnitude then
		return vec.Unit * maxMagnitude
	end
	return vec
end

function Math.ConvertZoomLevelToFOV(base : number, level : number)
	return 2 * math.deg(math.atan(math.tan(math.rad(base / 2)) / level))
end

return Math