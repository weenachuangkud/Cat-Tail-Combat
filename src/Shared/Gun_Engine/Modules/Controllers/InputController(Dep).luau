--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services
--local Rep = game:GetService("ReplicatedStorage")

-- Modules
local Modules = script.Parent.Parent
local InputModules = Modules:WaitForChild("InputModules")

-- Requires
local InputConfigs = require(InputModules:WaitForChild("InputConfigs"))
local InputService = require(InputModules:WaitForChild("InputService"))

-- StateMachine
local StateMachine = Modules:WaitForChild("FPS_StateMachine")

-- Private variables
local Binds_table = {
	["Inspect"] = InputConfigs.Inspect,
	["Reload"] = InputConfigs.Reload,
	["Shoot"] = InputConfigs.Shoot,
	["Aim"] = InputConfigs.Aim
}

-- Private functions 
local function Binds(bool : boolean)
	if bool then
		for k, v in Binds_table do
			InputService.Bind(k, v)
		end
	else
		for k, v in Binds_table do
			InputService.UnBind(k)
		end
	end
end

-- Controller

local Controller = {}
Controller.Running = false

function Controller.Start()
	if Controller.Running then return end
	Binds(true)
end

function Controller.Stop()
	if not Controller.Running then return end
	Binds(false)
end

return Controller