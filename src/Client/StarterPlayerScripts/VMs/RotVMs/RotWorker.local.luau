--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- CONSTs
local origNeck = CFrame.new(0,1,0) * CFrame.fromOrientation(math.rad(-90), math.rad(-180), math.rad(0))
local origRightS = CFrame.new(1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
local origLeftS = CFrame.new(-1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(-90), math.rad(0))

-- Actors
local Actor = script:GetActor()
local ActorParent = script.Parent

-- Local functions
local function IntTask(amount : number)
	ActorParent:SetAttribute("Tasks", ActorParent:GetAttribute("Tasks")+amount)
end

-- Listeners
Actor:BindToMessage("Rot", function(targetPlayer : Player, RightSAngles : CFrame, LeftSAngles : CFrame, NeckAngles : CFrame, Lerping : boolean)
	IntTask(1)
	task.desynchronize()
	local character = targetPlayer.Character
	if not character then return end

	local Torso = character:FindFirstChild("Torso")
	if not Torso then return end

	local RightShoulder = Torso:FindFirstChild("Right Shoulder")
	local LeftShoulder = Torso:FindFirstChild("Left Shoulder")
	local Neck = Torso:FindFirstChild("Neck")

	if not (RightShoulder and LeftShoulder and Neck) then return end

	--print("ROTTING")
	local l =  RightShoulder.C0:Lerp(
		RightSAngles,
		0.1
	)
	local r = LeftShoulder.C0:Lerp(
		LeftSAngles,
		0.1
	)
	local n = Neck.C0:Lerp(
		NeckAngles,
		0.2
	)

	task.synchronize()
	if Lerping then
		RightShoulder.C0 = l
		LeftShoulder.C0 = r
		Neck.C0 = n
	else
		RightShoulder.C0 = origRightS
		LeftShoulder.C0 = origLeftS
		Neck.C0 = origNeck
	end
	IntTask(-1)
end)