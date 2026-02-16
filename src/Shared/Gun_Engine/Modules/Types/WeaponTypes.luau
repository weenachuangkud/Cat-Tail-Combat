--[[
	- Author : Mawin_CK
	- Date : 11/03/2025
	- Claude refactor: Improved organization and structure
]]
--!strict

-- Services
--local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = script.Parent.Parent.Parent
local Modules = GunEngine:WaitForChild("Modules")
local Types = Modules:WaitForChild("Types")

-- Requires
local ProjectileTypes = require(Types:WaitForChild("ProjectileTypes"))

-- Module
--type WeaponAnimation = AnimationObject | AnimationTrack
type RandomizableNumber = number | {
	min : number | {number},
	max : number | {number},
	Float : boolean?
}

type RandomizableSound = Sound | {Sound}

export type AnimationSetting = {
	Speed : RandomizableNumber?,
	FadeTime : RandomizableNumber?,
	Weight : RandomizableNumber?
}

--[[
	VALIDATION RULES:
	- All RandomizableNumber values should have min < max
	- Percentages (chances) are 0-100
	- Time values are in seconds
	- Distance values are in studs
	- Angles are in degrees
	- Multipliers should generally be 0-2 range
	- Speeds are in studs/second
]]

-- Runtime state (separate from configuration)
export type WeaponState = {
	CurrentAmmo : number,
	CurrentReserve : number,
	CurrentZoom : number,
	CurrentAccuracy : number,
	CurrentZero : number,
	CurrentRecoilPower : number,
	IsJammed : boolean,
	HasChamberedRound : boolean,
}

