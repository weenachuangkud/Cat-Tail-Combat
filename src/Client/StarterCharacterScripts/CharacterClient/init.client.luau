--[[
	- Author : Mawin CK
	- Date : 11/03/2025
	
	NOTE :
	- StateMachine : Behavior of the weapon
	- FPS_Animator : Animator for FPS weapon
	- WeaponObject : Object contains weaponSetting and viewmodel
]]

--[[
-- Services
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--local CAS = game:GetService("ContextActionService")
--local StarterGui = game:GetService("StarterGui")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Objects = Modules:WaitForChild("Objects")
local InputModules = Modules:WaitForChild("InputModules")

local Libraries = Modules:WaitForChild("Libraries")

local Configs = Modules:WaitForChild("Configs")


-- Requires
local WeaponObject = require(Objects:WaitForChild("Weapon"))
local Utility = require(Modules:WaitForChild("Utility"))
local Packet = require(Libraries:WaitForChild("Packet"))
--local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))
local RobloxStateMachine = require(Libraries:WaitForChild("RobloxStateMachine"))
local AnimController = require(Modules:WaitForChild("AnimationController"))

local InputService = require(InputModules:WaitForChild("InputService"))
local InputConfigs = require(InputModules:WaitForChild("InputConfigs"))

local GameRules = require(Configs:WaitForChild("GameRules"))

--- Events

-- NOTE : ONLY ACCPET : BOOLEAN AS TRUE
-- THIS MEAN IF YOU SET IT TO FALSE IT WILL LOOP THROUGH NO MATTER WHAT
local HolsterServer = Packet("HolsterServer", Packet.String, Packet.Boolean8)
--local HolsterEvent = Packet("HolsterEvent", Packet.String, Packet.Boolean8)

--- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid") :: Humanoid

local mouse = player:GetMouse()

-- TODO : Delete this after you finish the remake
--local Animator = character.Humanoid:WaitForChild("Animator")

-- Actor
local ViewmodelRender = script.Parent.Actors:WaitForChild("Viewmodel").ViewmodelRender:GetActor()

-- CONSTs


-- Check

if humanoid then
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("Please use R6 character")
		return
	end
end


-- StateMachine

local StateMachine = Modules:WaitForChild("FPS_StateMachine")
local StateMachineController = require(StateMachine:WaitForChild("StateMachineController"))

local FPS_StateMachine = nil
local Current_FPS_Animator : AnimationController  = nil
local CurrentWeaponObject : WeaponObject = nil

-- Initialize

humanoid.WalkSpeed = GameRules.WalkSpeed


-- Private functions


local function CleanUp()
	-- we will have to manaully clean up
	-- NOTE : WE CANNOT USE TROVE FOR THIS
	if FPS_StateMachine then 
		print("Stopping StateMachine..")
		FPS_StateMachine:Destroy()
		FPS_StateMachine = nil
	end
	if CurrentWeaponObject then
		CurrentWeaponObject:Destroy()
		CurrentWeaponObject = nil
	end
	if Current_FPS_Animator then
		Current_FPS_Animator:Destroy()
		Current_FPS_Animator = nil
	end
end

local function ChangeArms(Arms)
	local leftarm = Arms["Left Arm"]
	local rightarm = Arms["Right Arm"]
	
	if not leftarm or not rightarm then return end
	
	leftarm.Color = character["Left Arm"].Color
	rightarm.Color = character["Right Arm"].Color
	
	-- TODO : remake this
	local Shirt = character:FindFirstChildOfClass("Shirt")
	local bodyColor = character["Body Colors"]:Clone()
	local humanoidClone = humanoid:Clone()
	
	humanoidClone:ClearAllChildren()
	humanoidClone.Parent = Arms
	bodyColor.Parent = Arms
	if Shirt then
		local Shirtclone = Shirt:Clone()
		Shirtclone.Parent = Arms
	end
	
end

local function setup(Name : string)
	CurrentWeaponObject = WeaponObject.new(Name)
	
	local viewmodel = CurrentWeaponObject.Viewmodel
	if not viewmodel.AnimationController then
		local newAnimationController = Instance.new("AnimationController")
		newAnimationController.Parent = viewmodel
	end
	
	Current_FPS_Animator = AnimController.new(Name, viewmodel.AnimationController.Animator)
	
	-- Checks
	if not Utility.IsVaildWeapon(Name) then return end
	
	-- Loading
	ChangeArms(viewmodel.arms)
	HolsterServer:Fire(Name, true)
	
	-- Starting StateMachine
	print("Starting StateMachine..")
	FPS_StateMachine  = RobloxStateMachine.new("Idle",
		RobloxStateMachine:LoadDirectory(StateMachine.States),
		{
			WeaponObject = CurrentWeaponObject,
			AnimController = Current_FPS_Animator,
			Tool = character:FindFirstChildOfClass("Tool")
		}
	)
	
	-- Bindings
	StateMachineController.Start()
	-- Render Viewmodel and Things
	ViewmodelRender:SendMessage("FPS_State", true, CurrentWeaponObject)
