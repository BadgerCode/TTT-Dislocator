# TTT Dislocator

Shoots a disk at players. The disk moves a player in random directions before launching them into the air.

From destroy all humans
* https://destroyallhumans.fandom.com/wiki/Dislocator
* https://youtu.be/5LzdSsuGWRg?t=98


TODO
* ✅ Basic weapon
    * ✅ Use trace to hit a player
        * Only players for now
    * ✅ Attach entity to player
    * ✅ Launch player in random direction
        * ✅ Decrease launches remaining
    * ✅ Wait delay
    * ✅ If launches remaining is 0, launch player upwards and destroy self
* ✅ Prevent targetting a player with one already on
* ✅ Icon
* Projectile
    * ✅ Disk model
    * ✅ Moves through air (not instant)
    * ✅ Check collisions to decide which player to attach to
* ✅ Disk on view model
* ✅ Explode projectile if no target found within period of time
* Stop the wobble of the projectile?
* Only allow one disk per gun at a time?
* Change launch behaviour
    * Keep moving the player until time is up (10 seconds?)
    * If player hits a wall, move a different direction
* ✅ Prevent sticking to person who fired it?
* ✅ Ensure traitor gets credit for fall damage
* Support other entities?
    * NPCS? Props?
* Put into gamemodes/terrortown/entities/weapons?
    * Or leave as generic?
