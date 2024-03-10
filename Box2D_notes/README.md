# Box2D
Ovamo pišem saznanja o biblioteci. Jedan veći problem je što ne postoji službena dokumentacija nego je referencirana [dokumentacija za C++](https://box2d.org/documentation/index.html). Skoro sve je implementirano po uzoru na tu biblioteku, ali su neka imena izmjenjena. Potrebno je malo muke za istraživanje. 

# Body
* `Body`:
    * ima `getUserData() -> Object o`
    * ima `setUserData(Object o)` : referenca na neki korisnički objekt iz programa
    * kreira se pomoću `BodyDef` klase
    * ima `Fixture` instancu
        * kreira se pomoću `FixtureDef`
        * ima `shape : PolygonShape` instancu
        * karakteristike : 
            * density ~ mass
            * friction
            * restitution - bounciness
    * ima `type` :
        * fixed - no movement (max mass)
        * dynamic - full simulation
        * kinematic - no forces, but moves, cheaper simulation
    * karakteristike : 
        * `position`
        * `angle`

# World
Koordinate svijeta ne odgovaraju koordinatama ekrana pa se koristi `coordPixelsToWorld` metoda za pretvorbu ekran -> simulacija.

# Collisions
Za slušanje kolizija se brine Box2D. Svaka kolizija se obrađuje u metodama `void beginContact(Contact cp)` i `void endContact(Contact cp)`. Kod kreiranja svijeta se poziva `box2d.listenForCollisions()`.