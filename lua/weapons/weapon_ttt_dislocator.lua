AddCSLuaFile("shared.lua")

SWEP.Author = "badger@badgercode.co.uk"
SWEP.Instructions = "TTT weapon to launch players in random directions"

SWEP.HoldType = "physgun" -- TODO: check this. Doesn't work in thirdperson

if CLIENT then
    SWEP.PrintName = "Dislocator"
    SWEP.Slot      = 7

    SWEP.Icon = "vgui/ttt/icon_badger_dislocator"

    SWEP.ViewModelFOV = 72

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Shoot at a player to launch them in random directions"
    };
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.Primary.Damage     = 0
SWEP.Primary.Delay      = 2
SWEP.Primary.Cone       = 0
SWEP.Primary.Automatic  = true
SWEP.Primary.Recoil     = 0
SWEP.Primary.Knockback  = 100
SWEP.Primary.Sound      = Sound( "weapons/airboat/airboat_gun_energy1.wav" )

SWEP.Primary.ClipSize       = 5
SWEP.Primary.ClipMax        = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = nil

SWEP.AutoSpawnable      = false
SWEP.UseHands           = true
SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54
SWEP.ViewModel  = "models/weapons/c_superphyscannon.mdl"
SWEP.ViewModelMaterial = "models/weapons/v_physcannon/v_superphyscannon_sheet"
SWEP.ViewModelColour = Vector(0.49, 0.212, 0.761)
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.WorldModelColour = Color(125, 54, 194, 255)

SWEP.NoSights = true

local maxrange = 800 -- TODO: What should this be?

function SWEP:Initialize()
    self:SetColor(self.WorldModelColour)
    self:SetSkin(1)
end

function SWEP:PreDrawViewModel(viewModel)
    Material(self.ViewModelMaterial):SetVector("$color2", self.ViewModelColour )
    --viewModel:SetPoseParameter("active", 1) -- TODO: Remove/fix. Sets the claws to open but they jitter
end

function SWEP:PostDrawViewModel(viewModel)
    Material(self.ViewModelMaterial):SetVector("$color2", Vector(1, 1, 1) )
end



function SWEP:PrimaryAttack(worldsnd)
    if not self:CanPrimaryAttack() then return end

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:TakePrimaryAmmo(1)

    local owner = self.Owner
    if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

    if SERVER then
        local tr = util.TraceLine({start=owner:GetShootPos(), endpos=owner:GetShootPos() + owner:GetAimVector() * maxrange, filter={owner, self.Entity}, mask=MASK_SOLID})

        if tr.HitNonWorld and tr.Entity.IsPlayer() then
            self:CreateDisk(tr.Entity, tr.HitPos)
        end
    end

    owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

    local bullet = {
        Attacker        = self.Owner,
        Num             = 1,
        Src             = self.Owner:GetShootPos(),
        Dir             = self.Owner:GetAimVector(),
        Spread          = 0.1 * 0.1 , 0.1 * 0.1, 0,
        Tracer          = 1,
        TracerName      = "AirboatGunHeavyTracer",
        Force           = self.Primary.NumShots,
        Damage          = self.Primary.Damage
    }
   
    bullet.Callback = function(attacker, trace, dmginfo)
        dmginfo:SetDamageType(DMG_AIRBOAT)
    end

    self.Weapon:FireBullets(bullet)
    self:EmitSound(self.Primary.Sound)
end

function SWEP:Reload()
    -- Need to overload to prevent errors when NPCs use this weapon
end



function SWEP:CreateDisk(tgt, pos)
   local disk = ents.Create("ttt_dislocator_disk")
   if IsValid(disk) then
      local ang = self:GetOwner():GetAimVector():Angle()
      ang:RotateAroundAxis(ang:Right(), 90)

      disk:SetPos(pos)
      disk:SetAngles(ang)

      disk:Spawn()

      disk:SetOwner(self:GetOwner())

      local stuck = disk:StickTo(tgt)

      if not stuck then disk:Remove() end
      self.disk = disk -- TODO: Only allow one disk to be active at a time
   end
end