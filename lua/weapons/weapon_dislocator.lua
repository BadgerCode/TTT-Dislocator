AddCSLuaFile("shared.lua")

SWEP.Base           = "weapon_base"
SWEP.PrintName      = "Dislocator"
SWEP.Category       = "Destroy all humans"
SWEP.Author         = "Badger (badger@badgercode.co.uk)"
SWEP.Instructions   = "Shoots a disk which launches players in random directions."

if CLIENT then
    SWEP.WepSelectIcon      = surface.GetTextureID("vgui/weapon_dislocator")
    SWEP.BounceWeaponIcon   = true
end

SWEP.HoldType       = "physgun"
SWEP.Slot           = 3
SWEP.SlotPos        = 10
SWEP.Weight         = 5
SWEP.AutoSwitchTo   = true
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo       = true

SWEP.Spawnable      = true
SWEP.AdminSpawnable = true


SWEP.Primary.Damage     = 0
SWEP.Primary.Delay      = 2
SWEP.Primary.Cone       = 0
SWEP.Primary.Automatic  = true
SWEP.Primary.Recoil     = 0
SWEP.Primary.Knockback  = 100
SWEP.Primary.Sound      = Sound( "weapons/physcannon/superphys_launch1.wav" )

SWEP.Primary.ClipSize       = 5
SWEP.Primary.ClipMax        = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = "XBowBolt"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.ClipMax      = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Ammo         = "none"


SWEP.UseHands                   = true
SWEP.ViewModelFlip              = false
SWEP.ViewModelFOV               = 54
SWEP.ViewModel                  = "models/weapons/c_superphyscannon.mdl"
SWEP.ViewModelMaterial          = "models/weapons/v_physcannon/v_superphyscannon_sheet"
SWEP.ViewModelColour            = Vector(0.49, 0.212, 0.761)
SWEP.ViewModelDiskModel         = "models/props_junk/sawblade001a.mdl"
SWEP.ViewModelDiskModelMaterial = "models/props_junk/phys_objects01a"

SWEP.WorldModel         = "models/weapons/w_physics.mdl"
SWEP.WorldModelColour   = Color(125, 54, 194, 255)

SWEP.ReadySound         = Sound("weapons/physcannon/physcannon_dryfire.wav")
SWEP.EquipSound         = Sound("weapons/physcannon/physcannon_claws_open.wav")



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

    if self:Clip1() >= 1 and timeUntilShowModel - 1 <= 0 then

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
    end
    -- Make sure to reset the material AFTER rendering the clientside prop
    Material(self.ViewModelDiskModelMaterial):SetVector("$color2", Vector(1, 1, 1) )

    if (self.ReadySoundPlayed == false and timeUntilShowModel == 0) then
        self.ReadySoundPlayed = true
        surface.PlaySound(self.ReadySound)
    end
end



function SWEP:PrimaryAttack()
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
    elseif CLIENT then
        self.ReadySoundPlayed = false
    end

    owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0 ) )

    self:EmitSound(self.Primary.Sound)
end

function SWEP:SecondaryAttack()

end


function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
end


function SWEP:CreateDisk(pos, ang)
    local disk = ents.Create("ttt_dislocator_disk")
    if IsValid(disk) then
        disk:SetPos(pos)
        disk:SetAngles(ang)

        disk.WeaponClass = self:GetClass()
        disk:SetOwner(self:GetOwner())
        disk:Spawn()
        disk:Activate()
    end
end

if CLIENT then
    function SWEP:Deploy()
        self.ReadySoundPlayed = false
        surface.PlaySound(self.EquipSound)
        return true
    end
end
