--[[
	- Author : Mawin CK
	- Date : 2025
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")

-- Requires
local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))
local FastCast2 = require(Libraries:WaitForChild("FastCast2"))

-- Folders
local GunEngine_Client = script.Parent.Parent
local VMsFolder = GunEngine_Client:WaitForChild("VMs")
local ActorContainers = GunEngine_Client:WaitForChild("ActorContainers")

-- Caster
local Caster = FastCast2.new()
Caster:Init(
	4,
	VMsFolder,
	"ProjectileVMs",
	ActorContainers,
	"ProjectileServerWorks",
	"ProjectileWorkers"
)

-- Behavior
local FastCastbehavior = FastCast2.newBehavior()

-- Listeners

UnreliablePackets.ProjectileRayClient.OnServerEvent:Connect(function(Firedplayer : PLayer, Origin : Vector3, Direction : Vector3, Tool)

end)