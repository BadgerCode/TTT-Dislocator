# TTT Dislocator

Shoots a disk at players. The disk moves a player in random directions before launching them into the air.

From destroy all humans
* https://destroyallhumans.fandom.com/wiki/Dislocator
* https://youtu.be/5LzdSsuGWRg?t=98


TODO
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
* Add glow to disk
* Support other entities?
    * NPCS? Props?
* Put into gamemodes/terrortown/entities/weapons?
    * Or leave as generic?
