--[[
	- Author : Mawin_CK
	- Date : 2026
]]

-- Services
local StarterGui = game:GetService("StarterGui")
local RS = game:GetService("RunService")

-- Modules
local GunEngine = script.Parent.Parent.Parent
local Modules = GunEngine:WaitForChild("Modules")
local Types = Modules:WaitForChild("Types")

-- Requires
local WeaponTypes = require(Types:WaitForChild("WeaponTypes"))
local AnimControllerM = require(Modules:WaitForChild("AnimationController"))
local WeaponObjM = require(Modules:WaitForChild("Objects").Weapon)
local UtilM = require(Modules:WaitForChild("Utility"))

-- Variables
local ViewmodelAnimator : AnimControllerM.AnimationController = nil
local WeaponObject : WeaponObjM.WeaponObject = nil
local Setting : WeaponTypes.WeaponSetting = nil

-- StateMachine
local StateMachineF = Modules:WaitForChild("FPS_StateMachine")

-- Local functions
local function PlaySound(sound : string | Instance)
	-- This is shit
	if sound then
		if typeof(sound) == "string" then
			local sound = Instance.new("Sound")
			sound.SoundId = sound
			sound.Parent = script
			sound.Ended:Connect(function()
				sound:Destroy()
			end)
			sound:Play()
		end
		if typeof(sound) == "Instance" and sound:IsA("Sound") then
			sound:Play()
		end
	end
end

-- EventController

local module = {}

function module.Start(
	newAnimController : AnimControllerM.AnimationController,
	newWeaponObj : WeaponObjM.WeaponObject
)
	ViewmodelAnimator = newAnimController
	WeaponObject = newWeaponObj
	Setting = WeaponObject.Setting

	-- Checking shit
	
	if not newWeaponObj then
		warn("No WeaponObject, MUST HAVE")
		return
	end

	if not Setting then
		warn("No Setting, MUST HAVE")
	end

	if not ViewmodelAnimator then
		warn("No AnimationController that animates the Viewmodel, MUST HAVE")
	end

	-- Getting the animations, Shit

	local EquippingAnim = ViewmodelAnimator.Animations.Equip
	local IdleAnim = ViewmodelAnimator.Animations.Idle
	
	local AnimSettings = Setting.AnimationSettings

	-- Playing Equipping animation

	if EquippingAnim then
		print("Equpping animation")
		EquippingAnim.KeyframeReached:Once(function(keyframe : string)
			if string.lower(keyframe) == "equip" or string.lower(keyframe) == "equipsound" then
				PlaySound(Setting.SFX.Equip)
			end
		end)
		
		local EquipSetting = AnimSettings.Equip
		
		ViewmodelAnimator:Play("Equip",
			UtilM.GetRandomizableNumber(EquipSetting.Speed),
			UtilM.GetRandomizableNumber(EquipSetting.FadeTime),
			UtilM.GetRandomizableNumber(EquipSetting.Weight)
		)
		EquippingAnim.Stopped:Wait()
	else
		if RS:IsStudio() then
			warn("No equip animation")
		end
	end

	-- Play IdleAnim
	--- Does anyone give a fuck if IdleAnim doesn't exist, Maybe?

	if IdleAnim then
		
		local IdleSetting = AnimSettings.Idle
		
		ViewmodelAnimator:Play(
			"Idle", 
			UtilM.GetRandomizableNumber(IdleSetting.Speed), 
			UtilM.GetRandomizableNumber(IdleSetting.FadeTime), 
			UtilM.GetRandomizableNumber(IdleSetting.Weight)
		)
	else
		error("No Idle animation, MUST HAVE")
		return
	end

	-- Some hardcoding shit
	--- Setting Attributes

	StateMachineF:SetAttribute("CanShoot", true)
	StateMachineF:SetAttribute("CanAim", true)
	StateMachineF:SetAttribute("Equipped", true)
	
	-- Set up connections

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end

function module.Stop()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	local UnequipAnim = ViewmodelAnimator and ViewmodelAnimator.Animations.Unequip

	if UnequipAnim then
		UnequipAnim.KeyframeReached:Connect(function(keyframe : string)
			if string.lower(keyframe) == "unequipsound" then
				PlaySound(Setting.SFX.Unequip)
			end
		end)
		
		local UnequipSetting = Setting.AnimationSettings.Unequip

		ViewmodelAnimator:Play("Unequip",
			UtilM.GetRandomizableNumber(UnequipSetting.Speed),
			UtilM.GetRandomizableNumber(UnequipSetting.FadeTime),
			UtilM.GetRandomizableNumber(UnequipSetting.Weight)
		)
		UnequipAnim.Stopped:Wait()
	end

	ViewmodelAnimator = nil
	Setting = nil
	WeaponObject = nil
	
	-- Event setup

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end

return module
