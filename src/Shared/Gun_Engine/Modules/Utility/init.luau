--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services
local Players = game:GetService("Players")

-- Modules
local GunEngine = script.Parent.Parent

local Modules = GunEngine:WaitForChild("Modules")
local Assets = GunEngine:WaitForChild("Assets")

-- Variables
local WeaponSettings = Modules:WaitForChild("WeaponSettings")
local ViewmodelFolder = GunEngine:WaitForChild("Viewmodels")
local ModelAssets = Assets:WaitForChild("Models")

local WeaponAnimations = ViewmodelFolder.Animations
local Viewmodels = ViewmodelFolder.Models

local ProjectileFolder = ModelAssets:WaitForChild("Projectiles")

local GenericProjectiles = ProjectileFolder:WaitForChild("Generic")
local CustomProjectiles = ProjectileFolder:WaitForChild("Custom")
local AmmunitionModels = ModelAssets:WaitForChild("Ammunitions")

-- Module
local Module = {}
Module.__index = Module

-- Types

type Randomized = number | {
	min : number | {number},
	max : number | {number},
	Float: boolean?
}

--[[
	return the weapon setting ModuleScript if it exist
	
	@params Name : string
	@return weaponSetting : Instance
	@return nil : nil
	
	@usage
	local weaponSetting = Module.FindWeaponSetting("M4A1")
]]
function Module.FindWeaponSetting(Name : string, verbose : boolean?)
	local weaponSetting = WeaponSettings:FindFirstChild(Name)
	if weaponSetting then
		return weaponSetting
	else
		for i, v in WeaponSettings:GetDescendants() do
			if v.Name == Name then
				return v
			end
		end
	end
	if verbose then warn(Name .. " Does not have WeaponSetting") end
end

--[[
	return the weapon animation ModuleScript if it exist
	
	@params Name : string
	@return weaponAnimation : Instance
	@return nil : nil
	
	@usage
	local weaponAnimation = Module.FindWeaponAnimation("M4A1")
	print(weaponAnimation)
]]
function Module.FindWeaponAnimation(Name : string, verbose : boolean?)
	local weaponAnimation = WeaponAnimations:FindFirstChild(Name)
	if weaponAnimation then
		return weaponAnimation
	else
		for i, v in weaponAnimation:GetDescendants() do
			if v.Name == Name then
				return v
			end
		end
	end
	if verbose then warn(Name .. " Does not have WeaponAnimation") end
end

--[[
	return the viewmodel of the weapon if it exist
	
	@params Name : string
	@return viewmodel : Instance
	@return nil : nil
	
	@usage
	local viewmodel = Module.FindViewmodel("M4A1")
	print(viewmodel)
]]
function Module.FindViewmodel(Name : string, verbose : boolean?)
	local viewmodel = Viewmodels:FindFirstChild(Name)
	if viewmodel then
		return viewmodel
	else
		for i, v in Viewmodels:GetDescendants() do
			if v.Name == Name then
				return v
			end
		end
	end
	if verbose then warn(Name .. " Does not have viewmodel") end
end

--[[
	returns the gunmodel of the viewmodel
	
	@params Name : string
	@return gunmodel : Instance
	@return nil : nil
	
	@usage
	local gunmodel = Module.FindGunmodel("M4A1")
	print(gunmodel)
	-- You can rename gunmodel Name to "gunmodel" as Generic name for searching
]]
function Module.FindGunmodel(Name : string, verbose : boolean?)
	local viewmodel : Instance? = Module.FindViewmodel(Name)
	local gunmodel = nil
	if viewmodel then
		for i, v in viewmodel:GetDescendants() do
			if v.Name == Name or v.Name == "gunmodel" then
				gunmodel = v
				break
			end
		end
	end
	if not gunmodel and verbose then warn(Name .. " Does not have gunmodel") end
	return gunmodel
end

