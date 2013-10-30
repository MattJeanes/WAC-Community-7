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
ENT.rotorPos 	= Vector(283.6,-180,9)

ENT.Wheels={
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

ENT.Seats = {
	{
		pos=Vector(175,16,25),
		exit=Vector(372.79,0,9),
	},
	{
		pos=Vector(155,-24,20),
		exit=Vector(372.79,0,14),
	},
	{
		pos=Vector(270,-27,-9),
		ang=Angle(0,90,0),
		exit=Vector(372.79,0,14),
	},
}

ENT.Sounds={
	Start="wac/dh98/start.wav",
	Blades="wac/dh98/external.wav",
	Engine="wac/dh98/internal.wav",
	MissileAlert="",
	MissileShoot="",
	MinorAlarm="",
	LowHealth="",
	CrashAlarm="",
}

function ENT:DrawPilotHud() end
function ENT:DrawWeaponSelection() end