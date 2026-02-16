--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")

-- Modules
local Gun_Engine = Rep:WaitForChild("Gun_Engine")
local Modules = Gun_Engine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")

local Types = Modules.Types

-- Requires
local Packet = require(Libraries.Packet)
local UnreliablePackets = require(Libraries.UnreliablePackets)
local Utility = require(Modules.Utility)
local WeaponTypes = require(Types.WeaponTypes)

-- Variables

-- Events

-- ARGS : {}

local HolsterServer = Packet("HolsterServer", Packet.String, Packet.Boolean8)
local HolsterClient = Packet("HolsterClient", Packet.Instance, Packet.String, Packet.Boolean8)
--local HolsterEvent = Packet("HolsterEvent", Packet.String, Packet.Boolean8)

-- DB

local db = {}
local debounce = 0.1

-- Functions

--[[local function Holster(Name : string, Parent : Instance, Part1 : BasePart)
	print("NAME : " .. Name)
	local dupe = Parent:FindFirstChild(Name)
	if dupe then print("A") dupe:Destroy() end
	if Name ~= "" and not Utility.IsVaildWeapon(Name) then return end
	print("B")
	local weaponSetting : WeaponTypes.WeaponSetting = require(Utility.FindWeaponSetting(Name))
	local holsterClone = Utility.FindGunmodel(Name):Clone()
	holsterClone.Name = Name
	
	Utility.BindCollidesModel(holsterClone, false)
	Utility.BindAnchorModel(holsterClone, false)

	local target = holsterClone.PrimaryPart or holsterClone.Handle
	if target then
		Utility.Weld( 
			Part1,
			target,
			weaponSetting.HolsterCFrame,
			weaponSetting.HolsterAngles
		)
		holsterClone.Parent = Parent
		return
	else
		warn("No PrimaryPart or Handle found in holsterClone:", Name)
		holsterClone:Destroy()
		return
	end
end]]

-- Listeners

--[[HolsterServer.OnServerEvent:Connect(function(player : Player, Name : string, IsEquipped : boolean)
	HolsterClient:Fire(player, Name, IsEquipped)
end)]]

--[[UnreliablePackets.HolsterServer.OnServerEvent:Connect(function(player : player, Name : string, IsEquipped : boolean)
	UnreliablePackets.HolsterClient:Fire(player, Name, IsEquipped)
end)]]

--[[UnreliablePackets.HolsterEvent.OnServerEvent:Connect(function(player : Player, Name : string, IsEquipped : boolean)
	--print(QUEUE[player.UserId])
	local targetCharacter = player.Character
	if not targetCharacter then return end

	local playerRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	local holsterFolder = targetCharacter:FindFirstChild("Holsters")

	if not holsterFolder then
		holsterFolder = Instance.new("Folder")
		holsterFolder.Name = "Holsters"
		holsterFolder.Parent = targetCharacter
	end
	

	local holster = holsterFolder:FindFirstChild(Name)
	if holster then
		holster:Destroy()
		if not IsEquipped then
			Holster(Name, holsterFolder, playerRoot)
		end
		return
	end

	for i, v in player.Backpack:GetChildren() do
		Holster(v.Name, holsterFolder, playerRoot)
	end
	
end)]]

HolsterServer.OnServerEvent:Connect(function(player : Player, Name : string, IsEquipped : boolean)
	local Now = os.clock()
	if (Now - (db[player] or 0) < debounce) then
		if RS:IsStudio() then warn("Exceeded HolsterServer rate limit") end
		return 
	end
	db[player] = Now
	HolsterClient:Fire(player, Name, IsEquipped)
end)

Players.PlayerRemoving:Connect(function(player : Player)
	db[player] = nil
end)