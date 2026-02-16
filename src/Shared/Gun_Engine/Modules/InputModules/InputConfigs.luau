--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

--!strict

type VaildInputs = Enum.UserInputType | Enum.KeyCode

export type InputConfig = {
	Trigger : {VaildInputs} | VaildInputs,
	OnInputBegan : ((InputObject) -> ())?,
	OnInputEnded : ((InputObject) -> ())?,
	MobileButton : (TextButton | ImageButton)?
}

export type InputConfigs = {
	IsMobile : boolean,
	[string] : InputConfig
}

local InputConfigs : InputConfigs = {
	IsMobile = false,
	["Running"] = {
		Trigger = Enum.KeyCode.LeftShift
	},
	["Inspect"] = {
		Trigger = Enum.KeyCode.H
	},
	["Reload"] = {
		Trigger = Enum.KeyCode.R
	},
	["Aim"] = {
		Trigger = Enum.UserInputType.MouseButton2
	},
	["Shoot"] = {
		Trigger = Enum.UserInputType.MouseButton1
	},
	["Steady"] = {
		Trigger = Enum.KeyCode.T
	},
	["Focus"] = {
		Trigger = Enum.KeyCode.Y
	},
	["ZeroIncrement"] = {
		Trigger = Enum.KeyCode.LeftBracket
	},
	["ZeroDecrement"] = {
		Trigger = Enum.KeyCode.RightBracket
	},
	["HighReady"] = {
		Trigger = Enum.KeyCode.U
	},
	["LowReady"] = {
		Trigger = Enum.KeyCode.J
	}
}

return InputConfigs