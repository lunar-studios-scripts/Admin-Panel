local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
local Evt = Engine:WaitForChild("Eventos")
local Mod = Engine:WaitForChild("Modulos")
local GunModels = Engine:WaitForChild("GunModels")
local GunModelClient = GunModels:WaitForChild("Client")
local GunModelServer = GunModels:WaitForChild("Server")
local GunModelHolster = GunModels:WaitForChild("Holster")
local Utils = require(Mod:WaitForChild("Utilities"))
local ServerConfig = require(Engine.ServerConfigs:WaitForChild("Config"))
local TS = game:GetService("TweenService")
local RagdollModule = require(Mod:WaitForChild("PlayerRagdoll"))

local Players = game:GetService("Players")
local ACS_Storage = workspace:WaitForChild("ACS_WorkSpace")
local HttpService = game:GetService("HttpService")
local ACS_0 = HttpService:GenerateGUID(true)

local Debris = game:GetService("Debris")
local BreakModule = require(Mod:WaitForChild("PartFractureModule"))

local StancesTweenTable = {}
local EvtStanceTweenTable = {}

local ver = "ACS R15 Mod 1.2.5 v4 beta"
print(ver .. " loading")



local AttachmentsFolder
do
	local Terrain = workspace:FindFirstChildOfClass("Terrain")
	if not Terrain then
		warn(ver .. ": Please insert a Terrain instance to your game. ACS won't work.")
	else
		AttachmentsFolder = Terrain:FindFirstChild("ACS_Attachments")
		if not AttachmentsFolder then
			AttachmentsFolder = Instance.new("Attachment")
			AttachmentsFolder.Name = "ACS_Attachments"
			AttachmentsFolder.Parent = Terrain
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:connect(function(character)
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.BreakJointsOnDeath = false
			local con
			con = humanoid.Died:connect(function()
				if ServerConfig.EnableRagdoll then
					RagdollModule(character)
				end
				con:Disconnect()
			end)
			
			if ServerConfig.TeamTags then
				local TTScript = Engine.Essential.TeamTag:Clone()
				TTScript.Parent = Player.PlayerGui
				TTScript.Disabled = false
			end
		end
	end)
end)

local space = workspace.ACS_WorkSpace.Server

space.ChildAdded:Connect(function(child)
	if child:IsA("BasePart") then
		local anchored
		repeat
			if child.Velocity.Magnitude < 0.01 then
				if not anchored then
					coroutine.wrap(function()
						task.wait(1)
						if child.Velocity.Magnitude < 0.01 and not anchored then
							anchored = true
						end
					end)()
				end
				if anchored then
					child.Anchored = true
					child.Velocity = Vector3.new(0,0,0)
					child.CanCollide = false
				end
			end
			task.wait(0.1)
		until anchored
	end
end)


local RS = game:GetService("RunService")

local Explosion = {"187137543"; "169628396"; "926264402"; "169628396"; "926264402"; "169628396"; "187137543";}




local SilencerNames = {
	"Supressor",
	"Suppressor",
	"Silencer",
	"Silenciador",
}

function FindSilencer(model)
	for _,name in pairs(SilencerNames) do
		local found = model:FindFirstChild(name)
		if found then
			return found
		end
	end
	return nil
end






----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------



Evt.AcessId.OnServerEvent:Connect(function(player,id)
	if player.UserId == id then
		Evt.AcessId:FireClient(player,ACS_0)
	else
		player:kick(ServerConfig.KickMessage or "whoops, better luck next time")
	end
end)



function Weld(p0, p1, cf1, cf2)
	local m = Instance.new("Motor6D")
	m.Part0 = p0
	m.Part1 = p1
	m.Name = p0.Name
	m.C0 = cf1 or p0.CFrame:inverse() * p1.CFrame
	m.C1 = cf2 or CFrame.new()
	m.Parent = p0
	return m
end

function OnRecarregar(Player, Arma, VarDict)
	local var = Arma.ACS_Modulo.Variaveis
	for key, val in pairs(VarDict) do
		if var:FindFirstChild(key) then
			var[key].Value = val
		end
	end
end

Evt.Recarregar.OnServerEvent:Connect(OnRecarregar)

Evt.Treino.OnServerEvent:Connect(function(Player, Vitima)

	if Vitima.Parent:FindFirstChild("Saude") ~= nil then
		local saude = Vitima.Parent.Saude
		saude.Variaveis.HitCount.Value = saude.Variaveis.HitCount.Value + 1
	end

end)

Evt.SVFlash.OnServerEvent:Connect(function(Player,Mode,Arma,Angle,Bright,Color,Range)
	if ServerConfig.ReplicatedFlashlight then
		Evt.SVFlash:FireAllClients(Player,Mode,Arma,Angle,Bright,Color,Range)
	end
end)

Evt.SVLaser.OnServerEvent:Connect(function(Player,Position,Modo,Cor,Arma,IRmode)
	if ServerConfig.ReplicatedLaser then
		Evt.SVLaser:FireAllClients(Player,Position,Modo,Cor,Arma,IRmode)
	end
end)

Evt.Breach.OnServerEvent:Connect(function(Player,Mode,BreachPlace,Pos,Norm,Hit)

	if Mode == 1 then
		Player.Character.Saude.Kit.BreachCharges.Value = Player.Character.Saude.Kit.BreachCharges.Value - 1
		BreachPlace.Destroyed.Value = true
		local C4 = Engine.FX.BreachCharge:Clone()

		C4.Parent = BreachPlace.Destroyable
		C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
		C4.Center.Place:Play()

		local weld = Instance.new("WeldConstraint")
		weld.Parent = C4
		weld.Part0 = BreachPlace.Destroyable.Charge
		weld.Part1 = C4.Center

		task.wait(1)
		C4.Center.Beep:Play()
		task.wait(4)
		C4.Center.Beep.Playing = false
		C4.Charge:Destroy()
		local Exp = Instance.new("Explosion")
		Exp.BlastPressure = 0
		Exp.BlastRadius = 0
		Exp.DestroyJointRadiusPercent = 0
		Exp.Position = C4.Center.Position
		Exp.Parent = workspace

		local S = Instance.new("Sound")
		S.EmitterSize = 50
		S.MaxDistance = 1500
		S.SoundId = "rbxassetid://".. Explosion[math.random(1, 7)]
		S.PlaybackSpeed = math.random(30,55)/40
		S.Volume = 2
		S.Parent = Exp
		S.PlayOnRemove = true
		S:Destroy()

		Debris:AddItem(BreachPlace.Destroyable,0)
	elseif Mode == 2 then

		Player.Character.Saude.Kit.BreachCharges.Value = Player.Character.Saude.Kit.BreachCharges.Value - 1
		BreachPlace.Destroyed.Value = true
		local C4 = Engine.FX.BreachCharge:Clone()

		C4.Parent = BreachPlace
		C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
		C4.Center.Place:Play()

		local weld = Instance.new("WeldConstraint")
		weld.Parent = C4
		weld.Part0 = BreachPlace.Door.Door
		weld.Part1 = C4.Center

		task.wait(1)
		C4.Center.Beep:Play()
		task.wait(4)
		C4.Center.Beep.Playing = false
		C4.Charge:Destroy()
		local Exp = Instance.new("Explosion")
		Exp.BlastPressure = 0
		Exp.BlastRadius = 0
		Exp.DestroyJointRadiusPercent = 0
		Exp.Position = C4.Center.Position
		Exp.Parent = workspace

		local S = Instance.new("Sound")
		S.EmitterSize = 50
		S.MaxDistance = 1500
		S.SoundId = "rbxassetid://".. Explosion[math.random(1, 7)]
		S.PlaybackSpeed = math.random(30,55)/40
		S.Volume = 2
		S.Parent = Exp
		S.PlayOnRemove = true
		S:Destroy()

		Debris:AddItem(BreachPlace,0)

	elseif Mode == 3 then

		Player.Character.Saude.Kit.Fortifications.Value = Player.Character.Saude.Kit.Fortifications.Value - 1
		BreachPlace.Fortified.Value = true
		local C4 = Instance.new('Part')

		C4.Parent = BreachPlace.Destroyable
		C4.Size =  Vector3.new(Hit.Size.X + .05,Hit.Size.Y + .05,Hit.Size.Z + 0.5) 
		C4.Material = Enum.Material.DiamondPlate
		C4.Anchored = true
		C4.CFrame = Hit.CFrame

		local S = Engine.FX.FortFX:Clone()
		S.PlaybackSpeed = math.random(30,55)/40
		S.Volume = 1
		S.Parent = C4
		S.PlayOnRemove = true
		S:Destroy()

	end
end)

