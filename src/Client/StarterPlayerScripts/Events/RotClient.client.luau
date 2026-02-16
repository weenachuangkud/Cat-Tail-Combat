--[[
	- Author : Mawin CK
	- Date : 2024
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")
--local RS = game:GetService("RunService")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")

-- Requires
local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))


-- Events
local RotClient = UnreliablePackets.RotClient

-- Variables

--local origNeck = CFrame.new(0,1,0) * CFrame.fromOrientation(math.rad(-90), math.rad(-180), math.rad(0))
--local origRightS = CFrame.new(1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
--local origLeftS = CFrame.new(-1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(-90), math.rad(0))

--local db = {}
--local debounce = 1/30

-- VM
local VMs = script.Parent.Parent:WaitForChild("VMs")
local RotVMs = require(VMs:WaitForChild("RotVMs"))

local numWorker = 3
local Dispatcher = RotVMs.new(numWorker, nil)

-- Listeners

RotClient.OnClientEvent:Connect(function(targetPlayer : Player, RightSAngles : CFrame, LeftSAngles : CFrame, NeckAngles : CFrame, Lerping : boolean)
	--if (os.clock() - (db[targetPlayer] or 0) < debounce) then return end
	--db[targetPlayer] = os.clock()
	
	--[[local character = targetPlayer.Character
	if not character then return end
	
	local Torso = character:FindFirstChild("Torso")
	if not Torso then return end
	
	local RightShoulder = Torso:FindFirstChild("Right Shoulder")
	local LeftShoulder = Torso:FindFirstChild("Left Shoulder")
	local Neck = Torso:FindFirstChild("Neck")
	
	if not (RightShoulder and LeftShoulder and Neck) then return end
	
	--print("ROTTING")
	
	if Lerping then
		RightShoulder.C0 = RightShoulder.C0:Lerp(
			RightSAngles,
			0.1
		)
		LeftShoulder.C0 = LeftShoulder.C0:Lerp(
			LeftSAngles,
			0.1
		)
		Neck.C0 = Neck.C0:Lerp(
			NeckAngles,
			0.2
		)
	else
		RightShoulder.C0 = origRightS
		LeftShoulder.C0 = origLeftS
		Neck.C0 = origNeck
	end]]
	Dispatcher:Dispatch("Rot", targetPlayer, RightSAngles, LeftSAngles, NeckAngles, Lerping)
end)