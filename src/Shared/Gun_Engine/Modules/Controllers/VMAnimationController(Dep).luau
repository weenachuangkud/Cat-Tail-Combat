--[[
	- Author : Mawin CK
	- Date : 2025
]]

-- Services
local StarterGui = game:GetService("StarterGui")
local RS = game:GetService("RunService")

-- Modules
local Modules = script.Parent.Parent
local InputModules = Modules:WaitForChild("InputModules")
local Libraries = Modules:WaitForChild("Libraries")

-- Requires
local Types = require(Modules:WaitForChild("Types").WeaponTypes)
local WeaponObj = require(Modules:WaitForChild("Objects").Weapon)
local AnimController = require(Modules:WaitForChild("AnimationController"))
local TroveModule = require(Libraries:WaitForChild("trove"))

local InputConfigs = require(InputModules.InputConfigs)
local InputService = require(InputModules.InputService)

-- Variables

local ViewmodelAnimator : AnimController.AnimationController = nil
local WeaponObject = nil
local Setting : Types.WeaponSetting = nil

local IsLowReadyPlaying = false
local IsHighReadyPlaying = false

--local trove = TroveModule.new()

-- Local functions

local function PlayEquipSound(weaponSetting : Types.WeaponSetting, Unequip : boolean?)
	-- Okay?, idk who write this
	if not weaponSetting then return end 

	local sound = Unequip and weaponSetting.SFX.Unequip or weaponSetting.SFX.Equip
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

-- StateMachine
local StateMachine = Modules:WaitForChild("FPS_StateMachine")

-- CONSTs
local EQUIP_FADE = 0.25

local HIGH_READY_IN_TIME = 1
local HIGH_READY_OUT_TIME = 1

local LOW_READY_IN_TIME = 1
local LOW_READY_OUT_TIME = 1


-- VMAnimationController

local module = {}