--Start Blizzard Compat Functions----
Evt.BlizzardCompat.HeliHit.OnServerEvent:Connect(function(Player, Heli, dg, damage, Id)
	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "no jimmy, you can't make all blizzard helicopters go boom")
		end
		return
	end
	if 0 < dg.Value then
		if dg.Value > damage then
			dg.Value = dg.Value - damage
		else
			dg.Value = 0
		end
	end
end)

--End Blizzard Compat Functions----



--Start Striker Compat Functions----
Evt.StrikerCompat.TankHit.OnServerEvent:Connect(function(Player, Tank, dg, damage, Id)
	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "no jimmy, you can't make all striker tanks go boom")
		end
		return
	end
	if 0 < dg.Value then
		if dg.Value > damage then
			dg.Value = dg.Value - damage
		else
			dg.Value = 0
		end
	end
end)

--End Striker Compat Functions----

function OffHitCF(Hit, Off)
	if Hit == workspace.Terrain then
		return Off
	else
		return Hit.CFrame * Off
	end
end



Evt.Hit2.OnServerEvent:Connect(function(Player, HitPart, Offset, Material, Settings, Id, BulletPower, HitType)
	--print("Hit Event from: "..Player.Name)

	if not Player or not HitPart then
		return
	end

	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "don't try to make everyone explode next time")
		end
		return
	end

	Evt.Hit2:FireAllClients(Player, HitPart, Offset, Material, Settings, BulletPower, HitType)

	if HitPart.Parent and (HitPart.Parent:FindFirstChild("DestroyableLight") or HitPart.Parent.Name == "DestroyableLight") then
		for _,light in pairs(HitPart.Parent:GetDescendants()) do
			if light:IsA("Light") then
				light.Enabled = false
			end
		end
	elseif HitPart.Name == "DestroyableLight" then
		for _,light in pairs(HitPart:GetDescendants()) do
			if light:IsA("Light") then
				light.Enabled = false
			end
		end
	end

	if HitPart.Name == "BreakableObj" then --Name of the part that's breakable.
		local BreakingPoint = HitPart:FindFirstChild("BreakingPoint") --Finds the Breaking Point Attachment.
		if not BreakingPoint or not BreakingPoint:IsA("Attachment") then
			BreakingPoint = Instance.new("Attachment")
			BreakingPoint.Name = "BreakingPoint"
		end
		BreakingPoint.WorldPosition = OffHitCF(HitPart, Offset).Position -- Break position = bullet hit posisiton. 
		--BreakingPoint.WorldPosition = Position -- Break position = bullet hit posisiton. 
		--BreakingPoint.Position = Vector3.new(0, BreakingPoint.Position.Y, BreakingPoint.Position.Z) 

		BreakModule.FracturePart(HitPart) -- Calls the module that will be given on the bottom of this message.
	end

	if Settings.ExplosiveHit then

		local Hitmark = Instance.new("Attachment")
		Hitmark.CFrame = OffHitCF(HitPart, Offset)
		Hitmark.Parent = AttachmentsFolder
		Debris:AddItem(Hitmark, 5)

		local Exp = Instance.new("Explosion")
		Exp.BlastPressure = Settings.ExPressure
		Exp.BlastRadius = Settings.ExpRadius
		Exp.DestroyJointRadiusPercent = Settings.DestroyJointRadiusPercent
		Exp.ExplosionType = Enum.ExplosionType.NoCraters
		Exp.Position = Hitmark.Position
		Exp.Parent = Hitmark

		if Settings.ExplosionDamagesTerrain then
			local Exp2 = Instance.new("Explosion")
			Exp2.BlastPressure = 0
			Exp2.BlastRadius = Settings.TerrainDamageRadius
			Exp2.DestroyJointRadiusPercent = 0
			Exp2.Visible = false
			Exp2.Position = Hitmark.Position
			Exp2.Parent = Hitmark
		end


		local dm = Settings.ExpSoundDistanceMult or 1
		local vm = Settings.ExpSoundVolumeMult or 1
		local S = Instance.new("Sound")
		S.RollOffMinDistance = 40 * dm
		S.RollOffMaxDistance = 400 * dm
		S.RollOffMode = Enum.RollOffMode.InverseTapered
		S.SoundId = "rbxassetid://".. Explosion[math.random(1, 7)]
		S.PlaybackSpeed = math.random(30,55)/40
		S.Volume = 2 * vm
		S.Parent = Hitmark

		local S2 = Instance.new("Sound")
		S2.RollOffMinDistance = 400 * dm
		S2.RollOffMaxDistance = 8000 * dm
		S2.RollOffMode = Enum.RollOffMode.InverseTapered
		S2.SoundId = S.SoundId
		S2.PlaybackSpeed = S.PlaybackSpeed * 0.95
		S2.Volume = 0.4 * vm

		local mod = Instance.new("EqualizerSoundEffect")
		mod.HighGain = -36
		mod.MidGain = -3
		mod.LowGain = 3
		mod.Parent = S2

		S2.Parent = Hitmark
		
		
		
		Evt.FireSound:FireAllClients(nil, "Play", S, Hitmark.Position)
		Evt.FireSound:FireAllClients(nil, "Play", S2, Hitmark.Position)

		Exp.Hit:connect(function(hitPart, partDistance)
			local humanoid = hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid")
			if humanoid then
				local distance_factor = partDistance / Settings.ExpRadius    -- get the distance as a value between 0 and 1
				distance_factor = 1 - distance_factor                         -- flip the amount, so that lower == closer == more damage
				if distance_factor > 0 then
					humanoid:TakeDamage(Settings.ExplosionDamage*distance_factor)                -- 0: no damage; 1: max damage
				end
			end
		end)
	end
end)

Evt.LauncherHit.OnServerEvent:Connect(function(Player, Position, HitPart, Normal)
	Evt.LauncherHit:FireAllClients(Player, Position, HitPart, Normal)
end)

Evt.Whizz.OnServerEvent:Connect(function(Player, Target, btype, bspeed, loud, dist, maxdist)
	--print("Whizz Event from: "..Player.Name.." to: "..Target.Name)
	Evt.Whizz:FireClient(Target, btype, bspeed, loud, dist, maxdist)
end)

Evt.RicoSound.OnServerEvent:Connect(function(Player,Pos)
	--print("Ricochet Sound Event from: "..Player.Name)
	Evt.RicoSound:FireAllClients(Player,Pos)
end)

Evt.StanceSound.OnServerEvent:Connect(function(Player,id)
	--print("Stance Sound Event from: "..Player.Name)
	Evt.StanceSound:FireAllClients(Player,id)
end)

-- new suppression server event...
Evt.Suppression.OnServerEvent:Connect(function(Player, Target, Intensity, Tempo)
	--print("Suppression Event from: "..Player.Name.." to: "..Target.Name)
	Evt.Suppression:FireClient(Target, Intensity, Tempo)
end)


Evt.ServerBullet.OnServerEvent:connect(function(Player, ID, Origin, BDrop, Velocity, MaxDist, Tracer, TracerColor, BulletFlare, BulletFlareColor, TracerExtra, BulletLight, BulletLightExtra)
	Evt.ServerBullet:FireAllClients(Player, ID, Origin, BDrop, Velocity, MaxDist, Tracer, TracerColor, BulletFlare, BulletFlareColor, TracerExtra, BulletLight, BulletLightExtra)
end)

function CreateFakeArm(char, arm)
	local part = char:FindFirstChild("Fake"..arm.Name)
	if not part then
		part = arm:Clone()
		part.Name = "Fake"..arm.Name
		part:ClearAllChildren()
		part.Transparency = 1
		part.Size = arm.Size
		part.CanCollide = false
	end

	local weld = part:FindFirstChild(arm.Name)
	if not weld then
		weld = Instance.new("Weld")
		weld.Name = arm.Name
		weld.Part0 = part
		weld.Part1 = arm
		weld.C0 = CFrame.new()
		weld.C1 = CFrame.new()
		weld.Parent = part
	end

	part.Parent = char

	return part
end