export type WeaponSetting = {
	-- Basic Info
	WeaponWeight : number, -- affects movement speed and sway

	-- Positioning
	HolsterCFrame : CFrame,
	HolsterAngles : CFrame,

	-- Ammo System
	Ammo : {
		UseMagazine : boolean,

		-- Capacities
		MaxCapacity : number, -- Max ammo total (non-magazine) or max reserve (magazine)
		MagazineSize : number?, -- Only if UseMagazine == true

		-- Ammo type reference (name of module in Types folder)
		TypeName : string,
	},

	-- Visual Ammo Model
	AmmunitionModel : Model | BasePart, -- Displayed on BulletType

	-- Damage & Penetration
	Power : {
		Damages : {
			["Head"] : RandomizableNumber, -- multiplier or flat damage
			["Torso"] : RandomizableNumber,
			["Limbs"] : RandomizableNumber
		},

		IgnoreProtection : boolean, -- ignores armor/vests
		DamagePenetration : RandomizableNumber, -- damage retained after penetrating (0-1)
		PenetrationDepth : number, -- max thickness can penetrate (studs)
	},

	MaxRange : number, -- max damage distance (studs)

	-- Ballistics
	Ballistics : {
		MuzzleVelocity : number, -- studs/second
		BulletDrop : boolean, -- gravity multiplier (0-1, 0 = no drop, 1 = full gravity)

		Zeroing : {
			Enabled : boolean,
			Default : number, -- default zero distance (studs)
			Increment : number, -- adjustment step (studs)
			Max : number, -- maximum zero distance (studs)
		}?,
	},

	-- Fire Modes & Rate
	FireMode : {
		Default : "Semi" | "Burst" | "Auto",
		CanChange : boolean,
		Available : {
			Semi : boolean,
			Burst : boolean,
			Auto : boolean,
		},
	},

	FireRate : {
		RoundsPerMinute : number, -- fire rate in RPM
		BurstCount : RandomizableNumber?, -- rounds per burst if burst mode enabled
	},

	-- Chamber System
	Chamber : {
		HasChamber : boolean,
		AutoChamber : boolean,
		CanInsertShell : boolean,
		InsertShellAmount : number, -- shells added per insert action
	},

	-- Jamming
	JamChance : RandomizableNumber, -- 0-100 chance to jam

	-- Recoil System
	Recoil : {
		Camera : {
			Up : RandomizableNumber,
			Tilt : RandomizableNumber,
			Left : RandomizableNumber,
			Right : RandomizableNumber,
		},

		Gun : {
			Up : RandomizableNumber,
			Tilt : RandomizableNumber,
			Left : RandomizableNumber,
			Right : RandomizableNumber,
		}?,

		MinPower : number,
		MaxPower : number,
		PowerStepAmount : RandomizableNumber,

		-- Reductions
		BaseReduction : RandomizableNumber,
		AimReduction : RandomizableNumber,
		SteadyReduction : RandomizableNumber,
	},

	-- Spread System
	Spread : {
		-- Fire spread
		Fire : {
			Pattern : RandomizableNumber,
			Min : number,
			Max : number,
		},

		-- Hipfire spread
		HipFire : {
			Pattern : RandomizableNumber,
		},

		-- Aim spread
		Aim : {
			StepAmount : RandomizableNumber,
			RunningStepAmount : RandomizableNumber,
			Reduction : RandomizableNumber,
			SteadyReduction : RandomizableNumber,
		},

		-- Stance modifiers
		Stance : {
			Standing : RandomizableNumber,
			Crouch : RandomizableNumber,
			Prone : RandomizableNumber,
		},
	},

	-- Accuracy System
	Accuracy : {
		Base : number, -- starting accuracy value
		SteadyAdd : RandomizableNumber,
		MoveInaccuracyDecrease : RandomizableNumber,
	},

	-- Movement
	Movement : {
		WalkSpeedMultiplier : number, -- speed mult when weapon is equipped
	},

	-- Sway
	Sway : {
		Idle : RandomizableNumber,
		Aim : RandomizableNumber,
	},

	-- Aiming System
	Aiming : {
		Enabled : boolean,
		InSpeed : RandomizableNumber, -- time to ADS (seconds)
		OutSpeed : RandomizableNumber, -- time to exit ADS (seconds)
	},

	-- Zoom System
	Zoom : {
		Type : "Levels" | "Continuous",

		-- For Type == "Levels"
		Levels : {number}?, -- e.g., {1.5, 2.5, 4.0}

		-- For Type == "Continuous"
		Continuous : {
			Min : number,
			Max : number,
			Increment : number,
			Decrement : number,
		}?,

		-- Common settings
		Normal : number, -- base zoom level
		FocusAdd : number, -- additional zoom when holding breath
		InTime : RandomizableNumber,
		OutTime : RandomizableNumber,
	},

	-- Ready States
	ReadyStates : {
		HighReady : {
			Enabled : boolean,
			InTime : RandomizableNumber,
			OutTime : RandomizableNumber,
		},

		LowReady : {
			Enabled : boolean,
			InTime : RandomizableNumber,
			OutTime : RandomizableNumber,
		},
	}?,

	-- Weapon Interaction
	Interaction : {
		CanCheckAmmo : boolean,
		CanCancelReload : boolean, -- can cancel reload with other actions
		CanBlindFire : boolean,
		WeaponCollision : boolean, -- weapon reacts to world collision
	},

	-- Visual Settings
	Visuals : {
		Tracer : {
			Enabled : boolean,
			EveryXShots : number, -- every Xth bullet becomes tracer (0 = disabled)
			Random : {
				Enabled : boolean,
				Chance : number, -- 0-100
			},
		},

		BulletFlare : boolean,
		MuzzleFlashChance : number, -- 0-100
		Casings : boolean,

		ShowCursor : boolean,
		ShowCursorWhenAiming : boolean,
	},

	-- HUD
	HUD : {
		Enabled : boolean,
	},

	-- Animation Settings
	AnimationSettings : {
		Idle : AnimationSetting,
		Equip : AnimationSetting,
		Unequip : AnimationSetting,

		Fire : AnimationSetting,
		Aim : AnimationSetting,
		Reload : AnimationSetting,
		InsertShell : AnimationSetting,
		ChamberingBullet : AnimationSetting,

		HighReady : AnimationSetting,
		LowReady : AnimationSetting,

		Sprint : AnimationSetting,
	},

	-- VFX
	VFX : {
		-- Muzzle Flash
		MuzzleFlashVfx : Instance,

		-- Shell Ejection
		ShellModel : Instance,
		ShellEjectSpeed : RandomizableNumber,
		ShellEjectDirection : CFrame,

		-- Impact Effects
		ImpactVFXByMaterial : boolean,
		GenericImpactVfx : Instance,
		MaterialImpactVFXs : {
			[string] : Instance
		},
	},

	-- SFX
	SFX : {
		Equip : Sound,
		Unequip : Sound,
		Fire : RandomizableSound,

		HighReadyInSound : Sound,
		HighReadyOutSound : Sound,

		LowReadyInSound : Sound,
		LowReadyOutSound : Sound,
	},

	-- Addons/Special Features
	Explosive : {
		Enabled : boolean,
		ExplosionRadius : number,
		ExplosionVFX : string,
	}?,

	--- WIP - Attachment System
	--[[
		Attachments : {
			Sights : {[string] : Attachment},
			Barrels : {[string] : Attachment},
			UnderBarrels : {[string] : Attachment},
			Other : {[string] : Attachment},
		},
		
		GrenadeLauncher : {
			Enabled : boolean,
			ExplosionRadius : number,
			ExplosionVFX : string,
			CanBounce : boolean,
			GrenadeDrop : number,
			GrenadeVelocity : number,
			
			UseFuzeTime : boolean,
			FuzeTime : RandomizableNumber, -- seconds until detonation
		}?,
	]]
}

export type WeaponAnimations = {
	Equip : AnimationTrack,
	Unequip : AnimationTrack,

	Shoot : AnimationTrack,

	Reload : AnimationTrack,

	HighReady : AnimationTrack,
	LowReady : AnimationTrack,

	InsertShell : AnimationTrack,
	ChamberingBullet : AnimationTrack,

	--- WIP, will make this soon later?
	--BlindFireUp : AnimationTrack,
	--BlindFireDown : AnimationTrack,
	--BlindFireLeft : AnimationTrack,
	--BlindFireRight : AnimationTrack
}

--[[export type AnimationObject = {
	AnimTrack : AnimationTrack,
	Instance : Animation,
	Speed : number?, -- defualt 1
	Weight : number?, -- default 1
	FadeTime : number? -- default 0.1
}
]]

export type FPS_Data = {

}

return {}