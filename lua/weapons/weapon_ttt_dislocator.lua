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

SWEP.Kind = WEAPON_EQUIP1
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
SWEP.ViewModelDiskModel = "models/props_junk/sawblade001a.mdl"
SWEP.ViewModelDiskModelMaterial = "models/props_junk/phys_objects01a"

SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.WorldModelColour = Color(125, 54, 194, 255)

SWEP.NoSights = true



function SWEP:Initialize()
    self:SetColor(self.WorldModelColour)
    self:SetSkin(1)
end

function SWEP:PreDrawViewModel(viewModel)
    Material(self.ViewModelMaterial):SetVector("$color2", self.ViewModelColour )
    Material(self.ViewModelDiskModelMaterial):SetVector("$color2", self.ViewModelColour )
end

function SWEP:PostDrawViewModel(viewModel)
    Material(self.ViewModelMaterial):SetVector("$color2", Vector(1, 1, 1) )

    local timeUntilShowModel = math.max(self:GetNextPrimaryFire() - CurTime(), 0)

    if self:Clip1() < 1 or timeUntilShowModel - 1 > 0 then return end

    if not IsValid(self.DiskViewModel) then
        self.DiskViewModel = ClientsideModel(self.ViewModelDiskModel, RENDERGROUP_VIEWMODEL)
        self.DiskViewModel:SetModelScale(0.5)
    end

    self.DiskViewModel:SetModelScale(0.5 * (1 - timeUntilShowModel))

    local rightHandPos, rightHandAngle = viewModel:GetBonePosition(viewModel:LookupBone("ValveBiped.Bip01_L_Hand"))
    rightHandPos = rightHandPos
                    + rightHandAngle:Forward() * 70
                    + rightHandAngle:Up() * -12
                    + rightHandAngle:Right() * 12

    local modelSettings = {
        model = self.ViewModelDiskModel,
        pos = rightHandPos,
        angle = rightHandAngle
    }
    render.Model(modelSettings, self.DiskViewModel)
    -- Make sure to reset the material AFTER rendering the clientside prop
    Material(self.ViewModelDiskModelMaterial):SetVector("$color", Vector(1, 1, 1) )
end



function SWEP:PrimaryAttack(worldsnd)
    if not self:CanPrimaryAttack() then return end

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:TakePrimaryAmmo(1)

    local owner = self.Owner
    if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

    if SERVER then
        local vsrc = owner:GetShootPos()
        local vang = owner:GetAimVector()

        local diskAngles = owner:EyeAngles()
        local diskPos = vsrc + vang * 50 + diskAngles:Right() * 20 - diskAngles:Up() * 20

        self:CreateDisk(diskPos, diskAngles)
    end

    owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0 ) )

    self:EmitSound(self.Primary.Sound)
end

function SWEP:Reload()
    -- Need to overload to prevent errors when NPCs use this weapon
end


function SWEP:CreateDisk(pos, ang)
    local disk = ents.Create("ttt_dislocator_disk")
    if IsValid(disk) then
        disk:SetPos(pos)
        disk:SetAngles(ang)

        disk:SetOwner(self:GetOwner())
        disk:Spawn()
        disk:Activate()
    end
end