Evt.Equipar.OnServerEvent:Connect(function(Player,Arma)

	local Head = Player.Character:FindFirstChild('Head')

	if Player.Character:FindFirstChild('Holst' .. Arma.Name) then
		Player.Character['Holst' .. Arma.Name]:Destroy()
	end

	if not GunModelServer:FindFirstChild(Arma.Name) then
		warn("Didn't find gun server model: ".. Arma.Name)
		return
	end
	local ServerGun = GunModelServer:FindFirstChild(Arma.Name):clone()
	ServerGun.Name = 'S' .. Arma.Name
	for _, Part in pairs(ServerGun:GetDescendants()) do
		if Part:IsA('BasePart') then
			Part:SetAttribute("FPInvis", true)
		end
	end;
	local grip = ServerGun:FindFirstChild("Grip")
	if not grip then
		warn("Didn't find grip on gun server model: ".. Arma.Name)
		return
	end
	local Settings = require(Arma.ACS_Modulo.Variaveis:WaitForChild("Settings"))

	Arma.ACS_Modulo.Variaveis.BType.Value = Settings.BulletType

	local AnimBase = Instance.new("Part")
	AnimBase.FormFactor = "Custom"
	AnimBase.CanCollide = false
	AnimBase.Transparency = 1
	AnimBase.Anchored = false
	AnimBase.Name = "AnimBase"
	AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
	AnimBase.Parent = Player.Character

	local AnimBaseW = Instance.new("Motor6D")
	AnimBaseW.Part0 = AnimBase
	AnimBaseW.Part1 = Head
	AnimBaseW.Parent = AnimBase
	AnimBaseW.Name = "AnimBaseW"



	local char = Player.Character

	local RUA = char.RightUpperArm
	local LUA = char.LeftUpperArm
	local RLA = char.RightLowerArm
	local LLA = char.LeftLowerArm
	local RH = char.RightHand
	local LH = char.LeftHand



	local RightS = RUA.RightShoulder
	local LeftS = LUA.LeftShoulder

	local RightE = Player.Character.RightLowerArm.RightElbow
	local LeftE = Player.Character.LeftLowerArm.LeftElbow

	local RightW = Player.Character.RightHand.RightWrist
	local LeftW = Player.Character.LeftHand.LeftWrist



	local FRUA = CreateFakeArm(char,RUA)
	local FLUA = CreateFakeArm(char,LUA)
	local FRLA = CreateFakeArm(char,RLA)
	local FLLA = CreateFakeArm(char,LLA)
	local FRH = CreateFakeArm(char,RH)
	local FLH = CreateFakeArm(char,LH)


	-- ACS R6 settings compat

	local SV_RightArmPos = Settings.SV_RightArmPos or Settings.RightArmPos or CFrame.new()
	local SV_RightElbowPos = Settings.SV_RightElbowPos or CFrame.new()
	local SV_RightWristPos = Settings.SV_RightWristPos or CFrame.new()

	local SV_LeftArmPos = Settings.SV_LeftArmPos or Settings.LeftArmPos or CFrame.new()
	local SV_LeftElbowPos = Settings.SV_LeftElbowPos or CFrame.new()
	local SV_LeftWristPos = Settings.SV_LeftWristPos or CFrame.new()




	local ruaw = Instance.new("Motor6D")
	ruaw.Name = "RAW"
	ruaw.Part0 = AnimBase
	ruaw.Part1 = FRUA
	ruaw.Parent = AnimBase
	ruaw.C1 = SV_RightArmPos
	if not Settings.SV_RightArmPos and Settings.RightArmPos then
		ruaw.C0 = CFrame.new(0, 0, 0.4155)
	end
	RightS.Part1 = nil
	RightS.Enabled = false

	local rlaw = Instance.new("Motor6D")
	rlaw.Name = "RLAW"
	rlaw.Part0 = FRUA
	rlaw.Part1 = FRLA
	rlaw.Parent = AnimBase
	rlaw.C1 = CFrame.new(0,RUA.Size.Y/2+.008,0) * SV_RightElbowPos
	RightE.Part1 = nil
	RightE.Enabled = false

	local rhw = Instance.new("Motor6D")
	rhw.Name = "RHW"
	rhw.Part0 = FRLA
	rhw.Part1 = FRH
	rhw.Parent = AnimBase
	rhw.C1 = CFrame.new(0,RLA.Size.Y/2+.1,0) * SV_RightWristPos
	RightW.Part1 = nil
	RightW.Enabled = false

	local luaw = Instance.new("Motor6D")
	luaw.Name = "LAW"
	luaw.Part0 = AnimBase
	luaw.Part1 = FLUA
	luaw.Parent = AnimBase
	luaw.C1 = SV_LeftArmPos
	if not Settings.SV_LeftArmPos and Settings.LeftArmPos then
		luaw.C0 = CFrame.new(0, 0, 0.4155)
	end
	LeftS.Part1 = nil
	LeftS.Enabled = nil

	local llaw = Instance.new("Motor6D")
	llaw.Name = "LLAW"
	llaw.Part0 = FLUA
	llaw.Part1 = FLLA
	llaw.Parent = AnimBase
	llaw.C1 = CFrame.new(0,LUA.Size.Y/2+.008,0) * SV_LeftElbowPos
	LeftE.Part1 = nil
	LeftE.Enabled = false

	local lhw = Instance.new("Motor6D")
	lhw.Name = "LHW"
	lhw.Part0 = FLLA
	lhw.Part1 = FLH
	lhw.Parent = AnimBase
	lhw.C1 = CFrame.new(0,LLA.Size.Y/2+.1,0) * SV_LeftWristPos
	LeftW.Part1 = nil
	LeftW.Enabled = false

	ServerGun.Parent = Player.Character

	-- copied
	for _, Part in pairs(ServerGun:GetChildren()) do
		if not Part:IsA("BasePart") or Part.Name == "Grip" then
			-- do nothing
		elseif Part.Name == "Bolt" or Part.Name == "Slide" then
			if ServerGun:FindFirstChild("BoltHinge") then
				if ServerGun.BoltHinge:FindFirstChild("BoltOnly") and Part.Name == "Slide" then
				else
					Utils.WeldComplex(ServerGun.BoltHinge, Part, grip)
				end
			else
				Utils.WeldComplex(grip, Part, grip)
			end

		elseif Part.Name == "Lid" then
			local LidHinge = ServerGun:FindFirstChild("LidHinge")
			if LidHinge then
				Utils.Weld(LidHinge, Part, Part)
			else
				Utils.Weld(grip, Part, Part)
			end

		elseif Part:FindFirstChild("HingeMotor") then
			local hinge = Part.HingeMotor.Value
			Utils.Weld(hinge, Part, Part)

		else
			Utils.Weld(grip, Part, Part)
		end
	end

	local GripW = Instance.new('Motor6D')
	GripW.Name = 'GripW'
	GripW.Parent = grip
	GripW.Part0 = FRH
	GripW.Part1 = grip
	GripW.C0 = ((Settings.SV_GunPos ~= nil) and Settings.SV_GunPos * CFrame.Angles(0, math.rad(90), 0) or (Settings.ServerGunPos ~= nil) and Settings.ServerGunPos * CFrame.new(0,0,0.85) or CFrame.new())
	GripW.C1 = CFrame.new()

	for i, part in pairs(ServerGun:GetChildren()) do
		if part:IsA('BasePart') then
			part.Anchored = false
			part.CanCollide = false
		end
	end

end)

Evt.SilencerEquip.OnServerEvent:Connect(function(Player, Arma, Silencer)
	local Arma = Player.Character['S' .. Arma.Name]

	local SilencerPart = FindSilencer(Arma)
	if Silencer then
		SilencerPart.Transparency = 0
	else
		SilencerPart.Transparency = 1
	end

end)



function DestroyFakeArm(char, ArmName)
	while true do
		local fakearm = char:FindFirstChild("Fake" .. ArmName)
		if fakearm then
			fakearm:Destroy()
		else
			return
		end
	end
end

local HolsteredPlayers = {}
local HolstBodyTable = {
	Torso = "UpperTorso",
	["Left Leg"] = "LeftUpperLeg",
	["Right Leg"] = "RightUpperLeg",
	["Left Arm"] = "LeftLowerArm",
	["Right Arm"] = "RightLowerArm",
}

