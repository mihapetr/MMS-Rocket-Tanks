
class SPG {

	// attributes for the game
	PVector colour;                  // display color
  String name;                    // player name
  PVector startPos;               // pos in screen coordinates
  PShape tank_svg;              // svg of the whole tank
	PShape hull_path;             // child of PShape containing a path for the collision box
  PShape tank_image;

	// components
	Gun gun;
  // Projectile p;

	// Box2D components
	Body body;
  float topSpeed = 5;
  boolean onGround = false;

	SPG(DefSPG def) {

		// copying given data
		colour = def.colour;
		name = def.name;
		startPos = def.startPos;
		tank_svg = def.tank_svg;
    hull_path = tank_svg.getChild("hull_path");

		gun = new Gun(this);
		
		makeBody();
		body.setUserData(this);
	}

  // direction is -1f for left and 1f for right
  // this can be optimized for better realism
  void move() {

    //if(moveDir == 0f) body.setLinearVelocity(new Vec2(0,0));
    if(body.getLinearVelocity().length() > topSpeed) return;

    float a = body.getAngle();
    PVector right = new PVector(moveDir * 1000, 0);
    PVector down = new PVector(0, -200);
    right.rotate(a);
    down.rotate(a);
    Vec2 r = new Vec2(right.x, right.y);
    Vec2 d = new Vec2(down.x, down.y);

    if(moveDir != 0f) body.applyForceToCenter(r);
    if(onGround) body.applyForceToCenter(d);
  }

	void makeBody() {

		Vec2 center = new Vec2(startPos.x, startPos.y);
		
		// Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();

		// setting the collision box
		PShape hull_path = tank_svg.getChild("c_box");
    Vec2[] vertices = new Vec2[hull_path.getVertexCount()];
		PVector v;
		for (int i = 0; i < vertices.length; ++i) {
			v = hull_path.getVertex(i);
			vertices[i] = box2d.vectorPixelsToWorld(new Vec2(v.x, v.y));
		}
    sd.set(vertices, vertices.length);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 10; // corelated to mass
    fd.friction = 2;  // friction with other meshes
    fd.restitution = 0.2; // bounciness

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(0f,0f)); 
    body.setAngularVelocity(0f);
	}

	void display() {

		// We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    pushMatrix();

    translate(pos.x, pos.y);
    rotate(-a);
    fill(colour.x, colour.y, colour.z);

    // gun first to leave excess behind turret
    gun.display();

    beginShape();
    PShape image = tank_svg.getChild("image");
    PVector v;
    for (int i = 0; i < image.getVertexCount(); ++i) {
      v = image.getVertex(i);
      vertex(v.x, v.y);
    }
    endShape();

    popMatrix();
	}


}