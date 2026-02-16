--!strict
--[[
    FPS_Animator.lua
    Author: Mawin CK
    Date: 11/03/2025
    Description: A robust FPS weapon animation manager for Roblox.
                 Supports AnimationTracks, AnimationObjects, and KeyframeSequences.
                 I've made this shit to make it works with my gun engine
]]

-- Services
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local RS = game:GetService("RunService")

-- Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunEngine = ReplicatedStorage:WaitForChild("Gun_Engine")
local Modules = GunEngine:WaitForChild("Modules")
local Utility = require(Modules.Utility)
local WeaponTypes = require(Modules.Types.WeaponTypes)

-- Types
--type ValidAnimation = string | AnimationTrack | WeaponTypes.AnimationObject | KeyframeSequence

export type AnimationController = {
	Animator: Animator,
	Animations: { [string]: AnimationTrack},
	CurrentAnim : (AnimationTrack)?,
	
	new : (name: string, animator: Animator) -> AnimationController,

	Play: (self: AnimationController, anim: string, speed: number?, fadeTime: number?, weight: number?) -> (),
	Stop: (self: AnimationController, anim : string, fadeTime: number?) -> (),
	Destroy: (self: AnimationController) -> (),
	
	StopAll: (self : AnimationController, fadetime : number) -> (),
	
	__index : AnimationController
}

-- Constants
local DEFAULT_FADE_TIME = 0.1
local DEFAULT_WEIGHT = 1
local DEFAULT_SPEED = 1

-- Private Helpers
local function loadKeyframeSequence(animator: Animator, kfs: KeyframeSequence): AnimationTrack?
	local animationId = KeyframeSequenceProvider:RegisterKeyframeSequence(kfs)
	if not animationId then
		warn("[FPS_Animator] Failed to register KeyframeSequence:", kfs:GetFullName())
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	return track
end

local function loadAnimationID(animator : Animator, ID : string)
	local animation = Instance.new("Animation")
	animation.AnimationId = ID
	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	return track
end

-- Main Module
local AnimationController = {} :: AnimationController
AnimationController.__index = AnimationController

--[[
	Creates a new FPS_Animator instance.
	@param name The weapon name used to load its animation data.
	@param animator The Animator instance (usually in the weapon tool or arms).
]]
function AnimationController.new(WeaponName: string, animator: Animator): AnimationController
	assert(typeof(WeaponName) == "string" and #WeaponName > 0, "Weapon name must be a non-empty string")
	assert(animator and animator:IsA("Animator"), "Valid Animator instance required")

	local animationModule = Utility.FindWeaponAnimation(WeaponName)
	if not animationModule:IsA("ModuleScript") then error("animationFolder must be a ModuleScript") end
	local animations = require(animationModule) :: { [string]: any }

	local self = setmetatable({
		Animator = animator,
		Animations = {},
		CurrentAnim = nil,
	} :: any, AnimationController)
	
	for k, v in animations do
		local t = typeof(v)
		if t == "string" then
			self.Animations[k] = loadAnimationID(self.Animator, v)
		elseif t == "Instance" and v:IsA("KeyframeSequence") then
			self.Animations[k] = loadKeyframeSequence(self.Animator, v)
		elseif t == "Instance" and v:IsA("Animation") then
			self.Animations[k] = self.Animator:LoadAnimation(v)
		else
			if RS:IsStudio() then
				warn("Invaild types for animation")
			end
		end
	end
	
	return self
end

--[[
	Plays an animation by name
]]
function AnimationController:Play(
	animName: string,
	speed: number?,
	fadeTime: number?,
	weight: number?
)
	local animTrack = self.Animations[animName]
	if not animTrack then 
		if RS:IsStudio() then warn("Invaild animationName : " .. animName) end
		return 
	end
	
	speed = speed or DEFAULT_SPEED
	fadeTime = fadeTime or DEFAULT_FADE_TIME
	weight = weight or DEFAULT_WEIGHT
	
	if animTrack.IsPlaying then 
		animTrack:Stop(fadeTime)
	end
	
	animTrack:Play(fadeTime, weight, speed)
	return animTrack
end

--[[
	Stops the currently playing animation with optional fade out.
]]
function AnimationController:Stop(animName : string, fadeTime: number?)
	local animTrack = self.Animations[animName]
	if animTrack then
		animTrack:Stop(fadeTime or DEFAULT_FADE_TIME)
	else
		if RS:IsStudio() then
			warn("Invaild animationName")
		end
	end
end

--[[
	Stop all animations
]]
function AnimationController:StopAll(fadetime : number)
	for _, track in self.Animations do
		track:Stop(fadetime or DEFAULT_FADE_TIME)
	end
end

--[[
	Cleans up the animator. Call when weapon is unequipped/destroyed.
]]
function AnimationController:Destroy()
	for i, v in self.Animations do
		v:Destroy()
	end
	-- wtf
	setmetatable(self, nil)
end

return AnimationController