Evt.Desequipar.OnServerEvent:Connect(function(Player, Arma, VarDict)
	
	if VarDict then
		OnRecarregar(Player, Arma, VarDict)
	end

	local char = Player.Character
	if not char then
		return
	end

	local Humanoid = char:FindFirstChild("Humanoid")
	local ArmaModel = char:FindFirstChild('S' .. Arma.Name)

	local Var = Arma.ACS_Modulo.Variaveis
	local Settings = require(Var.Settings)
	if not ServerConfig.DisableHolster and Settings.EnableHolster and Humanoid and Humanoid.Health > 0 and Player.Backpack:FindFirstChild(Arma.Name) then

		local holsterGun = GunModelHolster:FindFirstChild(Arma.Name)
		if not holsterGun then
			holsterGun = GunModelServer:FindFirstChild(Arma.Name)
		end
		local hModel = holsterGun:Clone()
		local hGrip = hModel.Grip
		hModel.PrimaryPart = hGrip
		hModel.Parent = char
		hModel.Name = 'Holst' .. Arma.Name

		local holstToBody = Settings.HolsterTo
		
		local BodyPart = HolstBodyTable[holstToBody]
		if BodyPart then
			holstToBody = BodyPart
		end

		for index, part in pairs(hModel:GetDescendants()) do
			if part:IsA('BasePart') and part.Name ~= 'Grip' then
				Weld(part, hGrip)
			end
		end
		
		Weld(hGrip, char[holstToBody], CFrame.new(), Settings.HolsterPos)

		for index, part in pairs(hModel:GetDescendants()) do part:SetAttribute("FPInvis", false)
			if part:IsA('BasePart') then
				part.Anchored = false
				part.CanCollide = false
			end
		end
		
		
		
		if ServerConfig.LimitHolster then
			local HolstProfile = HolsteredPlayers[Player.Name]
			if not HolstProfile then
				HolstProfile = {}
				HolsteredPlayers[Player.Name] = HolstProfile
			end

			if Settings.GunType ~= 0 then
				local model = HolstProfile.Primary
				if model then
					model:Destroy()end
				
				
				HolstProfile.Primary = hModel
				
			else
				local model = HolstProfile.Secondary
				if model then
					model:Destroy()
				end
				
				HolstProfile.Secondary = hModel
			end
		end
	end

	if ArmaModel then
		ArmaModel:Destroy()
		char.AnimBase:Destroy()
	end



	local rs = char.RightUpperArm:FindFirstChild("RightShoulder")
	if rs then
		rs.Part1 = char.RightUpperArm
		rs.Enabled = true
	end

	local ls = char.LeftUpperArm:FindFirstChild("LeftShoulder")
	if ls then
		ls.Part1 = char.LeftUpperArm
		ls.Enabled = true
	end

	local re = char.RightLowerArm:FindFirstChild("RightElbow")
	if re then
		re.Part1 = char.RightLowerArm
		re.Enabled = true
	end
	
	local le = char.LeftLowerArm:FindFirstChild("LeftElbow")
	if le then
		le.Part1 = char.LeftLowerArm
		le.Enabled = true
	end
	
	local rw = char.RightHand:FindFirstChild("RightWrist")
	if rw then
		rw.Part1 = char.RightHand
		rw.Enabled = true
	end
	
	local lw = char.LeftHand:FindFirstChild("LeftWrist")
	if lw then
		lw.Part1 = char.LeftHand
		lw.Enabled = true
	end

	DestroyFakeArm(char,"RightUpperArm")
	DestroyFakeArm(char,"RightLowerArm")
	DestroyFakeArm(char,"RightHand")
	DestroyFakeArm(char,"LeftUpperArm")
	DestroyFakeArm(char,"LeftLowerArm")
	DestroyFakeArm(char,"LeftHand")
end)

Evt.Holster.OnServerEvent:Connect(function(Player, ArmaName)
	if Player.Character:FindFirstChild('Holst' .. ArmaName) then
		Player.Character['Holst' .. ArmaName]:Destroy()
	end
end)

Evt.Atirar.OnServerEvent:Connect(function(Player, ArmaName, dur, objs)
	--print("Atirar Event Fire")
	Evt.Atirar:FireAllClients(Player, ArmaName, dur, objs)

end)

Evt.FireSound.OnServerEvent:Connect(function(Player, Mode, Sound, Origin, objs)
	--print("FireSound Event")
	if Mode == "Pause" or Mode == "LoopStop" then
		Evt.FireSound:FireAllClients(Player, Mode, Sound, Origin, objs)
	else
		for i, plr in pairs(Players:GetPlayers()) do
			pcall(function() -- error proofing
				if (plr.Character.Head.Position - Origin).Magnitude <= Sound.RollOffMaxDistance then
					Evt.FireSound:FireClient(plr, Player, Mode, Sound, Origin, objs)
				end
			end)

		end
	end
end)

Evt.HeadRot.OnServerEvent:Connect(function(Player, CF, CF2)
	local char = Player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	Evt.HeadRot:FireAllClients(Player, CF, CF2)
end)

Evt.Stance.OnServerEvent:Connect(function(Player, Poses)
	if not Poses then
		return
	end

	local Character = Player.Character
	if not Character or Character.Humanoid.Health <= 0 then
		return
	end

	local AnimBase = Character:FindFirstChild("AnimBase")
	if not AnimBase then
		return
	end

	local Right_Weld = AnimBase:FindFirstChild("RAW")
	local Left_Weld = AnimBase:FindFirstChild("LAW")
	if not Right_Weld or not Left_Weld then
		return
	end

	Evt.Stance:FireAllClients(Player, Poses)
end)

Evt.Damage.OnServerEvent:Connect(function(Player, VitimaHuman, Damage, VestDmg, HelmetDmg, Id)

	-- no player? don't even bother
	if not Player then
		return
	end

	-- failed sanity check? kick
	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "good luck trying to loopkill everyone with your exploits")
		end
		return
	end

	if VitimaHuman then
		if VitimaHuman.Parent:FindFirstChild("Saude") then
			local Protecao = VitimaHuman.Parent.Saude.Protecao
			local Colete = Protecao.VestVida
			local Capacete = Protecao.HelmetVida
			
			Colete.Value = Colete.Value - VestDmg
			Capacete.Value = Capacete.Value - HelmetDmg
		end
		
		local prevhealth = VitimaHuman.Health
		VitimaHuman:TakeDamage(Damage)
		
		if VitimaHuman.Health <= 0 and prevhealth > 0 then
			local c = Instance.new("ObjectValue")
			c.Name = "creator"
			c.Value = Player
			game.Debris:AddItem(c, 3)
			c.Parent = VitimaHuman
		end
	end
end)

--[[Evt.CreateOwner.OnServerEvent:Connect(function(Player,VitimaHuman)
	local c = Instance.new("ObjectValue")
	c.Name = "creator"
	c.Value = Player
	game.Debris:AddItem(c, 3)
	c.Parent = VitimaHuman
end)]]

-------------------------------------------------------------------
-----------------------[MEDSYSTEM]---------------------------------
-------------------------------------------------------------------



Evt.Ombro.OnServerEvent:Connect(function(Player,Vitima)
	local Nombre
	for i, plr in pairs(game.Players:GetChildren()) do
		if plr:IsA('Player') and plr ~= Player and plr.Name == Vitima then
			if plr.Team == Player.Team then
				Nombre = Player.Name
			else
				Nombre = "Someone"
			end
			Evt.Ombro:FireClient(plr, Nombre)
		end
	end
end)

Evt.Target.OnServerEvent:Connect(function(Player,Vitima)
	Player.Character.Saude.Variaveis.PlayerSelecionado.Value = Vitima
end)

Evt.Render.OnServerEvent:Connect(function(Player,Status,Vitima)
	if Vitima == "N/A" then
		Player.Character.Saude.Stances.Rendido.Value = Status
		
	else
		local VitimaTop = game.Players:FindFirstChild(Vitima)
		local VStances = VitimaTop.Character.Saude.Stances
		
		if VStances.Algemado.Value == false then
			VStances.Rendido.Value = Status
			VitimaTop.Character.Saude.Variaveis.HitCount.Value = 0
		end
	end
end)

Evt.Drag.OnServerEvent:Connect(function(player)
	local Char = player.Character
	local Human = Char.Humanoid
	local Torso = Char.UpperTorso
	local Saude = Char.Saude
	local Var = Saude.Variaveis
	
	local enabled = Var.Doer
	local MLs = Var.MLs
	local Caido = Saude.Stances.Caido
	local target = Var.PlayerSelecionado
	
	if Caido.Value or target.Value == "N/A" or enabled.Value then return end
	
	

	local Player2 = Players:FindFirstChild(target.Value)
	local P2Char = Player2.Character
	local P2Human = P2Char.Humanoid
	local P2Saude = Player2.Saude
	local P2Stances = P2Saude.Stances

	local P2Ferido = P2Stances.Ferido
	local P2Caido = P2Stances.Caido
	local P2Sang = P2Saude.Variaveis.Sangue
	local P2Cuffed = P2Stances.Algemado
	
	if not P2Caido.Value and not P2Cuffed.Value then return end



	enabled.Value = true
	local P2Torso = P2Char.UpperTorso

	coroutine.wrap(function()
		local TorsoCF = CFrame.new(0, 0.75, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(90))
		while target.Value ~= "N/A" and P2Caido.Value and P2Human.Health > 0 and Human.Health > 0 and not Caido.Value or target.Value ~= "N/A" and P2Cuffed.Value  do
			task.wait()
			pcall(function()
				enabled.Value = true
				P2Torso.Anchored = true
				P2Torso.CFrame = Torso.CFrame * TorsoCF
			end)
		end
		enabled.Value = false
		P2Torso.Anchored = false
	end)()

	enabled.Value = false
end)

Evt.Squad.OnServerEvent:Connect(function(Player, SquadName, SquadColor)
	local FireTeam = Player.Character.Saude.FireTeam
	FireTeam.SquadName.Value = SquadName
	FireTeam.SquadColor.Value = SquadColor
end)

