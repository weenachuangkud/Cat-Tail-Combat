--!strict
--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services

-- Modules
local GunEngine =  script.Parent.Parent.Parent
local Modules = GunEngine:WaitForChild("Modules")
local Objects = Modules.Objects

local Libraries = Modules:WaitForChild("Libraries")
local Types = Modules:WaitForChild("Types")

-- Requires
local Utility = require(Modules.Utility)
local WeaponTypes = require(Types.WeaponTypes)

local trove = require(Libraries:WaitForChild("trove"))

-- Types

-- Export Types
export type WeaponObject = {
	__index : WeaponObject,
	
	Viewmodel : Model,
	Setting : WeaponTypes.WeaponSetting?,
	_trove : trove.Trove,
	
	new : (Name : string) -> WeaponObject,
	
	Destroy : (self : WeaponObject) -> ()
}

-- Object

local Module = {} :: WeaponObject
Module.__index = Module

function Module.new(Name : string)
	local self = setmetatable({} :: any, Module) :: WeaponObject
	self._trove = trove.new()
	
	local viewmodel : Model = Utility.FindViewmodel(Name)
	if viewmodel then
		viewmodel = viewmodel:Clone()
		Utility.BindCollidesModel(viewmodel, false)
		Utility.BindAnchorModel(viewmodel, false)
		
		-- Basically if the viewmodel has a PrimaryPart and the PrimaryPart has a Motor6D then the PrimaryPart will be anchored
		if viewmodel.PrimaryPart then
			viewmodel.PrimaryPart.Anchored = true
		end
		
		viewmodel.Parent = workspace
	end
	
	self.Viewmodel = viewmodel and self._trove:Add(viewmodel)
	
	-- TODO : Use Server authority to get the setting, after
	self.Setting = require(Utility.FindWeaponSetting(Name)) :: WeaponTypes.WeaponSetting
	if not self.Setting then return self end
	
	local Ammunition = self.Setting.Ammunition
	if Ammunition and typeof(Ammunition) == "string" then
		local AmmunitionModel : Model | BasePart = Utility.FindAmmunitionModel(Ammunition)
		self.Setting.Ammunition = AmmunitionModel
	end
	--Utility.TableMerge(self.Setting, nil)
	return self
end

function Module:Destroy()
	self._trove:Destroy()
	self.Setting = nil
end


return Module