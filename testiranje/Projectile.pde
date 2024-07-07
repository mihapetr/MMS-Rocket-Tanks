// A rectangular box
class Projectile {

  // We need to keep track of a Body and a width and height
  Body body;
  float w;
  float h;
  boolean delete = false;

  // Constructor
  Projectile(float x, float y) {
    w = 4;
    h = 4;
    // Add the box to the box2d world
    makeBody(new Vec2(x, y), w, h);
    body.setUserData(this); // vidi u Box2D_notes.md
  }

  // This function removes the particle from the box2d world and starts an explosion
  void killBody() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    
    box2d.destroyBody(body);
    
    // When the projectile is removed, explosion is created, assertion errors occur otherwise
    createExplosion(pos.x, pos.y, "test");
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height + 10 || pos.x > width + 10 || delete) {
      killBody();
      return true;
    }
    return false;
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(0);
    stroke(0);
    ellipse(0, 0, w, h);
    popMatrix();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 0.1; // corelated to mass
    fd.friction = 100;  // friction with other meshes
    fd.restitution = 0; // bounciness

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    //body.setLinearVelocity(crosshair);  // where user is aiming at the moment
    body.setAngularVelocity(0);
  }
  
  float getPositionX(){
    return (box2d.getBodyPixelCoord(body)).x;
  }
  
  float getPositionY(){
    return (box2d.getBodyPixelCoord(body)).y;
  }
}