Evt.Afogar.OnServerEvent:Connect(function(Player)
	Player.Character.Humanoid.Health = 0
end)



------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------



local Functions = Evt.MedSys
local FunctionsMulti = Evt.MedSys.Multi

local Bandage = Functions.Bandage
local Splint = Functions.Splint
local PainRelief = Functions.PainRelief
local Energy = Functions.Energy
local Tourniquet = Functions.Tourniquet

local Compress_Multi = FunctionsMulti.Compress
local Bandage_Multi = FunctionsMulti.Bandage
local Splint_Multi = FunctionsMulti.Splint
local EnergyShot_Multi = FunctionsMulti.EnergyShot
local Tranquilizer_Multi = FunctionsMulti.Tranquilizer
local Suppressant_Multi = FunctionsMulti.Suppressant
local BloodBag_Multi = FunctionsMulti.BloodBag
local Tourniquet_Multi = FunctionsMulti.Tourniquet
local prolene_Multi = FunctionsMulti.prolene
local o2_Multi = FunctionsMulti.o2
local defib_Multi = FunctionsMulti.defib
local npa_Multi = FunctionsMulti.npa
local catheter_Multi = FunctionsMulti.catheter
local etube_Multi = FunctionsMulti.etube
local nylon_Multi = FunctionsMulti.nylon
local balloon_Multi = FunctionsMulti.balloon
local skit_Multi = FunctionsMulti.skit
local bvm_Multi = FunctionsMulti.bvm
local nrb_Multi = FunctionsMulti.nrb
local scalpel_Multi = FunctionsMulti.scalpel
local suction_Multi = FunctionsMulti.suction
local clamp_Multi = FunctionsMulti.clamp
local prolene5_Multi = FunctionsMulti.prolene5
local drawblood_Multi = FunctionsMulti.drawblood


local Algemar = Functions.Algemar
local Fome = Functions.Fome
local Stance = Evt.MedSys.Stance
local Collapse = Functions.Collapse
local rodeath = Functions.rodeath
local Reset = Functions.Reset
local TS = game:GetService("TweenService")




Bandage.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local Sangrando = Human.Parent.Saude.Stances.Sangrando
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Ferido = Human.Parent.Saude.Stances.Ferido
	local bbleeding = Human.Parent.Saude.Stances.bbleeding

	local Bandages = Human.Parent.Saude.Kit.Bandage

	if enabled.Value == false and Caido.Value == false  then

		if Bandages.Value >= 1 and Sangrando.Value == true then 
			enabled.Value = true
			
			task.wait(.3)
			Sangrando.Value = false
			Bandages.Value = Bandages.Value - 1
			
			task.wait(2)
			enabled.Value = false

		end	
	end	
end)

Splint.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local Sangrando = Human.Parent.Saude.Stances.Sangrando
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Ferido = Human.Parent.Saude.Stances.Ferido

	local Bandages = Human.Parent.Saude.Kit.Splint

	if enabled.Value == false and Caido.Value == false  then

		if Bandages.Value >= 1 and Ferido.Value == true  then
			enabled.Value = true
			
			task.wait(.3)
			Ferido.Value = false
			Bandages.Value = Bandages.Value - 1
			
			task.wait(2)
			enabled.Value = false

		end	
	end	
end)

PainRelief.OnServerEvent:Connect(function(player)
	local Char = player.Character
	local Human = Char.Humanoid
	local Saude = Char.Saude
	local Var = Saude.Variaveis
	local Stances = Saude.Stances
	
	local enabled = Var.Doer
	local Sangrando = Stances.Sangrando
	local MLs = Var.MLs
	local Dor = Var.Dor
	local Caido = Stances.Caido
	local Ferido = Stances.Ferido

	local Bandages = Human.Parent.Saude.Kit.PainRelief

	if enabled.Value == false and Caido.Value == false  then

		if Bandages.Value >= 1  and Dor.Value >= 1  then
			enabled.Value = true

			task.wait(.3)
			Dor.Value = Dor.Value - math.random(60, 75)
			Bandages.Value = Bandages.Value - 1

			task.wait(2)
			enabled.Value = false

		end	
	end	
end)

Energy.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local Sangrando = Human.Parent.Saude.Stances.Sangrando
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Dor = Human.Parent.Saude.Variaveis.Dor
	local Caido = Human.Parent.Saude.Stances.Caido
	local Ferido = Human.Parent.Saude.Stances.Ferido

	local Bandages = Human.Parent.Saude.Kit.Energy

	if enabled.Value == false and Caido.Value == false and Bandages.Value >= 1 then

		if Human.Health < Human.MaxHealth  then
			enabled.Value = true

			task.wait(.3)		

			Human.Health = Human.Health + (Human.MaxHealth/3)
			Bandages.Value = Bandages.Value - 1


			task.wait(2)
			enabled.Value = false

		end	
	end	
end)

Tourniquet.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local Sangrando = Human.Parent.Saude.Stances.Sangrando
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Dor = Human.Parent.Saude.Variaveis.Dor
	local Caido = Human.Parent.Saude.Stances.Caido
	local Ferido = Human.Parent.Saude.Stances.Ferido

	local Bandagens = Human.Parent.Saude.Kit.Tourniquet

	if Human.Parent.Saude.Stances.Tourniquet.Value == false then
		if enabled.Value == false and Bandagens.Value > 0 then
			enabled.Value = true

			task.wait(.3)		

			Human.Parent.Saude.Stances.Tourniquet.Value = true
			Bandagens.Value = Bandagens.Value - 1


			task.wait(2)
			enabled.Value = false

		end	
	else
		if enabled.Value == false then
			enabled.Value = true

			task.wait(.3)		

			Human.Parent.Saude.Stances.Tourniquet.Value = false
			Bandagens.Value = Bandagens.Value + 1


			task.wait(2)
			enabled.Value = false
		end
	end
end)

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------



Compress_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local isdead = Human.Parent.Saude.Stances.rodeath

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local cpr = PlHuman.Parent.Saude.Stances.cpr
		local isdead = PlHuman.Parent.Saude.Stances.rodeath

		if enabled.Value == false then

			if isdead.Value == true and (Sangrando.Value == false or Human.Parent.Saude.Stances.Tourniquet.Value == true) then 
				enabled.Value = true



				PlHuman.Health = PlHuman.Health + 5




				task.wait(0.5)

				enabled.Value = false



			end
		end


	end
end)

Bandage_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.Bandage

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido

		if enabled.Value == false then

			if Item.Value >= 1 and Sangrando.Value == true then 
				enabled.Value = true

				task.wait(.3)		

				local number = math.random(1, 2)

				if number == 1 then		
					Sangrando.Value = false
				end

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

scalpel_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.scalpel

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local cutopen = PlHuman.Parent.Saude.Stances.cutopen
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local o2 = PlHuman.Parent.Saude.Stances.o2
		local caido = PlHuman.Parent.Saude.Stances.Caido

		if enabled.Value == false and cutopen.Value == false and caido.Value == true and o2.Value == true then

			if Item.Value >= 1 then 
				enabled.Value = true

				task.wait(.3)		

				cutopen.Value = true



				task.wait(2)

				enabled.Value = false
			end	

		end	
	end
end)

suction_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.suction

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local npa = PlHuman.Parent.Saude.Stances.npa
		local etube = PlHuman.Parent.Saude.Stances.etube
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.cutopen.Value == true and PlHuman.Parent.Saude.Stances.o2.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 then 
					--if Item.Value > 0 then 

					enabled.Value = true

					task.wait(.1)		

					PlHuman.Parent.Saude.Stances.suction.Value = true	
					task.wait(3.5)	

					PlHuman.Parent.Saude.Stances.suction.Value = false


					task.wait(0.1)
					enabled.Value = false
				end
			end	
		end
	end

end)

clamp_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.clamp

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local npa = PlHuman.Parent.Saude.Stances.npa
		local etube = PlHuman.Parent.Saude.Stances.etube
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.cutopen.Value == true and PlHuman.Parent.Saude.Stances.o2.Value == true and PlHuman.Parent.Saude.Stances.suction.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 then 
					--if Item.Value > 0 then 

					enabled.Value = true

					task.wait(.1)		

					PlHuman.Parent.Saude.Stances.clamped.Value = true	
					task.wait(5.5)	

					PlHuman.Parent.Saude.Stances.clamped.Value = false


					task.wait(0.1)
					enabled.Value = false
				end
			end	
		end
	end

end)



