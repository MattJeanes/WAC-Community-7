include("shared.lua")
AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*60)
	ent:Spawn()
	ent:Activate()
	ent.Owner=ply
    ent:SetSkin(math.random(0,4))
	ent:SetBodygroup(4,1)
	self.Sounds=table.Copy(sndt)
	return ent
end

ENT.AutomaticFrameAdvance = true // needed for gear anims

ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, -0.075, 0),
		Right = Vector(0, 0, 30), -- Rotate towards flying direction
		Top = Vector(0, -20, 0)
	},
	Lift = {
		Front = Vector(0, 0, 12.25), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.25)
	},
	Rail = Vector(1, 5, 20)
}

function ENT:CustomPhysicsUpdate(ph)
	if not IsValid(self) or not IsValid(self:GetPhysicsObject()) then return end

	if self.rotorRpm > 0.5 and self.rotorRpm < 0.89 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,2)
	elseif self.rotorRpm > 0.9 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,2)
	elseif self.rotorRpm < 0.8 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,1)
	end
	
	local geardown,t1=self:LookupSequence("geardown")
	local gearup,t2=self:LookupSequence("gearup")	
	local trace=util.QuickTrace(self:LocalToWorld(Vector(0,0,62)), self:LocalToWorld(Vector(0,0,50)), {self, self.Wheels[1], self.Wheels[2], self.Wheels[3], self.TopRotor})
	local phys=self:GetPhysicsObject()
	if IsValid(phys) and not self.disabled then
		if self.upMul>0.9 and self.rotorRpm>0.8 and phys:GetVelocity():Length() > 1299 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() != gearup then
			self:ResetSequence(gearup) 
			self:SetPlaybackRate(1.0)
			self:SetBodygroup(2,1)
			for i=1,3 do 
				self.Wheels[i]:SetRenderMode(RENDERMODE_TRANSALPHA)
				self.Wheels[i]:SetColor(Color(255,255,255,0))
				self.Wheels[i]:SetSolid(SOLID_NONE)
			end
		elseif self.upMul<0.6 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() == gearup then
			self:ResetSequence(geardown)
			self:SetPlaybackRate(1.0)
			timer.Simple(t1,function()
				if self.Wheels then
					for i=1,3 do
						self.Wheels[i]:SetRenderMode(RENDERMODE_NORMAL)
						self.Wheels[i]:SetColor(Color(255,255,255,255))
						self.Wheels[i]:SetSolid(SOLID_VPHYSICS)
					end
					self:SetBodygroup(2,0)
				end
			end)
		end
	end
	
	local phys=self:GetPhysicsObject()
	if IsValid(phys) and not self.disabled then
		if phys:GetVelocity():Length() > 850 then
			self:SetBodygroup(2,1)
		else
			self:SetBodygroup(2,0)
		end
	end

	if self.disabled and not self.backgib then
		self:KillBackRotor()
		self:SetBodygroup(5,1)
		self:SetBodygroup(4,0)
		self.backgib = ents.Create("prop_physics")
		self.backgib:SetModel("models/chippy/f86/wing.mdl")
		self.backgib:SetSkin(self:GetSkin())
		self.backgib:SetPos(self:LocalToWorld(Vector(0,25,25)))
		self.backgib:SetAngles(self:GetAngles())
		self.backgib:Spawn()
		self.backgib:Activate()
		self.backgib:GetPhysicsObject():AddVelocity(self:GetVelocity()+self:GetRight()*500)
		self.backgib:GetPhysicsObject():AddAngleVelocity(self:GetPhysicsObject():GetAngleVelocity())
		local fire = ents.Create("env_fire_trail")
		fire:SetPos(self.backgib:LocalToWorld(Vector(0,-50,0)))
		fire:Spawn()
		fire:SetParent(self.backgib)
		self.backgib.fire=fire
		constraint.NoCollide(self,self.backgib,0,0)
		for k,v in pairs(self.Wheels) do
			if IsValid(v) then
				constraint.NoCollide(self,v,0,0)
			end
		end
		self:AddOnRemove(self.backgib)
		self:AddOnRemove(self.backgib.fire)
	end
	
	if self.Active then
		self:SetBodygroup(3,0)
	else
		self:SetBodygroup(3,1)
	end
end


function ENT:AddRotor()
	self.TopRotor = ents.Create("prop_physics")
	self.TopRotor:SetModel("models/props_junk/sawblade001a.mdl")
	self.TopRotor:SetPos(self:LocalToWorld(self.TopRotorPos))
	self.TopRotor:SetAngles(self:GetAngles() + Angle(90, 0, 0))
	self.TopRotor:SetOwner(self.Owner)
	self.TopRotor:Spawn()
	self.TopRotor:SetNotSolid(true)
	self.TopRotor.Phys = self.TopRotor:GetPhysicsObject()
	self.TopRotor.Phys:EnableGravity(false)
	self.TopRotor.Phys:SetMass(5)
	--self.TopRotor.Phys:EnableDrag(false)
	self.TopRotor:SetNoDraw(true)
	self.TopRotor.fHealth = 100
	self.TopRotor.wac_ignore = true
	if self.RotorModel then
		local e = ents.Create("wac_hitdetector")
		e:SetModel(self.RotorModel)
		e:SetPos(self:LocalToWorld(self.TopRotorPos))
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:SetNotSolid(true)
		e:SetOwner(self.Owner)
		e:SetParent(self.TopRotor)
		e.wac_ignore = true
		local obb=e:OBBMaxs()
		self.RotorWidth=(obb.x>obb.y and obb.x or obb.y)
		self.RotorHeight=obb.z
		self.TopRotorModel=e
		self:AddOnRemove(e)
	end
	constraint.Axis(self.Entity, self.TopRotor, 0, 0, self.TopRotorPos, Vector(0,0,1), 0,0,0.01,1)
	self:AddOnRemove(self.TopRotor)

	if self.EngineWeight then
		local e = ents.Create("prop_physics")
		e:SetModel("models/props_junk/PopCan01a.mdl")
		e:SetPos(self:LocalToWorld(self.TopRotorPos))
		e:Spawn()
		e:SetNotSolid(true)
		e:GetPhysicsObject():SetMass(self.EngineWeight.Weight)
		constraint.Weld(self.Entity, e)
		self:AddOnRemove(e)
		self.EngineWeight.Entity = e
	end
end