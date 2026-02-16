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

local Objects = Modules:WaitForChild("Objects")
local InputModules = Modules:WaitForChild("InputModules")
local Controllers = Modules:WaitForChild("Controllers")

local Libraries = Modules:WaitForChild("Libraries")

local Configs = Modules:WaitForChild("Configs")

-- Requires
local WeaponObject = require(Objects:WaitForChild("Weapon"))
local Utility = require(Modules:WaitForChild("Utility"))
local Packet = require(Libraries:WaitForChild("Packet"))
local RobloxStateMachine = require(Libraries:WaitForChild("RobloxStateMachine"))
local AnimController = require(Modules:WaitForChild("AnimationController"))
local GameRules = require(Configs:WaitForChild("GameRules"))

local InputController = require(Controllers:WaitForChild("InputController"))

-- Events
local HolsterServer = Packet("HolsterServer", Packet.String, Packet.Boolean8)

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid") :: Humanoid

local mouse = player:GetMouse()

local FPS_StateMachine = nil
local ViewmodelAnimator : AnimationController  = nil
local CurrentWeaponObject : WeaponObject = nil

-- Actors

local ViewmodelRender = script.Parent.Parent.Parent.Actors.ViewmodelRender:GetActor()


-- StateMachine

local StateMachine = Modules:WaitForChild("FPS_StateMachine")

-- Local functions

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

-- ViewmodelManager

local module = {}

function module.Init()
	humanoid.WalkSpeed = GameRules.WalkSpeed
	HolsterServer:Fire("", false)
end

function module.CleanUp()
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
	if ViewmodelAnimator then
		ViewmodelAnimator:Destroy()
		ViewmodelAnimator = nil
	end
end

function module.Setup(Name : string)
	CurrentWeaponObject = WeaponObject.new(Name)

	local viewmodel = CurrentWeaponObject.Viewmodel
	if not viewmodel.AnimationController then
		local newAnimationController = Instance.new("AnimationController")
		newAnimationController.Parent = viewmodel
	end

	ViewmodelAnimator = AnimController.new(Name, viewmodel.AnimationController.Animator)

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
			AnimController = ViewmodelAnimator,
			Tool = character:FindFirstChildOfClass("Tool")
		}
	)

	-- Bindings
	InputController.Start()
	
	-- Render Viewmodel and Things
	ViewmodelRender:SendMessage("FPS_State", true, CurrentWeaponObject)
end

function module.Unsetup(Name : string)
	-- CleanUp
	module.CleanUp()
	InputController.Stop()

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
	
	-- Events
	if Name then
		HolsterServer:Fire(Name, false)
	end
end

return module
