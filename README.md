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
* ✅ Projectile
    * ✅ Disk model
    * ✅ Moves through air (not instant)
    * ✅ Check collisions to decide which player to attach to
* ✅ Disk on view model
* ✅ Explode projectile if no target found within period of time
* ✅ Prevent sticking to person who fired it?
* ✅ Ensure traitor gets credit for fall damage
* ✅ Change sound effects
    * ✅ Laser sound when shot
    * ✅ Laser sound when flying (with or without player)
    * ✅ Ambient hum when ready?
* ✅ Hide disk for the player it is attached to
* Change launch behaviour
    * Keep moving the player until time is up (10 seconds?)
    * If player hits a wall, move a different direction
    * Make movement a bit more consistent
        * Currently, the target often gets stuck somewhere
        * Or the velocity isn't that strong
        * Sometimes the velocity can be extremely strong and fly the player around
    * Make it harder for players to fight the movement
* Stop the wobble of the projectile?
* Only allow one disk per gun at a time?
* Support other entities?
    * NPCS? Props?
* Put into gamemodes/terrortown/entities/weapons?
    * Or leave as generic?