catheter_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.catheter


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local balloonbleed = PlHuman.Parent.Saude.Stances.balloonbleed
		local balloon = PlHuman.Parent.Saude.Stances.balloon
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local cutopen = PlHuman.Parent.Saude.Stances.cutopen
		local suction = PlHuman.Parent.Saude.Stances.suction

		if PlHuman.Parent.Saude.Stances.catheter.Value == false and PlHuman.Parent.Saude.Stances.o2.Value == true and cutopen.Value == true and suction.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 and (Sangrando.Value == true or bbleeding.Value == true) then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.catheter.Value = true	


					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.balloon.Value == false then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.catheter.Value = false		

					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

balloon_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.catheter


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local balloonbleed = PlHuman.Parent.Saude.Stances.balloonbleed
		local repaired = PlHuman.Parent.Saude.Stances.repaired
		local catheter = PlHuman.Parent.Saude.Stances.catheter
		local o2l = PlHuman.Parent.Saude.Stances.o2
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.balloon.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (Sangrando.Value == true or bbleeding.Value == true) and o2l.Value == true and catheter.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.balloon.Value = true	
					Sangrando.Value = false
					bbleeding.Value = false	




					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.balloon.Value == true and repaired.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.balloon.Value = false		


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)


prolene_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.prolene


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local o2l = PlHuman.Parent.Saude.Stances.o2
		local balloonbleed = PlHuman.Parent.Saude.Stances.balloonbleed
		local repaired = PlHuman.Parent.Saude.Stances.repaired
		local balloon = PlHuman.Parent.Saude.Stances.balloon


		if enabled.Value == false then

			if Item.Value > 0 and o2l.Value == true and balloon.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then 
				enabled.Value = true

				task.wait(2)		

				Sangrando.Value = false
				bbleeding.Value = false
				balloonbleed.Value = false
				repaired.Value = true
				Item.Value = Item.Value - 1



				task.wait(2)

				enabled.Value = false

			end	

		end	
	end
end)

prolene5_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.prolene5


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid
		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local o2l = PlHuman.Parent.Saude.Stances.o2
		local balloonbleed = PlHuman.Parent.Saude.Stances.balloonbleed
		local repaired = PlHuman.Parent.Saude.Stances.repaired
		local balloon = PlHuman.Parent.Saude.Stances.balloon
		local clamped = PlHuman.Parent.Saude.Stances.clamped
		local surg2 = PlHuman.Parent.Saude.Stances.surg2


		if enabled.Value == false then

			if Item.Value > 0 and o2l.Value == true and clamped.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then 

				enabled.Value = true

				task.wait(2)		


				surg2.Value = false
				repaired.Value = true
				Item.Value = Item.Value - 1



				task.wait(2)

				enabled.Value = false

			end	

		end	
	end
end)

nylon_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.nylon


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local o2l = PlHuman.Parent.Saude.Stances.o2
		local balloonbleed = PlHuman.Parent.Saude.Stances.balloonbleed
		local repaired = PlHuman.Parent.Saude.Stances.repaired
		local balloon = PlHuman.Parent.Saude.Stances.balloon
		local catheter = PlHuman.Parent.Saude.Stances.catheter
		local cutopen = PlHuman.Parent.Saude.Stances.cutopen


		if enabled.Value == false then

			if Item.Value >= 1 and o2l.Value == true and repaired.Value == true and catheter.Value == false and cutopen.Value == true and PlHuman.Parent.Saude.Stances.Caido.Value == true then 
				enabled.Value = true

				task.wait(2)		



				repaired.Value = false
				cutopen.Value = false


				task.wait(2)
				Item.Value = Item.Value - 1
				enabled.Value = false

			end	

		end	
	end
end)


defib_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.defib


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local bbleeding = PlHuman.Parent.Saude.Stances.bbleeding
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local o2p = PlHuman.Parent.Saude.Stances.o2
		local isdead = PlHuman.Parent.Saude.Stances.rodeath
		local cpr = PlHuman.Parent.Saude.Stances.cpr
		local life = PlHuman.Parent.Saude.Stances.life


		if enabled.Value == false then

			if Item.Value >= 1 and o2p.Value == true and isdead.Value == true then 
				enabled.Value = true

				task.wait(1)		

				isdead.Value = false

				life.Value = true


				PlHuman.Health = PlHuman.Health + 100



				task.wait(1)
				enabled.Value = false

			end	
		end	
	end
end)

Splint_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.Splint

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido

		if enabled.Value == false then

			if Item.Value >= 1 and Ferido.Value == true  then 
				enabled.Value = true

				task.wait(.3)		

				Ferido.Value = false		

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

Tourniquet_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.Tourniquet

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.Tourniquet.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.Tourniquet.Value = true		

					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.Tourniquet.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.Tourniquet.Value = false		

					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

skit_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.skit

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.skit.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.skit.Value = true		

					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.skit.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.skit.Value = false		


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

npa_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.npa

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.Saude.Stances.Caido
		local o2p = PlHuman.Parent.Saude.Stances.o2
		local nrb = PlHuman.Parent.Saude.Stances.nrb

		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.npa.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and faido.Value == false then 
					enabled.Value = true

					task.wait(.3)		


					PlHuman.Parent.Saude.Stances.npa.Value = true	


					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.npa.Value == true and nrb.Value == false then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.npa.Value = false	

					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

etube_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.etube

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.Saude.Stances.Caido
		local o2p = PlHuman.Parent.Saude.Stances.o2

		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.etube.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and faido.Value == true then 
					enabled.Value = true

					task.wait(.3)		


					PlHuman.Parent.Saude.Stances.etube.Value = true

					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.etube.Value == true and o2p.Value == false then 
					enabled.Value = true

					task.wait(.3)		


					PlHuman.Parent.Saude.Stances.etube.Value = false


					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

nrb_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.nrb

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.Saude.Stances.Caido
		local o2p = PlHuman.Parent.Saude.Stances.o2

		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.nrb.Value == false and PlHuman.Parent.Saude.Stances.npa.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					task.wait(.3)		


					PlHuman.Parent.Saude.Stances.nrb.Value = true

					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.nrb.Value == true and o2p.Value == false then 
					enabled.Value = true

					task.wait(.3)		


					PlHuman.Parent.Saude.Stances.nrb.Value = false


					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

o2_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.o2

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local npa = PlHuman.Parent.Saude.Stances.npa
		local nrb = PlHuman.Parent.Saude.Stances.nrb
		local etube = PlHuman.Parent.Saude.Stances.etube
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.o2.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (nrb.Value == true or etube.Value == true) then 
					--if Item.Value > 0 then 

					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.o2.Value = true		

					Item.Value = Item.Value - 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.Saude.Stances.o2.Value == true then
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.Saude.Stances.o2.Value = false		

					Item.Value = Item.Value + 1 


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)


bvm_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.bvm

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local npa = PlHuman.Parent.Saude.Stances.npa
		local etube = PlHuman.Parent.Saude.Stances.etube
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido


		if PlHuman.Parent.Saude.Stances.o2.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (npa.Value == true or etube.Value == true) then 
					--if Item.Value > 0 then 

					enabled.Value = true

					task.wait(.2)		

					PlHuman.Parent.Saude.Stances.o2.Value = true	
					task.wait(4.5)	

					PlHuman.Parent.Saude.Stances.o2.Value = false


					task.wait(0.2)
					enabled.Value = false
				end
			end	
		end
	end

end)



EnergyShot_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.EnergyShot
	local bbleeding = Human.Parent.Saude.Stances.bbleeding


	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local isdead = PlHuman.Parent.Saude.Stances.rodeath
		local skit = PlHuman.Parent.Saude.Stances.skit

		if enabled.Value == false then
			--if enabled.Value == false and bbleeding.Value == false then
			if Item.Value >= 1 and PlCaido.Value == true and skit.Value == true then 
				enabled.Value = true



				task.wait(.3)		

				if Dor.Value > 0 then
					Dor.Value = Dor.Value + math.random(10,20)
				end

				if Sangrando.Value == true then
					MLs.Value = MLs.Value + math.random(10,35)
				end

				isdead.Value = false

				PlCaido.Value = false	

				PlHuman.PlatformStand = false
				PlHuman.AutoRotate = true		

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

Tranquilizer_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.Tranquilizer
	local bbleeding = Human.Parent.Saude.Stances.bbleeding

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local skit = PlHuman.Parent.Saude.Stances.skit

		if enabled.Value == false then
			--if enabled.Value == false and bbleeding.Value == false then
			if Item.Value >= 1 and PlCaido.Value == false and skit.Value == true then 
				enabled.Value = true


				task.wait(.3)		



				PlCaido.Value = true	
				PlHuman.PlatformStand = true
				PlHuman.AutoRotate = false

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

Suppressant_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.Suppressant

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local skit = PlHuman.Parent.Saude.Stances.skit

		if enabled.Value == false then

			if Item.Value >= 1 and Dor.Value >= 1 and skit.Value == true then 
				enabled.Value = true

				task.wait(.3)		

				Dor.Value = Dor.Value - math.random(100,150)

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

