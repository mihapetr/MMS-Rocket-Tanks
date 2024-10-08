
class Gun {

  SPG tank;   // who is carying the gun

  final int length = 30;   // barrel length
  final int calibre = 3;  // barrel diameter
  final PVector mountPos = new PVector(19, 4);   // where it is mounted on the tank

  float power = 10;
  PVector direction;

  Gun(SPG tank) {

    this.tank = tank;
    direction = new PVector(1,0);
    direction.normalize().mult(length);
  }

  void display() {

    strokeWeight(calibre);
    strokeCap(SQUARE);
    line(
      mountPos.x,
      mountPos.y,
      mountPos.x + direction.x,
      mountPos.y + direction.y
    );
    strokeWeight(1);
  }

  void fire() {

    fire = false;
    
    Vec2 pos = box2d.getBodyPixelCoord(tank.body);
    float a = tank.body.getAngle();

    PVector dir = direction.copy();
    
    PVector mPos = mountPos.copy();
    dir.rotate(-a);
    mPos.rotate(-a);
    
    if(selectedWeapon == 1 || selectedWeapon == 2){
      Projectile p = new Projectile(
        pos.x + mPos.x + dir.x,
        pos.y + mPos.y + dir.y
      );
  
      dir.normalize().mult(power);
  
      p.body.setLinearVelocity(new Vec2(dir.x, - dir.y));
      shells.add(p);
    }
    else if (selectedWeapon == 3){
      Projectile p1 = new Projectile(
        pos.x + mPos.x + dir.x,
        pos.y + mPos.y + dir.y
      );
      Projectile p2 = new Projectile(
        pos.x + mPos.x + dir.x,
        pos.y + mPos.y + dir.y
      );
      Projectile p3 = new Projectile(
        pos.x + mPos.x + dir.x,
        pos.y + mPos.y + dir.y
      );
      
      dir.normalize().mult(power);
      
      p1.body.setLinearVelocity(new Vec2(dir.x + 1, - dir.y));
      p2.body.setLinearVelocity(new Vec2(dir.x - 1, - dir.y));
      p3.body.setLinearVelocity(new Vec2(dir.x, - dir.y));
      shells.add(p1);
      shells.add(p2);
      shells.add(p3);
    }
  }

  void aim() {

    direction.rotate(rotateGun * w);
    power += modPower * powerStep;
    if(power < 0) power = 0;
    if(power > maxPower) power = maxPower;
  }
}
