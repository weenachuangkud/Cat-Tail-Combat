--[[
	- Author : Mawin CK
	- Date : 2025
]]

-- Services
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Controllers = Modules:WaitForChild("Controllers")

-- Requires
local InputController = require(Controllers:WaitForChild("InputController"))
local ViewmodelController = require(script:WaitForChild("ViewmodelController"))

local Utility = require(Modules:WaitForChild("Utility"))

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid") :: Humanoid

-- ViewmodelManager

local module = {}

function module.Init()
	InputController.Init()
	ViewmodelController.Init()
	
	task.defer(InputController.Start)
end

function module.Start()
	
	character.ChildAdded:Connect(function(child : Instance)
		if not child:IsA("Tool") then return end
		local Name = child.Name
		if not Utility.IsVaildWeapon(Name) then return end
		
		ViewmodelController.Setup(Name)
	end)
	
	character.ChildRemoved:Connect(function(child : Instance)
		if not (child or child:IsA("Instance")) then return end
		local Name = child.Name
		if not Utility.IsVaildWeapon(Name) then return end
		
		ViewmodelController.Unsetup(Name)
	end)
	
	-- wtf lmao
	humanoid.Died:Connect(function()
		ViewmodelController.Unsetup()
	end)
end

return module