BloodBag_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local MLs = Human.Parent.Saude.Variaveis.MLs
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.SacoDeSangue

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local blood = PlHuman.Parent.Saude.Variaveis.Sangue
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local skit = PlHuman.Parent.Saude.Stances.skit

		if enabled.Value == false then

			if Item.Value >= 1 and skit.Value == true then 
				enabled.Value = true

				task.wait(.3)		

				blood.Value = blood.Value + 2000

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

drawblood_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.Saude.Variaveis.Doer
	local Caido = Human.Parent.Saude.Stances.Caido
	local Item = Human.Parent.Saude.Kit.SacoDeSangue

	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.Saude.Stances.Sangrando
		local MLs = PlHuman.Parent.Saude.Variaveis.MLs
		local Dor = PlHuman.Parent.Saude.Variaveis.Dor
		local blood = PlHuman.Parent.Saude.Variaveis.Sangue
		local Ferido = PlHuman.Parent.Saude.Stances.Ferido
		local PlCaido = PlHuman.Parent.Saude.Stances.Caido
		local skit = PlHuman.Parent.Saude.Stances.skit

		if not enabled.Value then

			if Item.Value < 10 and skit.Value then 
				enabled.Value = true

				task.wait(.3)		

				blood.Value = blood.Value - 2000

				Item.Value = Item.Value + 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)




------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

Collapse.OnServerEvent:Connect(function(player)
	local Char = player.Character
	local Human = Char.Humanoid
	local Saude = Char.Saude
	local Var = Saude.Variaveis
	local Stances = Saude.Stances
	
	local Dor = Var.Dor
	local Sangue = Var.Sangue

	local IsWounded = Stances.Caido
	local IsDead = Stances.rodeath

	if Sangue.Value <= 1250 or Dor.Value >= 600 or IsWounded.Value == true or IsDead.Value == true then -- Man this Guy's Really wounded,
		IsWounded.Value = true
		Human.PlatformStand = true
		Human.AutoRotate = false		
	elseif IsWounded.Value == false then -- YAY A MEDIC ARRIVED! =D
		Human.PlatformStand = false
		Human.AutoRotate = true

	end
end)



rodeath.OnServerEvent:Connect(function(player)
	local Char = player.Character
	local Human = Char.Humanoid
	local Saude = Char.Saude
	local Var = Saude.Variaveis
	local Stances = Saude.Stances
	
	local Dor = Var.Dor
	local Sangue = Var.Sangue

	local IsWounded = Stances.Caido
	local IsDead = Stances.rodeath
	local bleeding = Stances.Sangrando
	local bbleeding = Stances.bbleeding
	local cpr = Stances.cpr
	local dead = Stances.dead
	local life = Stances.life
	local Sangrando = Stances.Sangrando

	if IsDead.Value then
		life.Value = false
		IsWounded.Value = true
		--Sangrando.Value = true
		
		if Sangue.Value <= 0 then
			dead.Value = true	
			
			task.wait(1)
			Human.PlatformStand = false
			Human.AutoRotate = true	
			Human.Health = 0
			
		else
			task.wait(90)
			
			if Human.Health <= 1 then
				dead.Value = true
				Sangue.Value = 0	

				task.wait(1)
				Human.PlatformStand = false
				Human.AutoRotate = true	
				Human.Health = 0
			end
		end
	end

end)



Reset.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local target = Human.Parent.Saude.Variaveis.PlayerSelecionado

	target.Value = "N/A"
end)



------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- stance leaning event?
Stance.OnServerEvent:Connect(function(Player, Stances, Virar, Rendido)
	local char		= Player.Character
	if not char or char.Humanoid.Health <= 0 then return end

	local Human 	= char.Humanoid
	local Saude 	= char:FindFirstChild("Saude")

	local rua       = Player.Character:FindFirstChild("RightUpperArm")
	local lua       = Player.Character:FindFirstChild("LeftUpperArm")

	if not rua or not lua then return end

	local RootPart 	= char.HumanoidRootPart
	local LowerTorso= char.LowerTorso
	local UpperTorso= char.UpperTorso
	local RootJoint = LowerTorso.Root
	local WaistJ 	= UpperTorso.Waist
	local Neck 		= char.Head.Neck
	local RS 		= rua.RightShoulder
	local LS 		= lua.LeftShoulder
	local RH 		= char.RightUpperLeg.RightHip
	local RK 		= char.RightLowerLeg.RightKnee
	local LH 		= char.LeftUpperLeg.LeftHip
	local LK 		= char.LeftLowerLeg.LeftKnee

	local RightArm	= rua
	local LeftArm 	= lua
	local LeftLeg 	= char.LeftUpperLeg
	local RightLeg 	= char.RightUpperLeg

	local TInfo = TweenInfo.new(ServerConfig.StanceTime)

	if Stances == 2 and char then
		TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-Human.HipHeight - LowerTorso.Size.Y,Human.HipHeight)* CFrame.Angles(math.rad(-90),0,0)} ):Play()
		TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(15),0,0)} ):Play()
		TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)*CFrame.Angles(0,math.rad(-30),0)} ):Play()
		TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)*CFrame.Angles(0,math.rad(30),0)} ):Play()
		TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)} ):Play()
		TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)} ):Play()
	end
	if Virar == 1 then
		if Stances == 0 then
			TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(0,0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-(Human.HipHeight/3.5),0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)} ):Play()
		elseif Stances == 1 then

			TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(0,0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),0,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),0,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),0,0)} ):Play()
		end
	elseif Virar == -1 then
		if Stances == 0 then

			TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(0,0,math.rad(30))} ):Play()
			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-(Human.HipHeight/3.5),0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)} ):Play()
		elseif Stances == 1 then

			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),0,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),0,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),0,0)} ):Play()
		end
	elseif Virar == 0 then
		if Stances == 0 then

			TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)} ):Play()
			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-(Human.HipHeight/3.5),0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)} ):Play()
		elseif Stances == 1 then

			TS:Create(WaistJ, TInfo, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)} ):Play()
			TS:Create(RootJoint, TInfo, {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)} ):Play()
			TS:Create(RH, TInfo, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)} ):Play()
			TS:Create(LH, TInfo, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),0,0)} ):Play()
			TS:Create(RK, TInfo, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),0,0)} ):Play()
			TS:Create(LK, TInfo, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),0,0)} ):Play()
		end
	end

	local Algemado = Saude.Stances.Algemado.Value
	if Rendido and not Algemado then
		TS:Create(RS, TInfo, {C0 = CFrame.new(.9,0.75,0) * CFrame.Angles(math.rad(110),math.rad(120),math.rad(70))} ):Play()
		TS:Create(LS, TInfo, {C0 = CFrame.new(-.9,0.75,0) * CFrame.Angles(math.rad(110),math.rad(-120),math.rad(-70))} ):Play()

	elseif Algemado then
		TS:Create(RS, TInfo, {C0 = CFrame.new(.6,0.75,0) * CFrame.Angles(math.rad(240),math.rad(120),math.rad(100))} ):Play()
		TS:Create(LS, TInfo, {C0 = CFrame.new(-.6,0.75,0) * CFrame.Angles(math.rad(240),math.rad(-120),math.rad(-100))} ):Play()

	elseif Stances == 2 then
		TS:Create(RS, TInfo, {C0 = CFrame.new(0.9,0.3,-0.5) * CFrame.Angles(math.rad(-75),math.rad(120),math.rad(-150))} ):Play()
		TS:Create(LS, TInfo, {C0 = CFrame.new(-0.9,0.3,-0.5) * CFrame.Angles(math.rad(-75),math.rad(-120),math.rad(150))} ):Play()
	else
		TS:Create(RS, TInfo, {C0 = CFrame.new(.9,0.6,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LS, TInfo, {C0 = CFrame.new(-.9,0.6,0) * CFrame.Angles(math.rad(0),math.rad(-0),math.rad(0))} ):Play()
	end

end)

Evt.Anims.OnServerEvent:Connect(function(Player, Anim, Tool, VarDict)
	if not Tool then return end
	local var = Tool.ACS_Modulo.Variaveis
	local anims = var.ServerAnimations
	if not anims then return end

	local func = require(anims)[Anim]
	if not func then return end

	Evt.Anims:FireAllClients(Player, Anim, Tool, VarDict)
end)

Fome.OnServerEvent:Connect(function(Player)
	Player.Character.Saude.Stances.Caido.Value = true
end)


Algemar.OnServerEvent:Connect(function(Player,Status,Vitima,Type)
	local VS = Players:FindFirstChild(Vitima).Character.Saude.Stances
	if Type == 1 then
		VS.Rendido.Value = Status
	else
		VS.Algemado.Value = Status
	end
end)

Evt.DamageObject.OnServerEvent:Connect(function(Player,Id,health,dmg)
	if not Player then
		return
	end
	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "bro are you really that desperate to want to make that barrel explode")
		end
		return
	end

	health.Value = math.max(0,health.Value - dmg)
end)

