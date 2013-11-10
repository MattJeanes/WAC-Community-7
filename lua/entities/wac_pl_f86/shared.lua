if not wac then return end
if SERVER then AddCSLuaFile() end
ENT.Base 				= "wac_pl_base"
ENT.Type 				= "anim"
ENT.Category			= wac.aircraft.spawnCategory
ENT.PrintName			= "F-86F Sabre"
ENT.Author				= "Chippy"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

ENT.Model            = "models/chippy/f86/body.mdl"

ENT.EngineForce        = 480
ENT.Weight            = 6400
ENT.SeatSwitcherPos	= Vector(0,0,0)
ENT.AngBrakeMul		= 0.0127
ENT.SmokePos        = Vector(-230,1,23)
ENT.FirePos            = Vector(50,-40,1)
ENT.rotorPos			= Vector(0,0,0)

if CLIENT then
	ENT.thirdPerson = {
		distance = 360
	}
end

ENT.Wheels={
	{
		mdl="models/chippy/f86/bwheel1.mdl",
		pos=Vector(-30,-47,-40),
		friction=0,
		mass=900,
	},
	{
		mdl="models/chippy/f86/bwheel2.mdl",
		pos=Vector(-30,47,-40),
		friction=0,
		mass=900,
	},
	{
		mdl="models/chippy/f86/fwheel.mdl",
		pos=Vector(136,-2,-37.8),
		friction=0,
		mass=700,
	},
}

ENT.Agility = {
	Thrust = 15
}


ENT.Seats = {
	{
		pos=Vector(60,-0.2,20.6),
		exit=Vector(3.5,60,100),
		weapons={"M3 Browning"},
	}
}

ENT.Weapons = {
	["M3 Browning"] = {
		class = "wac_pod_gatling",
		info = {
			Pods = {
				Vector(140,20,28),
				Vector(140,20,20),
				Vector(140,20,11),
				Vector(140,-20,28),
				Vector(140,-20,20),
				Vector(140,-20,11),
			},
			FireRate = 500,
			Sequential = true,
			Sounds = {
				shoot = "wac/f86/shoot_start.wav",
				stop = "wac/f86/shoot_end.wav",
			},
		}
	}
}

ENT.Sounds={
	Start="wac/f86/start.wav",
	Blades="wac/f86/external.wav",
	Engine="wac/f86/internal.wav",
	MissileAlert="",
	MissileShoot="",
	MinorAlarm="",
	LowHealth="",
	CrashAlarm="",
}


//hud

local function DrawLine(v1,v2)
	surface.DrawLine(v1.y,v1.z,v2.y,v2.z)
end

local mHorizon0 = Material("WeltEnSTurm/WAC/Helicopter/hud_line_0")
local HudCol = Color(70,199,50,150)
local Black = Color(0,0,0,200)

local mat = {
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_0"),
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_high"),
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_low"),
}

local function getspaces(n)
	if n<10 then
		n="      "..n
	elseif n<100 then
		n="    "..n
	elseif n<1000 then
		n="  "..n
	end
	return n
end


function ENT:DrawPilotHud()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetRight(), 90)
	ang:RotateAroundAxis(self:GetForward(), 90)

	local uptm = self.SmoothVal
	local upm = self.SmoothUp
	local spos=self.Seats[1].pos

	cam.Start3D2D(self:LocalToWorld(Vector(30,3.75,37.75)+spos), ang,0.015)
	surface.SetDrawColor(HudCol)
	surface.DrawRect(234, 247, 10, 4)
	surface.DrawRect(254, 247, 10, 4)
	surface.DrawRect(247, 234, 4, 10)
	surface.DrawRect(247, 254, 4, 10)

	local a=self:GetAngles()
	a.y=0
	local up=a:Up()
	up.x=0
	up=up:GetNormal()

	local size=180
	local dist=10
	local step=12
	for p=-180,180,step do
		if a.p+p>-size/dist and a.p+p<size/dist then
			if p==0 then
				surface.SetMaterial(mat[1])
			elseif p>0 then
				surface.SetMaterial(mat[2])
			else
				surface.SetMaterial(mat[3])
			end
			surface.DrawTexturedRectRotated(250+up.y*(a.p+p)*dist,250-up.z*(a.p+p)*dist,300,300,a.r)
		end
	end

	surface.SetTextColor(HudCol)
	surface.SetFont("wac_heli_small")

	surface.SetTextPos(30, 410) 
	surface.DrawText("SPD  "..math.floor(self:GetVelocity():Length()*0.1) .."kn")
	surface.SetTextPos(30, 445)
	local tr=util.QuickTrace(pos+self:GetUp()*10,Vector(0,0,-999999),self.Entity)
	surface.DrawText("ALT  "..math.ceil((pos.z-tr.HitPos.z)*0.01905).."m")

	if self:GetNWInt("seat_1_actwep") == 1 and self.weapons["Hydra 70"] then
		surface.SetTextPos(300,445)
		local n = self.weapons["Hydra 70"]:GetAmmo()
		surface.DrawText("Hydra 70" .. getspaces(n))
	end

	cam.End3D2D()
end

function ENT:DrawWeaponSelection() end