--[[
	Checks if the weapon is valid
	
	@params Name : string
	@return true : boolean
	@return false : boolean
	
	@usage
	local isValid = Module.IsVaildWeapon("M4A1")
	print(isValid) 
	
	Weapon must have have Viewmodel, WeaponAnimation, WeaponSetting, GunModel 
	or else will return false
]]
function Module.IsVaildWeapon(Name : string, verbose : boolean?)
	local weaponSetting = Module.FindWeaponSetting(Name, verbose)
	local weaponAnimation = Module.FindWeaponAnimation(Name, verbose)
	local gunmodel = Module.FindGunmodel(Name, verbose)
	return (weaponSetting and weaponAnimation and gunmodel) and true or false
end

function Module.BindCollidesModel(Model : Model, CanCollide : bool)
	for i, v in Model:GetDescendants() do
		if v:IsA("BasePart") and v.CanCollide ~= CanCollide then
			v.CanCollide = CanCollide
		end
	end
end

function Module.BindAnchorModel(Model : Model, Anchored : bool)
	for i, v in Model:GetDescendants() do
		if v:IsA("BasePart") and v.Anchored ~= Anchored then
			v.Anchored = Anchored
		end
	end
end

function Module.Weld(p1, p2, c0, c1, Parent)
	local w = Instance.new("Motor6D", p1)
	w.Part0 = p1
	w.Part1 = p2
	w.Name = p2.Name
	w.C0 = c0 or p1.CFrame:inverse() * p2.CFrame
	w.C1 = c1 or CFrame.new()
	if Parent then w.Parent = Parent else w.Parent = p1.Parent end
	return w
end

function Module.WeldComplex(x,y,Name)
	local W = Instance.new("Motor6D")
	W.Name = Name
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
	return W
end

function Module.TableMerge(OriginTable : {[string] : any}, ModTable : {[string] : any})
	for k, v in ModTable do
		OriginTable[k] = v
	end
end

function Module.FindAmmunitionModel(Name : string, verbose : boolean?)
	local model = AmmunitionModels:FindFirstChild(Name)
	if not model and verbose then warn(Name .. " Is not a vaild Ammunition") end
	return model
end

function Module.FindProjectileModel(Name : string)
	local Projectile = nil
	for i,v : Instance in GenericProjectiles:GetDescendants() do
		if (not v:IsA("Folder") and v:IsA("BasePart") or v:IsA("Model")) and v.Name == Name then
			Projectile = v
		end
	end
	if Projectile then return Projectile end
	for i, v : Instance in CustomProjectiles:GetDescendants() do
		if (not v:IsA("Folder") and v:IsA("BasePart") or v:IsA("Model")) and v.Name == Name then
			Projectile = v
		end
	end
	if not Projectile then warn(Name .. " Is not a vaild Projectile") end
	return Projectile
end

function Module.GetRandomizableNumber(t: Randomized)
	if t == nil then
		return
	end

	if type(t) ~= "table" then
		return t
	end

	if t.min == nil or t.max == nil then
		warn("min or max cannot be nil")
		return
	end

	-- pick min value
	local minValue
	if type(t.min) == "table" then
		local i = (#t.min == 1) and 1 or math.random(1, #t.min)
		minValue = t.min[i]
	else
		minValue = t.min
	end

	-- pick max value
	local maxValue
	if type(t.max) == "table" then
		local i = (#t.max == 1) and 1 or math.random(1, #t.max)
		maxValue = t.max[i]
	else
		maxValue = t.max
	end

	-- safety
	if minValue > maxValue then
		minValue, maxValue = maxValue, minValue
	end

	if t.Float == true then
		return math.random() * (maxValue - minValue) + minValue
	else
		return math.random(minValue, maxValue)
	end
end


function Module.SetModelTransparecy(Model :Model, amount : number)
	for i, v : Instance in Model:GetDescendants() do
		if v:IsA("BasePart") then
			v.Transparency = amount
		end
	end
end

return Module