end

local function unsetup()
	-- CleanUp
	CleanUp()
	StateMachineController.Stop()
	
	-- SetAttributes
	StateMachine:SetAttribute("CanShoot", false)
	StateMachine:SetAttribute("CanReload", false)
	StateMachine:SetAttribute("CanInspect", false)
	StateMachine:SetAttribute("CanHighReady", false)
	StateMachine:SetAttribute("CanLowReady", false)
	
	StateMachine:SetAttribute("IsLowReady", false)
	StateMachine:SetAttribute("IsHighReady", false)
	StateMachine:SetAttribute("IsAiming", false)
	StateMachine:SetAttribute("IsInspecting", false)
	StateMachine:SetAttribute("IsReloading", false)
	StateMachine:SetAttribute("IsAiming", false)
	StateMachine:SetAttribute("IsShooting", false)
	
	StateMachine:SetAttribute("Equipped", false)
	
	-- Render
	ViewmodelRender:SendMessage("FPS_State", false)
end

-- Loading
HolsterServer:Fire("", false)

--- Listeners

character.ChildAdded:Connect(function(child : Instance)
	if not child:IsA("Tool") then return end
	local Name = child.Name
	if not Utility.IsVaildWeapon(Name) then return end
	--[[CurrentWeaponObject = WeaponObject.new(gunName)
	Current_FPS_Animator = FPS_Animator.new(gunName, Animator)
	==
	local viewmodel = CurrentWeaponObject.Viewmodel
	local gunmodel = nil
	
	-- check viewmodel
	if viewmodel then
		local Arms = viewmodel.arms
		ChangeArms(Arms)
		
		for i, v in pairs(viewmodel:GetDescendants()) do
			if v.Name == gunName then
				gunmodel = v
				break
			end
		end
		if not gunmodel then warn("Viewmodel does not have gun model") end
	else
		return
	end
	
	-- Start FPS State Machine
	print("Starting StateMachine..")
	player.CameraMaxZoomDistance = MAX_ZOOM_DIST
	FPS_StateMachine = RobloxStateMachine.new("Idle",
		RobloxStateMachine:LoadDirectory(StateMachine.States),
		{
			WeaponObject = CurrentWeaponObject,
			FPS_Animator = Current_FPS_Animator
		}
	)
	
	-- Render Viewmodel and things
	ClientRender:SendMessage("FPS_State", true, CurrentWeaponObject)
	
	-- i like using setup :P
	setup(Name)
end)

character.ChildRemoved:Connect(function(child : Instance)
	if not (child or child:IsA("Instance")) then return end
	local Name = child.Name
	if not Utility.IsVaildWeapon(Name) then return end
	HolsterServer:Fire(Name, false)
	unsetup()
end)

humanoid.Died:Connect(function()
	unsetup()
end)

--- Input setup

---> Functions for setup

local function IsHRLR()
	return StateMachine:GetAttribute("IsLowReady") or StateMachine:GetAttribute("IsHighReady")
end

local function CanRun()
	if not StateMachine:GetAttribute("CanRun") then return false end
	if not StateMachine:GetAttribute("IsReloading") then return false end
end

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
end

InputConfigs.Aim.OnInputEnded = function()
	StateMachine:SetAttribute("IsAiming", false)
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

---> HighReady

InputConfigs.HighReady.OnInputBegan = function()
	if not StateMachine:GetAttribute("CanHighReady") then return end
	if StateMachine:GetAttribute("IsLowReady") then
		StateMachine:SetAttribute("IsLowReady", false)
		return
	end
	
	StateMachine:SetAttribute("IsHighReady", not StateMachine:GetAttribute("IsHighReady"))
end

---> LowReady

InputConfigs.LowReady.OnInputBegan = function()
	if not StateMachine:GetAttribute("CanLowReady") then return end
	if StateMachine:GetAttribute("IsHighReadyReady") then
		StateMachine:SetAttribute("IsHighReady", false)
		return
	end
	
	StateMachine:SetAttribute("IsLowReady", not StateMachine:GetAttribute("IsLowReady"))
end

-- Bindings
InputService.Bind("Running", InputConfigs.Running)
InputService.Bind("Shoot", InputConfigs.Shoot)
InputService.Bind("Aim", InputConfigs.Aim)
InputService.Bind("Steady", InputConfigs.Steady)
InputService.Bind("Focus", InputConfigs.Focus)
InputService.Bind("LowReady", InputConfigs.LowReady)
InputService.Bind("HighReady", InputConfigs.HighReady)]]

local ViewmodelManager = require(script:WaitForChild("ViewmodelManager"))

ViewmodelManager.Init()

task.defer(ViewmodelManager.Start)