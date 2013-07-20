if not wac then return end
if SERVER then AddCSLuaFile() end
ENT.Base 				= "wac_pl_base_u"
ENT.Type 				= "anim"
ENT.Category			= wac.aircraft.spawnCategoryU
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

if CLIENT then
	ENT.thirdPerson = {
		distance = 360
	}
end

ENT.WheelInfo={
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


function ENT:AddSeatTable()
    return{
        [1]={
            Pos=Vector(60,-0.2,20.6),
            ExitPos=Vector(3.5,60,100),
            NoHud=true,
			wep={[1]=wac.aircraft.getWeapon("M134",{
				Name="MG17",
				Ammo=1500,
				MaxAmmo=1500,
				NextShoot=1,
				LastShot=0,
				Gun=1,
				ShootDelay=0.02,
				func=function(self, t, p)
					if t.NextShoot <= CurTime() then
						if t.Ammo>0 then
							if !t.Shooting then
								t.Shooting=true
								t.SStop:Stop()
								t.SShoot:Play()
							end
							local Positions = { Vector(130,21,28), Vector(130,21,20), Vector(130,21,11),Vector(130,-21,28), Vector(130,-21,20) } 
							local ShootPos = table.Random( Positions )

							local bullet={}
							bullet.Num 		= 2
							bullet.Src 		= self:LocalToWorld(ShootPos+Vector(self:GetVelocity():Length()*0.6,0,0))
							bullet.Dir 		= self:GetForward()
							bullet.Spread 	= Vector(0.015,0.015,0)
							bullet.Tracer		= 25
							bullet.Force		= 100000
							bullet.Damage	= 300
							bullet.Attacker 	= p
							local effectdata=EffectData()
							effectdata:SetOrigin(self:LocalToWorld(ShootPos))
							effectdata:SetAngles(self:GetAngles())
							effectdata:SetScale(1.5)
							util.Effect("MuzzleEffect", effectdata)
							self.Entity:FireBullets(bullet)
							t.Gun=(t.Gun==1 and 2 or 1)
							t.Ammo=t.Ammo-1
							t.LastShot=CurTime()
							t.NextShoot=t.LastShot+t.ShootDelay
							local ph=self:GetPhysicsObject()
							if ph:IsValid() then
								ph:AddAngleVelocity(Vector(0,0,t.Gun==1 and 3 or -3))
							end
						end
						if t.Ammo<=0 then
							t.StopSounds(self,t,p)
							t.Ammo=t.MaxAmmo
							t.NextShoot=CurTime()+60
						end
					end
				end,
				StopSounds=function(self,t,p)
					if t.Shooting then
						t.SShoot:Stop()
						t.SStop:Play()
						t.Shooting=false
					end
				end,
				Init=function(self,t)
					t.SShoot=CreateSound(self,"wac/f86/shoot_start.wav")
					t.SStop=CreateSound(self,"wac/f86/shoot_end.wav")
				end,
				Think=function(self,t,p)
					if t.NextShoot<=CurTime() then
						t.StopSounds(self,t,p)
					end
				end,
				DeSelect=function(self,t,p)
					t.StopSounds(self,t,p)
				end
			}),	
		
			},
		},
	}
end


function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"wac/f86/Start.wav"),
		Blades=CreateSound(self.Entity,"F86.External"),
		Engine=CreateSound(self.Entity,"F86.Internal"),
		MissileAlert=CreateSound(self.Entity,""),
		MissileShoot=CreateSound(self.Entity,""),
		MinorAlarm=CreateSound(self.Entity,""),
		LowHealth=CreateSound(self.Entity,""),
		CrashAlarm=CreateSound(self.Entity,""),
	}
end

local function DrawLine(v1,v2)
	surface.DrawLine(v1.y,v1.z,v2.y,v2.z)
end

local mHorizon0=Material("WeltEnSTurm/WAC/Helicopter/hud_line_0")
local HudCol=Color(0,255,43,150)
local Black=Color(0,0,0,200)

mat={
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

ENT.thirdPerson = {
	distance = 470,
	angle = 5
}

function ENT:DrawPilotHud()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetRight(), 90)
	ang:RotateAroundAxis(self:GetForward(), 90)
	
	local uptm = self.SmoothVal
	local upm = self.SmoothUp
	local spos=self.SeatsT[1].Pos

	cam.Start3D2D(self:LocalToWorld(Vector(23,3.75,1)+spos), ang,0.015)
	surface.SetDrawColor(234,190,43,150)
	surface.DrawRect(228, -2185, 4, 4)
	surface.DrawRect(269, -2185, 4, 4)
	surface.DrawRect(247, -2185, 7, 7)
	surface.DrawRect(238, -2201, 4, 4)
	surface.DrawRect(258, -2201, 4, 4)
	surface.DrawRect(258, -2167, 4, 4)
	surface.DrawRect(238, -2167, 4, 4)
	
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
	
	surface.SetTextPos(205, 390) 
	surface.DrawText("IAS - "..math.floor(self:GetVelocity():Length()*0.1) .."kn")
	surface.SetTextPos(170, 425)
	local tr=util.QuickTrace(pos+self:GetUp()*10,Vector(0,0,-999999),self.Entity)
	surface.DrawText("RADAR ALT - "..math.ceil((pos.z-tr.HitPos.z)*0.01905).."m")
	
	surface.SetTextPos(220,45)
	local n=self:GetNWInt("seat_1_1_ammo")
	if n==14 and self:GetNWFloat("seat_1_1_nextshot")>CurTime() then
		n=0
	end
	
	cam.End3D2D()
end

function ENT:DrawWeaponSelection() end