--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")

-- Requires
local Utility = require(Modules:WaitForChild("Utility"))
local Packet = require(Libraries:WaitForChild("Packet"))
--local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))

-- Events
local HolsterClient = Packet("HolsterClient", Packet.Instance, Packet.String, Packet.Boolean8)

-- Variables


-- Functions
local function Holster(Name : string, Parent : Instance, Part1 : BasePart)
	local dupe = Parent:FindFirstChild(Name)
	if dupe then dupe:Destroy() end
	if Name ~= "" and not Utility.IsVaildWeapon(Name) then return end
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

end

-- Listeners

HolsterClient.OnClientEvent:Connect(function(targetPlayer : Player, Name : string, IsEquipped : boolean)
	--print("A")
	local targetCharacter = targetPlayer.Character
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
	
	for i, v in targetPlayer.Backpack:GetChildren() do
		Holster(v.Name, holsterFolder, playerRoot)
	end
end)