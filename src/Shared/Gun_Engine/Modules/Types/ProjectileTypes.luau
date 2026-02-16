--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]
--!strict

-- Services
--[[local Rep = game:GetService("ReplicatedStorage")

-- Modules
local GunEngine = Rep:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")

-- Requires

]]

-- Generic

-- TODO : Fix this shit ig

export type ProjectileData = {
	Origin : Vector3,
	Direction : Vector3,
	Lifetime : number,
	MaxDistance : number,
	ProjectileInstance : Instance,
	Velocity : Vector3,
	Acceleration : Vector3,
}

export type ProjectileImpact = {
	ImpactFX : ParticleEmitter?,
	Sound : Sound?,
	Position : Vector3,
	Hitbox : Instance | Vector3,
	Lifetime : number,
	CanDamage : boolean,
	Damage : number
}


-- Specfics for a projectile
export type BulletProjectile = ProjectileData & {
	Impact : ProjectileImpact,
}

export type GrenadeProjectile = ProjectileData & {
	Impact : ProjectileImpact,
	Bounces : number,
	FuseTime : number,
}

return {}