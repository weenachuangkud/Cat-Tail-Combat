--[[
	- Author : Mawin CK
	- Date : 2025
]]

-- Services
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")

local Modules = GunEngine:WaitForChild("Modules")
local InputModules = Modules:WaitForChild("InputModules")

-- Requires
local InputConfigs = require(InputModules:WaitForChild("InputConfigs"))
local InputService = require(InputModules:WaitForChild("InputService"))

local GameRules = require(Modules:WaitForChild("Configs").GameRules)

-- StateMachine
local StateMachine = Modules:WaitForChild("FPS_StateMachine")


-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid") :: Humanoid

local HRLR_bouncetime = 0.5
local HRLR_bounce = false

-- Local functions


local function IsHRLR()
	return StateMachine:GetAttribute("IsLowReady") or StateMachine:GetAttribute("IsHighReady")
end

local function CanRun()
	if not StateMachine:GetAttribute("CanRun") then return false end
	if not StateMachine:GetAttribute("IsReloading") then return false end
end


-- InputController

local module = {}

-- This is shit code

function module.Init()
	---> Running

	InputConfigs.Running.OnInputBegan = function()
		if not StateMachine:GetAttribute("CanRun") then return end
		StateMachine:SetAttribute("IsSprinting", true)
		humanoid.WalkSpeed = GameRules.RunningSpeed
	end

	InputConfigs.Running.OnInputEnded = function()
		if not StateMachine:GetAttribute("CanRun") then return end
		StateMachine:SetAttribute("IsSprinting", false)
		humanoid.WalkSpeed = GameRules.WalkSpeed
	end

	---> Shoot

	InputConfigs.Shoot.OnInputBegan = function()
		if not StateMachine:GetAttribute("CanShoot") then return end
		StateMachine:SetAttribute("IsShooting", true)
	end

	InputConfigs.Shoot.OnInputEnded = function()
		if not StateMachine:GetAttribute("CanShoot") then return end
		StateMachine:SetAttribute("IsShooting", true)
	end

	---> Aim

	InputConfigs.Aim.OnInputBegan = function()
		if not StateMachine:GetAttribute("CanAim") then return end
		StateMachine:SetAttribute("IsAiming", true)
		
		-- TODO : Fix this shit, HRLR
		--[[print("S HRLR")
		
		print("S2 HRLR")
		print(StateMachine:GetAttribute("CanLowReady"))
		
		StateMachine:GetAttribute("CanLowReady", false)
		StateMachine:GetAttribute("CanHighReady", false)
		
		print("S3 HRLR")
		print(StateMachine:GetAttribute("CanLowReady"))]]
	end

	InputConfigs.Aim.OnInputEnded = function()
		StateMachine:SetAttribute("IsAiming", false)
		
		-- TODO : Fix this shit, HRLR
		--[[print("F HRLR")
		StateMachine:GetAttribute("CanLowReady", true)
		StateMachine:GetAttribute("CanHighReady", true)]]
	end

	---> Inspect

	InputConfigs.Inspect.OnInputBegan = function()
		if not StateMachine:GetAttribute("CanInspect") then return end
		StateMachine:SetAttribute("IsInspecting", not StateMachine:GetAttribute("IsInspecting"))
	end

	---> Steady

	InputConfigs.Steady.OnInputBegan = function()
		local bool = not StateMachine:GetAttribute("IsSteady")
		StateMachine:SetAttribute("IsSteady", bool)
		StateMachine:SetAttribute("CanRun", not bool)
		humanoid.WalkSpeed = bool and GameRules.SteadyWalkSpeed or GameRules.WalkSpeed
	end

	---> Focus

	InputConfigs.Focus.OnInputBegan = function()
		if not StateMachine:GetAttribute("CanFocus") then return end
		StateMachine:SetAttribute("IsFocus", true)
	end

	InputConfigs.Focus.OnInputEnded = function()
		StateMachine:SetAttribute("IsFocus", false)
	end

	-- NOTE : HighReady, LowReady are work in progress
	---> HighReady (Default)

	--[[InputConfigs.HighReady.OnInputBegan = function()
		if HRLR_bounce then return end
		if not StateMachine:GetAttribute("CanHighReady") then return end
		print("HR")
		
		local bool = not StateMachine:GetAttribute("IsHighReady")
		StateMachine:SetAttribute("IsHighReady", bool)
		--StateMachine:SetAttribute("CanLowReady", not bool)
		HRLR_bounce = true
		task.wait(HRLR_bouncetime)
		HRLR_bounce = false
	end]]

	---> LowReady (Default)

	--[[InputConfigs.LowReady.OnInputBegan = function()
		if HRLR_bounce then return end
		if not StateMachine:GetAttribute("CanLowReady") then return end
		print("LR")
		
		local bool = not StateMachine:GetAttribute("IsLowReady")
		StateMachine:SetAttribute("IsLowReady", bool)
		--StateMachine:SetAttribute("CanHighReady", not bool)
		
		HRLR_bounce = true
		task.wait(HRLR_bouncetime)
		HRLR_bounce = false
	end]]
	
end

function module.Start()
	InputService.Bind("Running", InputConfigs.Running)
	InputService.Bind("Shoot", InputConfigs.Shoot)
	InputService.Bind("Aim", InputConfigs.Aim)
	InputService.Bind("Steady", InputConfigs.Steady)
	InputService.Bind("Focus", InputConfigs.Focus)
	InputService.Bind("HighReady", InputConfigs.HighReady)
	InputService.Bind("LowReady", InputConfigs.LowReady)
end

function module.Stop()
	
end

return module
