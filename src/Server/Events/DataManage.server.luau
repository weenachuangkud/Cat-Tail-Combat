--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Services
local Players = game:GetService("Players")	
local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Utility = require(Modules:WaitForChild("Utility"))

-- Variables
local playerWeaponDatas : {[Player] : any} = {}

-- Listeners

Players.PlayerAdded:Connect(function(player : Player)
	player.CharacterAdded:Connect(function(character : Model)
		-- Tags
		character:AddTag("BloodFliter")
		-- Loads
		for i, v in player.Backpack:GetChildren() do
			local weaponSetting = Utility.FindWeaponSetting(v.Name)
			if weaponSetting then 
				--print(weaponSetting.Name)
				playerWeaponDatas[v] = require(weaponSetting)
			end
		end
		
		local tool = character:FindFirstChildOfClass("Tool")
		local weaponSetting = Utility.FindWeaponSetting(tool and tool.Name or "")
		if weaponSetting then
			playerWeaponDatas[tool] = require(weaponSetting)
		end
	end)
	
	player.CharacterRemoving:Connect(function(character : Model)
		local tool = character:FindFirstChildOfClass("Tool")
		if tool and playerWeaponDatas[tool] then
			-- Weapon Drop thingy
			print("Oh you die? haha noob")
		end
		-- Weapon clear thingy
		for i, v in player.Backpack:GetChildren() do
			if playerWeaponDatas[tool] then
				playerWeaponDatas[tool] = nil
			end
		end
		
	end)
	-- TODO : Ragdoll thingy
	-- TODO : Loadout thingy
	-- TODO : More thingy, idk :P
end)

Players.PlayerRemoving:Connect(function(player : Player)
	playerWeaponDatas[player] = nil
end)