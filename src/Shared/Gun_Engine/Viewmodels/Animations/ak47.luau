--[[
	copyright (c) Mawin_CK 2025 
]]

-- ...

local animation : {[string] : any} = {
	Equip = script:WaitForChild("equipAk47"),
	Idle = script:WaitForChild("idleAk47"),
	Unequip = script:WaitForChild("unequipAk47"),
	
	HighReadyIn = script:WaitForChild("HighReadyin_ak47"),
	HighReadyOut = script:WaitForChild("HighReadyOut_ak47"),
	HighReadyIdle = script:WaitForChild("HighReadyIdle_ak47"),
	
	LowReadyIn = script:WaitForChild("LowReadyIn_ak47"),
	LowReadyOut = script:WaitForChild("LowReadyOut_ak47"),
	LowReadyIdle = script:WaitForChild("LowReadyIdle_ak47")
}

return animation