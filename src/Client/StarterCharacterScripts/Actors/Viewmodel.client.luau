--!native
--!strict

--[[
	- Author : Mawin CK
	- Date : 2025
]]

-- NOTE : You can mod this file as you want, but you should not delete this script

-- Services
local Rep = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

-- Modules
local Gun_Engine = Rep:WaitForChild("GunEngineRef").Value
local Modules = Gun_Engine:WaitForChild("Modules")
local Libraries = Modules:WaitForChild("Libraries")
local Util = Modules:WaitForChild("Utility")

-- Requires
local Utility = require(Util)
local WeaponObj = require(Modules:WaitForChild("Objects").Weapon)
local Spring = require(Libraries:WaitForChild("Spring"))
local MathModule = require(Util.Math)
local UnreliablePackets = require(Libraries:WaitForChild("UnreliablePackets"))
local Types = require(Modules:WaitForChild("Types").WeaponTypes)

-- Types

type Randomized = number | {
	min : number | {number},
	max : number | {number}
}


-- Actor

local Actor = script:GetActor()

-- Conenctions

local connection : RBXScriptConnection? = nil

--- CONSTs

-- Sway
local SWAY_INTENSITY = 0.005
local SWAY_MAX_ANGLE = math.rad(5)
local SWAY_SMOOTHNESS = 0.01

-- Bob

local BOB_FREQ = 2.5
local BOB_AMP = 0.02
local BOB_SPEED = 2.5
local BOB_INTENSITY = 1.15

-- Lerp

local LerpAlpha = 0.98

-- FOV
local NormalFOV = workspace.CurrentCamera.FieldOfView

--local t = tick()


--- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid") :: Humanoid

local mouse = player:GetMouse()
local CurrentCamera = workspace.CurrentCamera
local currentViewmodelCFrame = CFrame.new()


local Torso = character:WaitForChild("Torso")

-- RateLimits

local Rot_LastSend = 0
local Rot_SendRate = 1/10

-- Limb
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local Neck = Torso:WaitForChild("Neck")

-- Origin C0

-- NOTE: YOU DONT NEED THIS ACTUALLY, but i do :P
local origNeck = CFrame.new(0,1,0) * CFrame.fromOrientation(math.rad(-90), math.rad(-180), math.rad(0))
local origRightS = CFrame.new(1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
local origLeftS = CFrame.new(-1, 0.5, 0) * CFrame.fromOrientation(math.rad(0), math.rad(-90), math.rad(0))


-- big ass

-- SwaySpring

local SwaySpring = Spring.new(Vector3.zero)
SwaySpring.Speed = 10
SwaySpring.Damping = 0.5
SwaySpring.Target = Vector3.zero

-- BobSpring
local BobSpring = Spring.new(Vector3.zero)
BobSpring.Speed = 8      -- Slightly slower than sway for natural decay
BobSpring.Damping = 0.6  -- Prevents oscillation
BobSpring.Target = Vector3.zero

-- AimSpring
local AimSpring = Spring.new(Vector3.zero)
AimSpring.Speed = 5
AimSpring.Damping = 0.5
AimSpring.Target = Vector3.zero

-- Shaky Spring
local ShakeSpring = Spring.new(Vector3.zero)
ShakeSpring.Speed = 2
ShakeSpring.Damping = 0.5
ShakeSpring.Target = Vector3.zero


--- CONSTs
local oldPlayerZOOM = player.CameraMaxZoomDistance
local MAX_ZOOM_DIST = 0.5

-- Weld C0 Offsets
local SHOULDER_OFFSET_X = 1
local SHOULDER_OFFSET_Y = .5
local NECK_OFFSET_Y = 1.035
local RIGHT_ANGLE_RAD = 1.55

-- Events
local RotServer = UnreliablePackets.RotServer

-- StateMachine

local StateMachine = Modules:WaitForChild("FPS_StateMachine")

-- CFrames
local AimCF = CFrame.new()

-- Functions

local function ResetRot()
	local debounce = 1/30
	
	while not (Neck.C0 == origNeck and RightShoulder.C0 == origRightS and LeftShoulder.C0 == origLeftS) do
		RotServer:Fire(CFrame.identity, CFrame.identity, CFrame.identity, false)
		--print("RESETING ROT")
		task.wait(debounce)
	end
end

local function ResetSpring()
	SwaySpring.Target = Vector3.zero
	SwaySpring.Position = Vector3.zero

	BobSpring.Target = Vector3.zero
	BobSpring.Target = Vector3.zero
end

--[[
	--print("RENDERSTEP")
	-- Check
	if player.CameraMaxZoomDistance ~= MAX_ZOOM_DIST then
		player.CameraMaxZoomDistance = MAX_ZOOM_DIST
	end

	-- Get mosue delta
	local mouseDelta = UIS:GetMouseDelta()

	--- Calculate
	--task.desynchronize()

	-- Sway
	local swayTarget = Vector3.new(
		-mouseDelta.Y * SWAY_INTENSITY,
		-mouseDelta.X * SWAY_INTENSITY,
		0
	)
	local swayTarget = MathModule.clampVector3(swayTarget, SWAY_MAX_ANGLE)

	-- Bob 
	local MoveDirection = humanoid.MoveDirection
	local bobOffset = Vector3.zero
	if MoveDirection.Magnitude > 0.01 then
		MoveDirection = MoveDirection.Unit
		-- TODO : Contiune 
		local speed = humanoid.WalkSpeed / 16 -- Normalize to default walk speed
		local bobTime = tick() * BOB_SPEED * speed
		local bobAmplitude = BOB_AMP * BOB_INTENSITY * speed
		-- Sinusoidal bobbing for vertical and horizontal movement
		bobOffset = Vector3.new(
			math.sin(bobTime * BOB_FREQ) * bobAmplitude * 0.5, -- Horizontal bob
			math.sin(bobTime * BOB_FREQ * 2) * bobAmplitude,  -- Vertical bob (faster cycle)
			0
		)
	end
	BobSpring.Target = bobOffset
	local smoothBobOffset = BobSpring.Position

	-- Rot Angles

	local RightS_Angles = CFrame.new(SHOULDER_OFFSET_X, SHOULDER_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y),RIGHT_ANGLE_RAD, 0)
	local LeftS_Angles = CFrame.new(-SHOULDER_OFFSET_X, SHOULDER_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y),-RIGHT_ANGLE_RAD, 0)
	local Neck_Angles = CFrame.new(0, NECK_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y) + RIGHT_ANGLE_RAD, 3.15, 0)

	-- Result

	SwaySpring.Target = swayTarget
	local swayPosition = SwaySpring.Position				

	-- Render
	local Viewmodel : Model = WeaponObj.Viewmodel
	if Viewmodel then
		--- Final Result
		local baseCFrame = CurrentCamera.CFrame

		local swayCFrame = CFrame.Angles(swayPosition.X, swayPosition.Y, 0)
		local bobCFrame = CFrame.new(smoothBobOffset)

		local targetCFrame = baseCFrame * swayCFrame * bobCFrame
		currentViewmodelCFrame = currentViewmodelCFrame:Lerp(targetCFrame, LerpAlpha)



		--task.synchronize()

		-- Rots

		RotServer:Fire(RightS_Angles, LeftS_Angles, Neck_Angles, true)

		-- Render
		Viewmodel:PivotTo(currentViewmodelCFrame)
	end
]]

