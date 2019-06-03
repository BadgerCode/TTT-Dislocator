AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/props_junk/sawblade001a.mdl")


ENT.TrailColour = Color(125, 54, 194)
ENT.Stuck = false
ENT.Weaponised = false
ENT.InitialSpeed = 1000

ENT.PunchCurrentVelocity = Vector(0, 0, 0)
ENT.PunchSpeed = 500
ENT.PunchMax = 5
ENT.PunchRemaining = 5
ENT.NextPunch = 0

function ENT:Initialize()
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
    end

    self:SetColor(self.TrailColour)
    self.Stuck = false
    self.PunchRemaining = self.PunchMax
end

function ENT:StickTo(ent)
    if (not ent:IsPlayer() or ent.HasDislocator) then return false end
    self.PunchEntity = ent
    self:StartEffects()
    self.Stuck = true
    self.HasJustStuck = true
    ent.HasDislocator = true
    return true
end

function ENT:OnRemove()
    if IsValid(self.BallSprite) then
        self.BallSprite:Remove()
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
    local diesound = Sound("weapons/physcannon/energy_disintegrate4.wav")
    local punchsound = Sound("weapons/ar2/ar2_altfire.wav")

    function ENT:PhysicsCollide( collisionData, phys )
        self:StickTo(collisionData.HitEntity)
    end

    function ENT:GenerateRandomVelocity()
        local distance = self.PunchSpeed
        local u = math.random()
        local theta = 2 * math.pi * u

        local x = distance * math.cos(theta)
        local y = distance * math.sin(theta)
        local z = math.random(80, 120)

        local finalPunch = self.PunchRemaining == 0

        if (finalPunch) then
            z = z + 200
        end

        return Vector(x, y, z)
    end

    function ENT:Think()
        -- TODO: Disable when not stuck?
        if not self.Stuck then return end

        if self.HasJustStuck then
            self:SetPos(self:GetPos() + self:GetAngles():Forward() * 20)

            local phys = self:GetPhysicsObject()
            if phys and phys:IsValid() then
                phys:SetVelocity(Vector(0, 0, 0))
            end

            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_NONE)

            self:SetParent(self.PunchEntity)
            self.HasJustStuck = false
        end

        if (self.NextPunch > CurTime()) then
            local ply = self.PunchEntity
            ply:SetVelocity(self.PunchCurrentVelocity)

            return
        end

        if self.PunchRemaining <= 0 then
            local pos = self:GetPos()
            sound.Play(diesound, pos, 100, 100)
            self:Remove()
            local effect = EffectData()
            effect:SetStart(pos)
            effect:SetOrigin(pos)
            util.Effect("Explosion", effect, true, true)
        else
            self.PunchRemaining = self.PunchRemaining - 1

            if IsValid(self.PunchEntity) and IsValid(self.PunchEntity:GetPhysicsObject()) then
                local ply = self.PunchEntity
                local norm = Vector(0.5, 0.5, 1)
                self.PunchCurrentVelocity = self:GenerateRandomVelocity()
                ply:SetGroundEntity(NULL)
                ply:SetVelocity(self.PunchCurrentVelocity)
                local effect = EffectData()
                effect:SetStart(self:GetPos())
                effect:SetOrigin(self:GetPos())
                effect:SetNormal(norm * -1)
                effect:SetRadius(16)
                effect:SetScale(1)
                util.Effect("ManhackSparks", effect, true, true)
                sound.Play(punchsound, self:GetPos(), 80, 100)
            end
        end

        local delay = math.max(0.1, self.PunchRemaining / self.PunchMax) * 3
        self.NextPunch = CurTime() + delay
    end
end