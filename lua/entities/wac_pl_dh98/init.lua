
include("shared.lua")
AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*170)
	ent:Spawn()
	ent:Activate()
	Skin = math.random(0,1)
	ent:SetSkin(Skin)
	ent.Owner=ply	
	self.Sounds=table.Copy(sndt)

	return ent
end

ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, -0.075, 0),
		Right = Vector(0, 0, 70), -- Rotate towards flying direction
		Top = Vector(0, 0, 0)
	},
	Lift = {
		Front = Vector(0, 0, 13.25), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.25)
	},
	Rail = Vector(1, 5, 20)
}

function ENT:PhysicsUpdate(ph)
	self:base("wac_pl_base").PhysicsUpdate(self,ph)
	
	if self.rotorRpm > 0.5 and self.rotorRpm < 0.89 and IsValid(self.rotorModel) then
		self.rotorModel:SetBodygroup(1,2)
	elseif self.rotorRpm > 0.9 and IsValid(self.rotorModel) then
		self.rotorModel:SetBodygroup(1,3)
	elseif self.rotorRpm < 0.8 and IsValid(self.rotorModel) then
		self.rotorModel:SetBodygroup(1,1)
	end
	
	if self.rotorRpm > 0.5 and self.rotorRpm < 0.89 and IsValid(self.OtherRotorModel) then
		self.OtherRotorModel:SetBodygroup(1,2)
	elseif self.rotorRpm > 0.9 and IsValid(self.OtherRotorModel) then
		self.OtherRotorModel:SetBodygroup(1,3)
	elseif self.rotorRpm < 0.8 and IsValid(self.OtherRotorModel) then
		self.OtherRotorModel:SetBodygroup(1,1)
	end
	
	local geardown,t1=self:LookupSequence("geardown")
	local gearup,t2=self:LookupSequence("gearup")	
	local trace=util.QuickTrace(self:LocalToWorld(Vector(0,0,62)), self:LocalToWorld(Vector(0,0,50)), {self, self.Wheels[1], self.Wheels[2], self.Wheels[3], self.TopRotor})
	local phys=self:GetPhysicsObject()
	if IsValid(phys) and not self.disabled then
		if self.controls.throttle>0.9 and self.rotorRpm>0.5 and phys:GetVelocity():Length() > 1500 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() != gearup then
			self:ResetSequence(gearup) 
			self:SetPlaybackRate(1.0)
			self:SetBodygroup(4,1)
			for i=1,3 do 
				self.wheels[i]:SetRenderMode(RENDERMODE_TRANSALPHA)
				self.wheels[i]:SetColor(Color(255,255,255,0))
				self.wheels[i]:SetSolid(SOLID_NONE)
			end
		elseif self.controls.throttle<0.6 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() == gearup then
			self:ResetSequence(geardown)
			self:SetPlaybackRate(1.0)
			geardown,time1=self:LookupSequence("gearup")

			timer.Simple(time1,function()
				if self.wheels then
					for i=1,3 do 
						self.wheels[i]:SetRenderMode(RENDERMODE_NORMAL)
						self.wheels[i]:SetColor(Color(255,255,255,255))
						self.wheels[i]:SetSolid(SOLID_VPHYSICS)
					end
					self:SetBodygroup(4,0)
				end
			end)
		end
	end
	
	local vel = ph:GetVelocity()	
	local pos = self:GetPos()
	local lvel = self:WorldToLocal(pos+vel)
	local phm = FrameTime()*66
	local throttle = self.controls.throttle/2 + 0.5
	
	if self.OtherRotor.Phys and self.OtherRotor.Phys:IsValid() and self.rotor and self.rotor.phys and self.rotor.phys:IsValid() then
		local brake = (throttle+1)*self.rotorRpm/900+self.rotor.phys:GetAngleVelocity().z/100
		self.OtherRotor.Phys:AddAngleVelocity(Vector(0,0,-brake + lvel.x*lvel.x/500000)*self.OtherRotorDir*phm)
	end
end

function ENT:addRotors()
	self:base("wac_pl_base").addRotors(self)
	self.rotorModel.TouchFunc=nil
	
	// new rotor!
	self.OtherRotor = ents.Create("prop_physics")
	self.OtherRotor:SetModel("models/props_junk/sawblade001a.mdl")
	self.OtherRotor:SetPos(self:LocalToWorld(self.OtherRotorPos))
	self.OtherRotor:SetAngles(self:GetAngles() + Angle(90, 0, 0))
	self.OtherRotor:SetOwner(self.Owner)
	self.OtherRotor:Spawn()
	self.OtherRotor:SetNotSolid(true)
	self.OtherRotor.Phys = self.OtherRotor:GetPhysicsObject()
	self.OtherRotor.Phys:EnableGravity(false)
	self.OtherRotor.Phys:SetMass(5)
	--self.OtherRotor.Phys:EnableDrag(false)
	self.OtherRotor:SetNoDraw(true)
	self.OtherRotor.fHealth = 100
	self.OtherRotor.wac_ignore = true
	if self.RotorModel then
		local e = ents.Create("wac_hitdetector")
		e:SetModel(self.RotorModel)
		e:SetPos(self:LocalToWorld(self.OtherRotorPos))
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:SetOwner(self.Owner)
		e:SetParent(self.OtherRotor)
		e.wac_ignore = true
		local obb=e:OBBMaxs()
		self.RotorWidth=(obb.x>obb.y and obb.x or obb.y)
		self.RotorHeight=obb.z
		self.OtherRotorModel=e
		self:AddOnRemove(e)
	end
	constraint.Axis(self, self.OtherRotor, 0, 0, self.OtherRotorPos, Vector(0,0,1), 0,0,0.01,1)
	self:AddOnRemove(self.OtherRotor)
end