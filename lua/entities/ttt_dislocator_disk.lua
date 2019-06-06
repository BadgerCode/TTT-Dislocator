AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/props_junk/sawblade001a.mdl")
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT


ENT.DiskColour = Color(125, 54, 194, 125)
ENT.TrailColour = Color(125, 54, 194)
ENT.Stuck = false
ENT.Weaponised = false
ENT.InitialSpeed = 1000
ENT.MaxFlightTime = 3

ENT.PunchCurrentVelocity = Vector(0, 0, 0)
ENT.PunchSpeed = 200
ENT.FinalBonusUpVelocity = 210
ENT.PunchMax = 6
ENT.PunchRemaining = 0
ENT.NextPunch = 0


ENT.AttachSound = Sound("weapons/physcannon/physcannon_drop.wav")
ENT.InactiveSound = "dislocator_disk_inactive"
ENT.ActiveSound = "dislocator_disk_active"
ENT.DieSound = Sound("weapons/physcannon/energy_disintegrate5.wav")
ENT.PunchSound = Sound("weapons/physcannon/energy_sing_flyby1.wav")
ENT.PunchSoundAlt = Sound("weapons/physcannon/energy_sing_flyby2.wav")

sound.Add( {
    name = "dislocator_disk_inactive",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    sound = "weapons/physcannon/superphys_hold_loop.wav"
})

sound.Add( {
    name = "dislocator_disk_active",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    sound = "weapons/physcannon/energy_sing_loop4.wav"
})



function ENT:Initialize()
    self.BirthTime = CurTime()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetGravity(0)

    local phys = self:GetPhysicsObject()
    if phys and phys:IsValid() then
        phys:EnableGravity(false)
        phys:SetVelocity(self:GetAngles():Forward() * self.InitialSpeed)
        phys:Wake()
    end

    if SERVER then
        self:SetFriction(0)
        self:EmitSound(self.InactiveSound)
    end

    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetColor(self.DiskColour)
    self.Stuck = false
    self.PunchRemaining = self.PunchMax
end

function ENT:DrawTranslucent()
    local punchEntityId = self:GetNWInt("PunchEntityId", -1)
    if punchEntityId == -1 or LocalPlayer():EntIndex() != punchEntityId then
        self:Draw()
    end
end

function ENT:StickTo(ent)
    if (not ent:IsPlayer() or ent.HasDislocator or ent == self:GetOwner()) then return false end
    self.PunchEntity = ent
    self:StartEffects()
    self.Stuck = true
    self.HasJustStuck = true
    ent.HasDislocator = true

    self:SetNWInt("PunchEntityId", self.PunchEntity:EntIndex())
    return true
end

function ENT:OnRemove()
    if IsValid(self.BallSprite) then
        self.BallSprite:Remove()
    end

    if IsValid(self:GetParent()) then
        self:GetParent().HasDislocator = false
    end
end

function ENT:StartEffects()
    -- MAKE IT PRETTY
    local sprite = ents.Create("env_sprite")

    if IsValid(sprite) then
        local ang = self:GetAngles()
        local pos = self:GetPos() + self:GetAngles():Up() * 6
        sprite:SetPos(pos)
        sprite:SetAngles(ang)
        sprite:SetParent(self)
        sprite:SetKeyValue("model", "sprites/combineball_glow_blue_1.vmt")
        sprite:SetKeyValue("spawnflags", "1")
        sprite:SetKeyValue("scale", "0.25")
        sprite:SetKeyValue("rendermode", "5")
        sprite:SetKeyValue("renderfx", "7")
        sprite:Spawn()
        sprite:Activate()
        self.BallSprite = sprite
    end

    local effect = EffectData()
    effect:SetStart(self:GetPos())
    effect:SetOrigin(self:GetPos())
    effect:SetNormal(self:GetAngles():Up())
    util.Effect("ManhackSparks", effect, true, true)

    if SERVER then
        local ball = self:LookupAttachment("attach_ball")
        util.SpriteTrail(self, ball, self.TrailColour, false, 30, 0, 1, 0.07, "trails/physbeam.vmt")
    end
end

if SERVER then
    function ENT:Die()
        self:StopSound(self.InactiveSound)
        self:StopSound(self.ActiveSound)

        local pos = self:GetPos()
        sound.Play(self.DieSound, pos, 100, 100)
        self:Remove()
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        util.Effect("Explosion", effect, true, true)
    end

    function ENT:PhysicsCollide( collisionData, phys )
        if self.Stuck then return end
        self:StickTo(collisionData.HitEntity)
    end

    function ENT:GenerateRandomVelocity()
        local distance = self.PunchSpeed
        local u = math.random()
        local theta = 2 * math.pi * u

        local x = distance * math.cos(theta)
        local y = distance * math.sin(theta)
        local z = math.random(80, 120)

        local isFinalPunch = self.PunchRemaining == 0

        if (isFinalPunch) then
            z = z + self.FinalBonusUpVelocity
        end

        return Vector(x, y, z)
    end

    function ENT:Think()
        -- TODO: Disable when not stuck?
        if not self.Stuck then
            if (self.BirthTime + self.MaxFlightTime <= CurTime()) then
                self:Die()
            end
            return
        end

        if self.HasJustStuck then
            local phys = self:GetPhysicsObject()
            if phys and phys:IsValid() then
                phys:SetVelocity(Vector(0, 0, 0))
            end

            self:SetSolid(SOLID_NONE)

            self:SetPos(Vector(self.PunchEntity:GetPos().x, self.PunchEntity:GetPos().y, self:GetPos().z))
            self:SetParent(self.PunchEntity)

            self.HasJustStuck = false
            sound.Play(self.AttachSound, self.PunchEntity:GetPos(), 80, 100)

            self:StopSound(self.InactiveSound)
            self:EmitSound(self.ActiveSound)
        end

        if (self.NextPunch > CurTime()) then
            local ply = self.PunchEntity
            ply:SetVelocity(self.PunchCurrentVelocity)

            return
        end

        if self.PunchRemaining <= 0 then
            self:Die()
        else
            self.PunchRemaining = self.PunchRemaining - 1

            if IsValid(self.PunchEntity) and IsValid(self.PunchEntity:GetPhysicsObject()) then
                local ply = self.PunchEntity
                local norm = Vector(0.5, 0.5, 1)

                self.PunchCurrentVelocity = self:GenerateRandomVelocity()

                ply:SetGroundEntity(NULL)
                ply:SetVelocity(self.PunchCurrentVelocity)
                ply.was_pushed = {att = self:GetOwner(), t = CurTime(), wep = self.WeaponClass}

                local effect = EffectData()
                effect:SetStart(self:GetPos())
                effect:SetOrigin(self:GetPos())
                effect:SetNormal(norm * -1)
                effect:SetRadius(16)
                effect:SetScale(1)
                util.Effect("ManhackSparks", effect, true, true)

                local punchSound = self.PunchSound
                if (math.random(0, 100) >= 50) then punchSound = self.PunchSoundAlt end
                sound.Play(punchSound, self:GetPos(), 80, 100)
            end
        end

        local delay = math.max(0.1, self.PunchRemaining / self.PunchMax) * 3
        self.NextPunch = CurTime() + delay
    end
end