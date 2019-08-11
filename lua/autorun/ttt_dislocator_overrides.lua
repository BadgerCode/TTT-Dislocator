hook.Remove("ShouldCollide", "collisions_ttt_dislocator")
hook.Add("ShouldCollide", "collisions_ttt_dislocator", function(ent1, ent2)
    if ent1:GetClass() == "ttt_dislocator_disk" then
        return IsAmmoOrWeapon(ent2) == false
    elseif ent2:GetClass() == "ttt_dislocator_disk" then
        return IsAmmoOrWeapon(ent1) == false
    end

    return true
end)

function IsAmmoOrWeapon(ent)
    local class = ent:GetClass():lower()
    return string.find(class, "ammo") or string.find(class, "weapon") or false
end
