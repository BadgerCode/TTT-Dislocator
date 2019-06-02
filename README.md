# TTT Dislocator

Shoots a disk at players. The disk moves a player in random directions before launching them into the air.

From destroy all humans
* https://destroyallhumans.fandom.com/wiki/Dislocator
* https://youtu.be/5LzdSsuGWRg?t=98


TODO
* Disk on view model
* Basic weapon
    * Use trace to hit a player
        * Only players for not
    * Attach entity to player
    * Launch player in random direction
        * Decrease launches remaining
    * Wait delay
    * If launches remaining is 0, launch player upwards and destroy self
* Projectile
    * Disk model
    * Moves through air (not instant)
    * Check collisions to decide which player to attach to
* Trail?
* Support other entities?
    * NPCS? Props?
* Put into gamemodes/terrortown/entities/weapons?
    * Or leave as generic?
