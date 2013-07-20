if not wac then return end
ENT.Base = "wac_pl_base"
ENT.Type = "anim"
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "DH.98 Mosquito B MK.IV"

ENT.Model				= "models/chippy/dh98/body.mdl"
ENT.RotorPhModel		= "models/props_junk/sawblade001a.mdl"
ENT.RotorModel			= "models/chippy/dh98/prop.mdl"
ENT.OtherRotorModel		= "models/chippy/dh98/prop.mdl"

ENT.FirePos			= Vector(170,220,0)
ENT.SmokePos		= ENT.FirePos
ENT.AutomaticFrameAdvance = true

ENT.OtherRotorPos = Vector(283.6,176,9)
ENT.OtherRotorDir = -1

if CLIENT then
	ENT.thirdPerson = {
		distance = 740
	}
end

ENT.Weight			= 16225
ENT.EngineForce		= 450
ENT.TopRotorPos 	= Vector(283.6,-180,9)

ENT.AngBrakeMul		= 0.055

ENT.WheelInfo={
	{
		mdl="models/chippy/dh98/fwheel.mdl",
		pos=Vector(138,-180,-120),
		friction=0,
		mass=400,
	},
	{
		mdl="models/chippy/dh98/fwheel.mdl",
		pos=Vector(138,175,-119),
		friction=0,
		mass=400,
	},
	{
		mdl="models/chippy/dh98/bwheel.mdl",
		pos=Vector(-457,-2,-10),
		friction=0,
		mass=1100,
	},
}

function ENT:AddSeatTable()
	return {
		[1]={
			Pos=Vector(175,16,25),
			ExitPos=Vector(372.79,0,9),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[2]={
			Pos=Vector(155,-24,20),
			ExitPos=Vector(372.79,0,14),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[3]={
			Pos=Vector(270,-27,-9),
			Ang=Angle(0,90,0),
			ExitPos=Vector(372.79,0,14),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"wac/an32/Start.wav"),
		Blades=CreateSound(self.Entity,"DH98.External"),
		Engine=CreateSound(self.Entity,"DH98.Internal"),
		MissileAlert=CreateSound(self.Entity,""),
		MissileShoot=CreateSound(self.Entity,""),
		MinorAlarm=CreateSound(self.Entity,""),
		LowHealth=CreateSound(self.Entity,""),
		CrashAlarm=CreateSound(self.Entity,""),
	}
end

function ENT:DrawPilotHud() end
function ENT:DrawWeaponSelection() end