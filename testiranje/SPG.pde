
class SPG {

	// attributes for the game
	PVector colour;                  // display color
  String name;                    // player name
  PVector startPos;               // pos in screen coordinates
  PShape hull_svg;    // svg of the hull
	PShape hull_path;

	// components
	Gun gun;

	// Box2D components
	Body body;

	SPG(DefSPG def) {

		// copying given data
		colour = def.colour;
		name = def.name;
		startPos = def.startPos;
		hull_svg = def.hull_svg;
		gun = new Gun();
		gun.gun_svg = def.gun_svg;
		hull_path = hull_svg.getChild("hull_path");

		makeBody();
		body.setUserData(this);
	}

	void makeBody() {

		Vec2 center = new Vec2(startPos.x, startPos.y);
		
		// Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();

		// setting the collision box
		PShape hull_path = hull_svg.getChild("path_8");
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
    fd.density = 100; // corelated to mass
    fd.friction = 100;  // friction with other meshes
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
		shape(hull_svg, 0, 0);
    popMatrix();
	}


}