--!strict
--[[
	- Author : Suphi Kaner
	- Modded by : Mawin CK
]]

-- Services
local RunService = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")
local Libraries = Rep:WaitForChild("Gun_Engine").Modules.Libraries

-- Requires
local Packet = require(Libraries:WaitForChild("Packet"))

local unreliablePackets = {
	-- RightSAngles : CFrame, LeftSAngles : CFrame, NeckAngles : CFrame, Lerping : boolean
	RotServer = Packet("RotServer", Packet.CFrameF24U8, Packet.CFrameF24U8, Packet.CFrameF24U8, Packet.Boolean8),
	-- targetPlayer : Player, RightSAngles : CFrame, LeftSAngles : CFrame, NeckAngles : CFrame, Lerping : boolean
	RotClient = Packet("RotClient", Packet.Instance, Packet.CFrameF24U8, Packet.CFrameF24U8, Packet.CFrameF24U8, Packet.Boolean8),
	
	-- Limb : string
	BloodServer = Packet("BloodServer", Packet.String),
	-- targetPlayer : Player, Limb : string
	BloodClient = Packet("BloodClient", Packet.Instance, Packet.String),
	
	-- Casing
	
	-- RayFire Server : Origin, Direction, Tool
	ProjectileRayServer = Packet("ProjectileRayServer", Packet.Vector3F32, Packet.Vector3F32, Packet.Instance),
	
	-- RayFire Client : TargetPlayer, Origin, Direction, Tool
	
	ProjectileRayClient = Packet("ProjectileRayClient", Packet.Instance, Packet.Vector3F32, Packet.Vector3F32, Packet.String)
}

for index, packet in unreliablePackets do
	local packet = packet :: Packet.Packet

	if RunService:IsServer() then
		local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent.Name = packet.Name
		unreliableRemoteEvent.Parent = script
		unreliableRemoteEvent.OnServerEvent:Connect(function(player, ...)
			packet.OnServerEvent:Fire(player, packet:Deserialize(...))
		end)

		packet.Fire = function(packet, ...)
			unreliableRemoteEvent:FireAllClients(packet:Serialize(...))
		end

		packet.FireClient = function(packet, player, ...)
			unreliableRemoteEvent:FireClient(player, packet:Serialize(...))
		end
	else
		local unreliableRemoteEvent = script:WaitForChild(packet.Name)
		unreliableRemoteEvent.OnClientEvent:Connect(function(...)
			packet.OnClientEvent:Fire(packet:Deserialize(...))
		end)

		packet.Fire = function(packet, ...)
			unreliableRemoteEvent:FireServer(packet:Serialize(...))
		end
	end
end

return unreliablePackets