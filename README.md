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
* Prevent targetting traitors?
    * Might make it easy to spot traitors
* Icon
* Disk on view model
* Projectile
    * Disk model
    * Moves through air (not instant)
    * Check collisions to decide which player to attach to
    * Prevent targetting traitors
* Change launch behaviour
    * Keep moving the player until time is up (10 seconds?)
    * If player hits a wall, move a different direction
* Support other entities?
    * NPCS? Props?
* Put into gamemodes/terrortown/entities/weapons?
    * Or leave as generic?