function module.Start(NewWeaponObj : WeaponObj.WeaponObject, AnimController : AnimController.AnimationController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	-- GET THAT SETTING - Mawin CK 2025

	ViewmodelAnimator = AnimController
	WeaponObject = NewWeaponObj
	Setting = WeaponObject.Setting
	
	-- Checking shit
	
	if not Setting then
		warn("No Setting, MUST HAVE")
	end
	
	if not ViewmodelAnimator then
		warn("No AnimationController that animates the Viewmodel, MUST HAVE")
	end
	
	-- Getting the animations, Shit

	local EquippingAnim = ViewmodelAnimator.Animations.Equip
	local IdleAnim = ViewmodelAnimator.Animations.Idle

		
	-- Playing Equipping animation

	if EquippingAnim then
		print("Equpping animation")
		EquippingAnim.KeyframeReached:Once(function(keyframe : string)
			if string.lower(keyframe) == "equip" or string.lower(keyframe) == "equipsound" then
				PlayEquipSound(Setting)
			end
		end)
		ViewmodelAnimator:Play("Equip",Setting.EquipTime)
		EquippingAnim.Stopped:Wait()
	else
		if RS:IsStudio() then
			warn("No equip animation")
		end
	end
	
	-- Play IdleAnim
	--- Does anyone give a fuck if IdleAnim doesn't exist, Maybe?
	
	if IdleAnim then
		ViewmodelAnimator:Play("Idle", Setting.EquipTime, EQUIP_FADE, 1)
	else
		error("No Idle animation, MUST HAVE")
		return
	end
	
	-- Some hardcoding shit

	StateMachine:SetAttribute("CanShoot", true)
	StateMachine:SetAttribute("CanAim", true)
	StateMachine:SetAttribute("Equipped", true)

	--StateMachine:SetAttribute("CanHighReady", Setting.CanHighReady or false)
	--StateMachine:SetAttribute("CanLowReady", Setting.CanLowReady or false)
	
	-- HighReady and LowReady shit
	-- TODO : Fix this shit, HRLR, Not working shit - Mawin_CK
	-- TODO : Who made this mess. And magic numbers
	--- OH SHIT, BUGS
	
	--[[local HighReadyOutAnim = ViewmodelAnimator.Animations.HighReadyOut
	local HighReadyInAnim = ViewmodelAnimator.Animations.HighReadyIn
	local HighReadyIdle = ViewmodelAnimator.Animations.HighReadyIdle
	
	local LowReadyOutAnim = ViewmodelAnimator.Animations.LowReadyOut
	local LowReadyInAnim = ViewmodelAnimator.Animations.LowReadyIn
	local LowReadyIdle = ViewmodelAnimator.Animations.LowReadyIdle
	
	local CanHRLR_Action = true
	
	local function enterHighReady()
		if not StateMachine:GetAttribute("CanHighReady") then return end
		if StateMachine:GetAttribute("IsAiming") then return end
		
		LowReadyIdle:Stop()
		LowReadyInAnim:Stop()
		LowReadyOutAnim:Stop()
		
		ViewmodelAnimator:Stop("Idle", 0.1)

		if HighReadyInAnim then
			CanHRLR_Action = false
			ViewmodelAnimator:Play("HighReadyIn", Setting.HighReadyInTime or HIGH_READY_IN_TIME)
			HighReadyInAnim.Stopped:Wait()
			CanHRLR_Action = true
		end
		
		if not IdleAnim.IsPlaying then
			ViewmodelAnimator:Play("HighReadyIdle", 0.2, 0.2, 1)
		end
		StateMachine:SetAttribute("CanShoot", false)
	end
	
	local function exitHighReady()
		if not HighReadyIdle then return end
		ViewmodelAnimator:Stop("HighReadyIdle", 0.1)

		if HighReadyOutAnim then
			CanHRLR_Action = false
			ViewmodelAnimator:Play("HighReadyOut", Setting.HighReadyOutTime or HIGH_READY_OUT_TIME)
			HighReadyOutAnim.Stopped:Wait()
			CanHRLR_Action = true
		end

		-- FUCK
		if not StateMachine:GetAttribute("IsLowReady") then
			if not HighReadyIdle.IsPlaying then
				ViewmodelAnimator:Play("Idle", 0.2, 0.2, 1)
			end
			StateMachine:SetAttribute("CanShoot", true)
		end
	end
	
	local function enterLowReady()
		if not StateMachine:GetAttribute("CanLowReady") then return end
		if StateMachine:GetAttribute("IsAiming") then return end
		
		HighReadyIdle:Stop()
		HighReadyInAnim:Stop()
		HighReadyOutAnim:Stop()
		
		
		ViewmodelAnimator:Stop("Idle", 0.1)
		
		
		if LowReadyInAnim then
			CanHRLR_Action = false
			ViewmodelAnimator:Play("LowReadyIn", Setting.LowReadyInTime or LOW_READY_IN_TIME)
			LowReadyInAnim.Stopped:Wait()
			CanHRLR_Action = true
		end
		
		if not IdleAnim.IsPlaying then
			ViewmodelAnimator:Play("LowReadyIdle", 0.2, 0.2, 1)
		end
		StateMachine:SetAttribute("CanShoot", false)
	end
	
	local function exitLowReady()
		if not LowReadyIdle then return end
		ViewmodelAnimator:Stop("LowReadyIdle", 0.1)

		if LowReadyOutAnim then
			CanHRLR_Action = false
			ViewmodelAnimator:Play("LowReadyOut", Setting.LowReadyOutTime or LOW_READY_OUT_TIME) -- FIXED TYPO
			LowReadyOutAnim.Stopped:Wait()
			CanHRLR_Action = true
		end

		if not StateMachine:GetAttribute("IsHighReady") then
			if not LowReadyIdle.IsPlaying then
				ViewmodelAnimator:Play("Idle", 0.2, 0.2, 1)
			end
			StateMachine:SetAttribute("CanShoot", true)
		end
	end
	
	if Setting.CanHighReady then
		
		if not HighReadyOutAnim and RS:IsStudio() then
			warn("No HighReadyOut animation")
		end
		
		if not HighReadyInAnim and RS:IsStudio() then
			warn("No HighReadyIn animation")
		end
		
		if not HighReadyIdle and RS:IsStudio() then
			warn("No HighReadyIdle animation, MUST HAVE")
			return
		end
		
		trove:Add(StateMachine:GetAttributeChangedSignal("IsHighReady"):Connect(function()
			local isHR = StateMachine:GetAttribute("IsHighReady")
			local isLR = StateMachine:GetAttribute("IsLowReady")
			
			
			-- HAHAHA
			if isHR and isLR then
				StateMachine:SetAttribute("IsLowReady", false) -- wut
			end
			
			if not CanHRLR_Action then
				return 
			end

			if isHR then
				enterHighReady()
			else
				exitHighReady()
			end
		end))
	end

	if Setting.CanLowReady then
		
		if not LowReadyOutAnim and RS:IsStudio() then
			warn("No LowReadyOut animation")
		end
		
		if not LowReadyInAnim and RS:IsStudio() then
			warn("No LowReadyIn animation")
		end
		
		if not LowReadyIdle and RS:IsStudio() then
			warn("No LowReadyIdle animation, MUST HAVE")
			return
		end
		
		trove:Add(StateMachine:GetAttributeChangedSignal("IsLowReady"):Connect(function()
			local isHR = StateMachine:GetAttribute("IsHighReady")
			local isLR = StateMachine:GetAttribute("IsLowReady")
			
			
			if isHR and isLR then
				StateMachine:SetAttribute("IsHighReady", false) -- force exit, MOM
			end
			
			if not CanHRLR_Action then return end

			if isLR then
				enterLowReady()
			else
				exitLowReady()
			end
		end))
	end]]

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end

function module.Stop()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	local UnequipAnim = ViewmodelAnimator and ViewmodelAnimator.Animations.Unequip
	
	if UnequipAnim then
		UnequipAnim.KeyframeReached:Connect(function(keyframe : string)
			--[[if string.lower(keyframe) == "unequipped" then
				local viewmodel = WeaponObject.Viewmodel
				if viewmodel then
					local Arms = viewmodel:WaitForChild("arms")
					Utility.SetModelTransparecy(Arms, 1)
				end
			end]]
			if string.lower(keyframe) == "unequipsound" then
				PlayEquipSound(Setting, true)
			end
		end)

		ViewmodelAnimator:Play("Unequip", Setting.UnequipTime)
		UnequipAnim.Stopped:Wait()
	end
	
	ViewmodelAnimator = nil
	Setting = nil
	WeaponObject = nil

	--trove:Destroy()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end

return module
