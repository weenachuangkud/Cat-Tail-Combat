-- Modules
local Modules = script.Parent.Parent

-- Types
local WeaponTypes = require(Modules:WaitForChild("Types").WeaponTypes)


-- DefaultWeaponSetting

local DefaultWeaponSetting : WeaponTypes.WeaponSetting = {
	CurrentAmmo = 500,
	UseMag = false,
	
	
	
	ShowMouseCursor = true,
	ShowMouseCursorOnAim = false,
}

return DefaultWeaponSetting
