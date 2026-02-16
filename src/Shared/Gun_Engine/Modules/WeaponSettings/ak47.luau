--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]
-- Services
local Rep = game:GetService("ReplicatedStorage")

-- GunEngine
local GunEngine = Rep:WaitForChild("GunEngineRef").Value

local Assets = GunEngine:WaitForChild("Assets")
local SFXs = Assets:WaitForChild("SFXs")
local Modules = GunEngine:WaitForChild("Modules")

-- Requires
local Types = require(Modules:WaitForChild("Types").WeaponTypes)

-- Settings
local setting : Types.WeaponSetting = {
	-- Basic Info
	WeaponWeight = 3.5, -- kg (adjust as needed)

	-- Positioning
	HolsterCFrame = CFrame.new(-0.5, -0.2, -0.6),
	HolsterAngles = CFrame.Angles(math.rad(-20), math.rad(-90), math.rad(0)),

	-- Ammo System
	Ammo = {
		UseMagazine = true,
		MaxCapacity = 150, -- 5 mags * 30 rounds
		MagazineSize = 30,
		TypeName = "7.62x39mm",
	},

	-- Visual Ammo Model (you'll need to set this to actual model)
	AmmunitionModel = nil, -- Replace with actual Model/BasePart reference

	-- Damage & Penetration
	Power = {
		Damages = {
			["Head"] = {min = 100, max = 300},
			["Torso"] = {min = 50, max = 100},
			["Limbs"] = {min = 30, max = 50}
		},
		IgnoreProtection = false,
		DamagePenetration = 0.7, -- retains 70% damage after penetration
		PenetrationDepth = 1.18, -- 30mm converted to studs (30/25.4)
	},

	MaxRange = 1000, -- studs

	-- Ballistics
	Ballistics = {
		MuzzleVelocity = 2350, -- studs/second (adjust as needed)
		BulletDrop = 0.5, -- moderate drop
		Zeroing = {
			Enabled = true,
			Default = 100,
			Increment = 50,
			Max = 600,
		},
	},

	-- Fire Modes & Rate
	FireMode = {
		Default = "Auto",
		CanChange = true,
		Available = {
			Semi = true,
			Burst = true,
			Auto = true,
		},
	},

	FireRate = {
		RoundsPerMinute = 600,
		BurstCount = 3,
	},

	-- Chamber System
	Chamber = {
		HasChamber = true,
		AutoChamber = true,
		CanInsertShell = false,
		InsertShellAmount = 1,
	},

	-- Jamming
	JamChance = 0.5, -- 0.5% chance

	-- Recoil System
	Recoil = {
		Camera = {
			Up = {min = 0.5, max = 1.5},
			Tilt = {min = -0.3, max = 0.3},
			Left = {min = -0.2, max = 0.2},
			Right = {min = -0.2, max = 0.2},
		},
		Gun = {
			Up = {min = 0.3, max = 0.8},
			Tilt = {min = -0.2, max = 0.2},
			Left = {min = -0.1, max = 0.1},
			Right = {min = -0.1, max = 0.1},
		},
		MinPower = 1,
		MaxPower = 5,
		PowerStepAmount = 0.5,
		BaseReduction = 0.1,
		AimReduction = 0.3,
		SteadyReduction = 0.2,
	},

	-- Spread System
	Spread = {
		Fire = {
			Pattern = {min = 1, max = 3},
			Min = 0.5,
			Max = 5,
		},
		HipFire = {
			Pattern = {min = 2, max = 5},
		},
		Aim = {
			StepAmount = 0.1,
			RunningStepAmount = 0.3,
			Reduction = 0.5,
			SteadyReduction = 0.3,
		},
		Stance = {
			Standing = 1.0,
			Crouch = 0.7,
			Prone = 0.5,
		},
	},

	-- Accuracy System
	Accuracy = {
		Base = 95,
		SteadyAdd = 5,
		MoveInaccuracyDecrease = {min = 5, max = 10},
	},

	-- Movement
	Movement = {
		WalkSpeedMultiplier = 0.85,
	},

	-- Sway
	Sway = {
		Idle = {min = 0.5, max = 1.0},
		Aim = {min = 0.1, max = 0.3},
	},

	-- Aiming System
	Aiming = {
		Enabled = true,
		InSpeed = 19, -- converted from old ADS_InTime (4 seems wrong, using reasonable value)
		OutSpeed = 25, -- converted from old ADS_OutTime
	},

	-- Zoom System
	Zoom = {
		Type = "Continuous",
		Levels = nil,
		Continuous = {
			Min = 1.0,
			Max = 2.0,
			Increment = 0.1,
			Decrement = 0.1,
		},
		Normal = 1.25, -- from NormalAimZoomLevel
		FocusAdd = 0.45, -- from FocusAimZoomLevelAdd
		InTime = 0.145, -- from ZoomInTime
		OutTime = 0.23, -- from ZoomOutTime
	},

	-- Ready States
	ReadyStates = {
		HighReady = {
			Enabled = true,
			InTime = 0.3,
			OutTime = 0.3,
		},
		LowReady = {
			Enabled = true,
			InTime = 0.3,
			OutTime = 0.3,
		},
	},

	-- Weapon Interaction
	Interaction = {
		CanCheckAmmo = true,
		CanCancelReload = true,
		CanBlindFire = false,
		WeaponCollision = true,
	},

	-- Visual Settings
	Visuals = {
		Tracer = {
			Enabled = true,
			EveryXShots = 5,
			Random = {
				Enabled = false,
				Chance = 50,
			},
		},
		BulletFlare = true,
		MuzzleFlashChance = 90,
		Casings = true,
		ShowCursor = true,
		ShowCursorWhenAiming = false,
	},

	-- HUD
	HUD = {
		Enabled = true,
	},

	-- Animation Settings (you'll need to configure these)
	AnimationSettings = {
		Idle = {Speed = 1, FadeTime = 0.1, Weight = 1},
		Equip = {Speed = 1/0.546, FadeTime = 0.1, Weight = 1}, -- using EquipTime
		Unequip = {Speed = 1, FadeTime = 0.1, Weight = 1},
		Fire = {Speed = 1, FadeTime = 0, Weight = 1},
		Aim = {Speed = 1, FadeTime = 0.1, Weight = 1},
		Reload = {Speed = 1, FadeTime = 0.1, Weight = 1},
		InsertShell = {Speed = 1, FadeTime = 0.1, Weight = 1},
		ChamberingBullet = {Speed = 1, FadeTime = 0.1, Weight = 1},
		HighReady = {Speed = 1, FadeTime = 0.1, Weight = 1},
		LowReady = {Speed = 1, FadeTime = 0.1, Weight = 1},
		Sprint = {Speed = 1, FadeTime = 0.1, Weight = 1},
	},

	-- VFX (you'll need to set these to actual instances)
	VFX = {
		MuzzleFlashVfx = nil, -- Replace with actual instance
		ShellModel = nil, -- Replace with actual instance
		ShellEjectSpeed = {min = 20, max = 30},
		ShellEjectDirection = CFrame.Angles(0, math.rad(90), 0),
		ImpactVFXByMaterial = true,
		GenericImpactVfx = nil, -- Replace with actual instance
		MaterialImpactVFXs = {},
	},

	-- SFX
	SFX = {
		Equip = SFXs["Equip 1"],
		Unequip = SFXs["m4a1 unequip audio"],
		Fire = nil, -- Replace with actual fire sound
		HighReadyInSound = nil,
		HighReadyOutSound = nil,
		LowReadyInSound = nil,
		LowReadyOutSound = nil,
	},

	-- Explosive (optional addon)
	Explosive = nil,
}

return setting