----------------------------------------------------------------
--\\DOORS & BREACHING SYSTEM
----------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local DoorsFolder = ACS_Storage:FindFirstChild("Doors")
local DoorsFolderClone = DoorsFolder:Clone()
local BreachClone = ACS_Storage.Breach:Clone()

BreachClone.Parent = ServerStorage
DoorsFolderClone.Parent = ServerStorage

function ToggleDoor(Door)


	local Hinge = Door.Door:FindFirstChild("Hinge")
	if Hinge then

		local HingeConstraint = Hinge:FindFirstChildOfClass("HingeConstraint")

		if HingeConstraint then

			if Door:FindFirstChild("TargetAngle") then
				local TargetAngle = Door.TargetAngle

				if HingeConstraint.TargetAngle == TargetAngle.MaxValue then
					HingeConstraint.TargetAngle = TargetAngle.MinValue
				else
					HingeConstraint.TargetAngle = TargetAngle.MaxValue
				end

			else
				if HingeConstraint.TargetAngle == 0 then
					HingeConstraint.TargetAngle = -90
				else
					HingeConstraint.TargetAngle = 0
				end
			end
		else
			warn("Hinge at '"..Door:GetFullName().."' has no HingeConstraint object.")
		end

	else
		warn("Door named '"..Door:GetFullName().."' has no hinge part.")
	end

end


Players.PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(Message)
		if string.lower(Message) == "regenall" and Player == Players:GetPlayerByUserId(game.CreatorId) then
			DoorsFolder:ClearAllChildren()
			ACS_Storage.Breach:ClearAllChildren()

			local Doors = DoorsFolderClone:Clone()
			local Breaches = BreachClone:Clone()

			for Index,Door in pairs (Doors:GetChildren()) do
				Door.Parent = DoorsFolder
			end

			for Index,Door in pairs (Breaches:GetChildren()) do
				Door.Parent = ACS_Storage.Breach
			end

			Breaches:Destroy()
			Doors:Destroy()
		end
	end)
end)

Evt.DoorEvent.OnServerEvent:Connect(function(Player,Door,Mode,Key)
	if Mode == 1 then -- unlock door and open
		if Door.Locked.Value then
			if Door:FindFirstChild("RequiresKey") then
				local Character = Player.Character
				local KeyTool = Character:FindFirstChild(Key) or Player.Backpack:FindFirstChild(Key)
				if KeyTool then
					Door.Locked.Value = false
					ToggleDoor(Door)
				end
			end
		else
			ToggleDoor(Door)
		end
	elseif Mode == 2 then -- open door (no key)
		if not Door.Locked.Value then
			ToggleDoor(Door)
		end
	elseif Mode == 3 then -- lock/unlock door
		if Door:FindFirstChild("RequiresKey") then
			local Character = Player.Character
			Key = Door.RequiresKey.Value
			local KeyTool = Character:FindFirstChild(Key) or Player.Backpack:FindFirstChild(Key)
			if KeyTool then
				Door.Locked.Value = not Door.Locked.Value
			end
		end
	elseif Mode == 4 then -- unlock door
		if Door.Locked.Value then
			Door.Locked.Value = false
		end
	end
end)

----------------------------------------------------------------
--\\RAPPEL SYSTEM
----------------------------------------------------------------


--// Events
local placeEvent = Evt.Rappel.PlaceEvent
local ropeEvent = Evt.Rappel.RopeEvent
local cutEvent = Evt.Rappel.CutEvent

--// Delcarables

local active = false

--// Event Connections
placeEvent.OnServerEvent:connect(function(plr,newPos,what)

	local char =	plr.Character

	if ACS_Storage.Server:FindFirstChild(plr.Name.."_Rappel") == nil then
		local new = Instance.new('Part')
		new.Parent = workspace
		new.Anchored = true
		new.CanCollide = false
		new.Size = Vector3.new(0.2,0.2,0.2)
		new.BrickColor = BrickColor.new('Black')
		new.Material = Enum.Material.Metal
		new.Position = newPos + Vector3.new(0,new.Size.Y/2,0)
		new.Name = plr.Name.."_Rappel"

		local newW = Instance.new('WeldConstraint')
		newW.Parent = new
		newW.Part0 = new
		newW.Part1 = what
		new.Anchored = false

		local newAtt0 = Instance.new('Attachment')
		newAtt0.Name = "RappelAttachment"
		newAtt0.Parent = char.LowerTorso
		newAtt0.Position = Vector3.new(0,-.75,0)

		local newAtt1 = Instance.new('Attachment')
		newAtt1.Name = "RappelAttachment"
		newAtt1.Parent = new

		local newRope = Instance.new('RopeConstraint')
		newRope.Attachment0 = newAtt0
		newRope.Attachment1 = newAtt1
		newRope.Parent = char.LowerTorso
		newRope.Length = ServerConfig.RappelStartLength
		newRope.Restitution = 0.3
		newRope.Visible = true
		newRope.Thickness = ServerConfig.RappelThickness
		newRope.Color = BrickColor.new(ServerConfig.RappelColor)

		placeEvent:FireClient(plr,new)
	end
end)

ropeEvent.OnServerEvent:connect(function(plr,dir,dt)
	if not workspace:FindFirstChild(plr.Name .. "_Rappel") then return end
	local rappel = plr.Character.LowerTorso.RopeConstraint

	local rls = ServerConfig.RappelLengthStep
	local rmnl = ServerConfig.RappelMinLength
	local rmxl = ServerConfig.RappelMaxLength

	if dir == "Up" then
		rappel.Length = math.clamp(rappel.Length - rls * dt, rmnl, rmxl)
	elseif dir == "Down" then
		rappel.Length = math.clamp(rappel.Length + rls * dt, rmnl, rmxl)
	end
end)

cutEvent.OnServerEvent:connect(function(plr)
	local rappelpart = workspace:FindFirstChild(plr.Name.."_Rappel")
	if not rappelpart then return end
	
	rappelpart:Destroy()
	
	local lt = plr.Character.LowerTorso
	lt.RappelAttachment:Destroy()
	lt.RopeConstraint:Destroy()
end)


----------------------------------------------------------------
--\\ACS
--\\BODY MOVEMENT
----------------------------------------------------------------
Evt.MoveEvent.OnServerEvent:Connect(function(Player, CF)
	if Player and Player.Character and Player.Character:FindFirstChild("Humanoid").Health > 1 then
		local Waist = Player.Character.UpperTorso:FindFirstChild("Waist")

		if Waist then
			Waist.C0 = CF
		end
	end
end)


----------------------------------------------------------------
--\\ACS
--\\PING SYSTEM
----------------------------------------------------------------
--//Made By Acri_Terra modified by stillObama (440obama now lol)
--// Events
local pingEvent = Evt:WaitForChild('PingEvent')

--// Connections
pingEvent.OnServerEvent:Connect(function(sender,pos,whitelist)
	if not whitelist then
		pingEvent:FireAllClients(pos)
	else
		for _,v in pairs(whitelist) do
			if v and v:IsA('Player') then
				pingEvent:FireClient(v,pos)
			end
		end
	end;
end)



-- stank 7chon -i mean thank
-- 7chon stinks
Evt.Breathe.OnServerEvent:Connect(function(Player,Mode,Intensity)
	Evt.Breathe:FireAllClients(Player,Mode,Intensity)
end)

local function Lookup(Name)
	if Name == "KIA Callout" then
		return Engine.FX:FindFirstChild("KIACalls")
	end
	return nil
end

Evt.Callout.OnServerEvent:Connect(function(Player, plr, Id, Name) -- p = properties
	if plr == Player then
		return
	end
	if not plr or not plr.Character then
		return
	end
	if Id ~= ACS_0.."__"..Player.UserId then
		if ServerConfig.KickOnFailedSanityCheck then
			Player:kick(ServerConfig.KickMessage or "haha no you can't make everyone's heads play among us drip music aloud")
		end
		return
	end
	local char = plr.Character
	local head = char.Head
	
	local Folder = Lookup(Name)
	if not Folder then
		warn("Callout - Folder not found for: " .. Name)
	end
	
	local sounds = Folder:GetChildren()
	local Sound = sounds[math.random(1, #sounds)]:Clone()
	Sound.Parent = head
	Sound:Play()
	Sound.Played:Connect(function()
		Sound:Destroy()
	end)
end)

print(ver .. " loaded")






