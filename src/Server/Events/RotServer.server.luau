--[[
	- Author : Mawin CK
	- Date : 2024
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")

-- Requires
local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))

-- Events
local RotServer = UnreliablePackets.RotServer
local RotClient = UnreliablePackets.RotClient

local db = {}
local debounce = 1/60

-- Listeners

RotServer.OnServerEvent:Connect(function(player : Player, RightSAngles : CFrame, LeftSAngles : CFrame, NeckAngles : CFrame, Lerping : boolean)
	local Now = os.clock()
	if (Now - (db[player] or 0) < debounce) then
		if RS:IsStudio() then warn("Exceeded RotServer rate limit") end
		return 
	end
	db[player] = Now
	RotClient:Fire(player :: Instance, RightSAngles, LeftSAngles, NeckAngles, Lerping)
end)

Players.PlayerRemoving:Connect(function(player : Player)
	db[player] = nil
end)