# RocketTanks
Završni za MMS. 

[Dokumentacija](dokumentacija.pdf)

## Generalne informacije
Projekt je inspiriran igricom [Pocket Tanks](https://www.blitwise.com/pocket-tanks).

## Potrebne biblioteke
Plan je koristiti biblioteku [Box2D for Processing](https://github.com/shiffman/Box2D-for-Processing) u svrhu simulacije fizike.

## Klase
Trenutni plan hijerarhije klasa.
* `SPG` (self propelled gun) : glavni interes, instancira tenkove
    * sadrži `Gun` : top na čijem kraju se pojavljuju projektili `Projectile` u smjeru ispaljivanja 
        * glavne karakteritike :
            * `direction` : relativan smjer
            * `power` : jačina ispaljivanja
    * sadrži `tank_svg:PShape`
    * sadrži `hull_path:PShape` 

* `Projectile` : nakon ispaljivanja se prati kolizija s ostalim objektima u igri
    * sadrži `body:Body`

* `Ground` : objekti ove klase predstavljaju teren na kojem voze tenkovi
    * sadrži `chain:ChainShape` : jednostrani collison detection
    * sadrži `body:Body`

Za razumijevanje .svg datoteka potrebno je otvoriti ih u nekom editoru za vektorsku grafiku. Neki sadrže child elemente.

# Box2D

Ovamo pišem saznanja o biblioteci. Jedan veći problem je što ne postoji službena dokumentacija nego je referencirana [dokumentacija za C++](https://box2d.org/documentation/index.html). Skoro sve je implementirano po uzoru na tu biblioteku, ali su neka imena izmjenjena. Potrebno je malo muke za istraživanje. 

## Body
* `Body`:
    * sadrži `getUserData() -> Object o`
    * sadrži `setUserData(Object o)` : referenca na neki korisnički objekt iz programa
    * kreira se pomoću `BodyDef` klase
    * sadrži `Fixture` instancu
        * kreira se pomoću `FixtureDef`
        * sadrži `shape : PolygonShape` instancu
        * karakteristike : 
            * density ~ mass
            * friction
            * restitution - bounciness
    * sadrži `type` :
        * fixed - no movement (max mass)
        * dynamic - full simulation
        * kinematic - no forces, but moves, cheaper simulation
    * karakteristike : 
        * `position`
        * `angle`

## World
Koordinate svijeta ne odgovaraju koordinatama ekrana pa se koristi `coordPixelsToWorld` metoda za pretvorbu ekran -> simulacija.

## Collisions
Za slušanje kolizija se brine Box2D. Svaka kolizija se obrađuje u metodama `void beginContact(Contact cp)` i `void endContact(Contact cp)`. Kod kreiranja svijeta se poziva `box2d.listenForCollisions()`.

## Edge Shapes
Za konstrukciju terena koristit ćemo `EdgeShape` i `ChainShape` klase.
