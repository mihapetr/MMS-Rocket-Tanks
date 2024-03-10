# RocketTanks
Završni za MMS.

# Generalne informacije
Projekt je inspiriran igricom [Pocket Tanks](https://www.blitwise.com/pocket-tanks).

# Brainstorming
Potrebne su sljedeće scene za kompletnu igru:
* Main menu 
    * 2 player
    * credits
    * exit
* Controls graphical interface 
    * move
    * angle
    * power
    * weapon selector
    * fire button
* Weapon shop
    * player 1
    * weapon pool
    * player 2
* Game scene
    * Controls GUI
    * P1 name, score
    * P2 name, score
    * terrain 
    * tank 1
    * tank 2
    * physics

Zadaci posloženi po prioritetu:
1. terrain physics
1. tanks
1. names and scores
1. controls GUI
1. basic shell
1. shell physics and scoring
1. custom shells and physics
1. Weapon shop scene
1. Main menu scene

# Potrebne biblioteke
Plan je koristiti biblioteku [Box2D for Processing](https://github.com/shiffman/Box2D-for-Processing) u svrhu simulacije fizike.

# Klase
Trenutni plan hijerarhije klasa.
* `SPG` (self propelled gun)
    * ima `Gun`
        * karakteritike :
            * `angle`
            * `power`
    * ima `Hull`
        * ima `Body`
    * karakteristike :
        * `position`
        * `score`
* `Projectile`