-- This is hard coded shit - Mawin_CK 2025
-- I'm sorry for making this shit lmao - Mawin_CK 2026

local function OnFPS_State(FPS_State : boolean, WeaponObj : WeaponObj.WeaponObject)
	print(FPS_State)
	if FPS_State then
		player.CameraMaxZoomDistance = MAX_ZOOM_DIST
		local Setting : Types.WeaponSetting = WeaponObj.Setting :: Types.WeaponSetting
		
		UIS.MouseIconEnabled = (Setting.Visuals.ShowCursor == true) and true or false
		
		-- I'm a fucking pretty girl
		
		local Viewmodel : Model = WeaponObj.Viewmodel
		local gunmodel = nil
		
		for i, v in Viewmodel:GetDescendants() do
			if v.Name == Viewmodel.Name or v.Name == "gunmodel" then
				gunmodel = v
			end
		end


		if not gunmodel then
			error("No gunmodel")
			return
		end

		local Parts = gunmodel:WaitForChild("Parts")

		local AimPart: BasePart = Parts:WaitForChild("AimPart") :: BasePart
		
		-- Connect, You SHIT
		
		connection = RS.RenderStepped:Connect(function(dt : number)
			--print("RENDERSTEP")
			-- Check
			if player.CameraMaxZoomDistance ~= MAX_ZOOM_DIST then
				player.CameraMaxZoomDistance = MAX_ZOOM_DIST
			end

			-- Get mosue delta
			local mouseDelta = UIS:GetMouseDelta()

			--- Calculate, i have no idea, what this does
			--task.desynchronize()
			
			Rot_LastSend += dt

			-- Sway
			local swayTarget = Vector3.new(
				-mouseDelta.Y * SWAY_INTENSITY,
				-mouseDelta.X * SWAY_INTENSITY,
				0
			)
			local swayTarget = MathModule.clampVector3(swayTarget, SWAY_MAX_ANGLE)

			-- Bob 
			local MoveDirection = humanoid.MoveDirection
			local bobOffset = Vector3.zero
			if MoveDirection.Magnitude > 0.01 then
				MoveDirection = MoveDirection.Unit
				-- TODO : Contiune, Shit some goofball write this
				local speed = humanoid.WalkSpeed / 16 -- Normalize to default walk speed
				local bobTime = tick() * BOB_SPEED * speed
				local bobAmplitude = BOB_AMP * BOB_INTENSITY * speed
				
				local MoveInaccuracyDec = Setting.Accuracy.MoveInaccuracyDecrease
				
				if MoveInaccuracyDec then
					bobAmplitude = bobAmplitude * (1 - Utility.GetRandomizableNumber(MoveInaccuracyDec))
					BobSpring.Damping = 1.3
				end
				
				-- Sinusoidal bobbing for vertical and horizontal movement
				bobOffset = Vector3.new(
					math.sin(bobTime * BOB_FREQ) * bobAmplitude * 0.5, -- Horizontal bob
					math.sin(bobTime * BOB_FREQ * 2) * bobAmplitude,  -- Vertical bob (faster cycle)
					0
				)
			end
			
			BobSpring.Target = bobOffset
			local smoothBobOffset = BobSpring.Position

			-- Rot Angles

			local RightS_Angles = CFrame.new(SHOULDER_OFFSET_X, SHOULDER_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y),RIGHT_ANGLE_RAD, 0)
			local LeftS_Angles = CFrame.new(-SHOULDER_OFFSET_X, SHOULDER_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y),-RIGHT_ANGLE_RAD, 0)
			local Neck_Angles = CFrame.new(0, NECK_OFFSET_Y, 0) * CFrame.Angles(-math.asin((mouse.Origin.p - mouse.Hit.p).unit.y) + RIGHT_ANGLE_RAD, 3.15, 0)

			-- Result

			SwaySpring.Target = swayTarget
			local swayPosition = SwaySpring.Position	

			-- Render
			if Viewmodel then
				--- Final Result
				local baseCFrame = CurrentCamera.CFrame

				local swayCFrame = CFrame.Angles(swayPosition.X, swayPosition.Y, 0)
				local bobCFrame = CFrame.new(smoothBobOffset)
				
				local IsAiming = StateMachine:GetAttribute("IsAiming")
				
				local AimingSetting = Setting.Aiming
				
				local ADS_Enabled = AimingSetting.Enabled
				local ADS_InSpeed = AimingSetting.InSpeed
				local ADS_OutSpeed = AimingSetting.OutSpeed
				
				local ZoomSetting = Setting.Zoom
				
				if ADS_Enabled and IsAiming then

					-- AimCF Calacute thingy
					if not ADS_InSpeed then error("Setting.ADS_InTime is nil") return end
					
					
					local PrimPart = Viewmodel.PrimaryPart
					
					local offset : CFrame = CFrame.new()
					
					if PrimPart then
						offset =  AimPart.CFrame:ToObjectSpace(PrimPart.CFrame)
					else
						error("PrimaryPart of viewmodel is nil")
						return
					end
					
					AimSpring.Speed = Utility.GetRandomizableNumber(ADS_InSpeed)
					AimSpring.Target = offset.Position
					
					local Zoom_InTime = ZoomSetting.InTime
					
					local zoomLevel = ZoomSetting.Normal
					if StateMachine:GetAttribute("IsFocus") then
						zoomLevel += ZoomSetting.FocusAdd
					end
					
					if Zoom_InTime then
						TS:Create(
							CurrentCamera, 
							TweenInfo.new(Utility.GetRandomizableNumber(Zoom_InTime)), 
							{FieldOfView = MathModule.ConvertZoomLevelToFOV(NormalFOV, zoomLevel)}
						):Play()
					else
						warn("Setting.ZoomInTime is nil")
					end
					
					UIS.MouseIconEnabled = (Setting.Visuals.ShowCursorWhenAiming == true) and true or false
					
				else
					
					local Zoom_OutTime = ZoomSetting.OutTime
					
					if Zoom_OutTime then
						TS:Create(
							CurrentCamera, 
							TweenInfo.new(Utility.GetRandomizableNumber(ADS_InSpeed)), 
							{FieldOfView = NormalFOV}
						):Play()
					else
						warn("Setting.ZoomOutTime is nil")
					end
					
					if not ADS_OutSpeed then error("Setting.ADS_OutSpeed is nil") return end
					AimSpring.Speed = Utility.GetRandomizableNumber(ADS_OutSpeed)
					AimSpring.Target = Vector3.zero
					
					UIS.MouseIconEnabled = (Setting.Visuals.ShowCursorWhenAiming == true) and true or false
				end
				
				AimCF = CFrame.new(AimSpring.Position)
				
				-- targetCFrame, LET GO BOII!

				local targetCFrame = baseCFrame 
					* swayCFrame
					* AimCF
					* bobCFrame
				
				currentViewmodelCFrame = currentViewmodelCFrame:Lerp(targetCFrame, LerpAlpha)

				
				--task.synchronize()

				-- Rots

				if Rot_LastSend >= Rot_SendRate then
					Rot_LastSend = 0
					RotServer:Fire(RightS_Angles, LeftS_Angles, Neck_Angles, true)
				end

				-- Render
				Viewmodel:PivotTo(currentViewmodelCFrame)
			end
		end)
	else
		UIS.MouseIconEnabled = true
		player.CameraMaxZoomDistance = oldPlayerZOOM
		
		if connection then
			connection:Disconnect()
			connection = nil
		end
		
		ResetRot()
		ResetSpring()
	end
end


-- Listeners

Actor:BindToMessage("FPS_State", OnFPS_State)
