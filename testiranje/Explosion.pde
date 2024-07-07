// A rectangular box
class Explosion {

  // We need to keep track of a Body and a width and height
  Body circleBody;
  float maxWidth;
  float currentWidth;
  float x;
  float y;
  float growthSpeed = 2f;
  String type;
  boolean scoredTank = false;
  boolean scoredTank2 = false;

  // Constructor
  Explosion(float x, float y, String type) {
    maxWidth = 250;
    currentWidth = 1;
    this.x = x;
    this.y = y;
    this.type = type;
    
    makeCircleBody(x, y, currentWidth);
    circleBody.setUserData(this); // vidi u Box2D_notes.md
  }

  // This function removes the particle from the box2d world
  void removeExplosion() {
    currentWidth = 0;
    growthSpeed = 0;
    box2d.destroyBody(circleBody);
  }

  // Is the explosion ready for deletion?
  boolean done() {
    
    if (currentWidth > maxWidth) {
      removeExplosion();
      return true;
    }
    return false;
  }

  // Drawing the explosion
  void display() {
    
    rectMode(CENTER);
    pushMatrix();
    translate(x, y);
    fill(color(230,30,30, 140));
    stroke(0);
    ellipse(0, 0, currentWidth, currentWidth);
    currentWidth += growthSpeed;
    updateCircleBody();
    popMatrix();
  }
  
  void makeCircleBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.KINEMATIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x,y)));
    
    // Create the body
    circleBody = box2d.createBody(bd);
    
    // Define a circle shape
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r > 0 ? r : 0.1f); // Ensure radius is not zero

    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1.0;
    fd.friction = 0.3;
    fd.restitution = 0.5;
    
    // Masks so the only collision possible is with an SPG
    fd.filter.categoryBits = CATEGORY_EXPLOSION;
    fd.filter.maskBits = MASK_EXPLOSION;
    fd.filter.groupIndex = GROUP_INDEX_EXPLOSION;
    
    // Attach the shape to the body using the fixture
    circleBody.createFixture(fd);
  }
  
  void updateCircleBody() {
    if (circleBody == null) return;
    
    // Remove the existing fixture
    circleBody.destroyFixture(circleBody.getFixtureList());
    
    // Define a new circle shape with updated radius
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(currentWidth / 2);
    
    // Define a new fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1.0;
    fd.friction = 0.3;
    fd.restitution = 0.5;
    
    // Masks so the only collision possible is with an SPG
    fd.filter.categoryBits = CATEGORY_EXPLOSION;
    fd.filter.maskBits = MASK_EXPLOSION;
    fd.filter.groupIndex = GROUP_INDEX_EXPLOSION;
    
    // Attach the new shape to the body using the fixture
    circleBody.createFixture(fd);
  }

}
