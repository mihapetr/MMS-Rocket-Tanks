
class Ground {

  PShape svg;
  PShape c_box;
  ChainShape chain;
  PVector[] test_v;
  Body body;
  Vec2 origin;

  Ground(String path, Vec2 origin) {

    svg = loadShape(path);

    try {
      c_box = svg.getChild("c_box");
    } catch (Exception e) {
      e.printStackTrace();
    }

    this.origin = origin;
    makeBody();
  }

  void display() {

    fill(131, 92, 59);
    PVector v;

    beginShape();

    for (int i = 0; i < c_box.getVertexCount(); ++i) {
      v = c_box.getVertex(i);
      vertex(origin.x + v.x, origin.y + v.y);
    }

    endShape();

    // for control
    for (int i = 0; i < c_box.getVertexCount(); ++i) {
      v = c_box.getVertex(i);
      fill(255 * i / c_box.getVertexCount(), 0, 0);
      ellipse(origin.x + v.x, origin.y + v.y, 5, 5);
    }
  }

  void makeBody() {

    // making artificial previous and next vertices
    // Box2D requires it for createChain() method

    chain = new ChainShape();
    int len = c_box.getVertexCount();

    PVector v;
    Vec2[] vertices = new Vec2[len];

    for (int i = 0; i < len; i++) {
      v = c_box.getVertex(i);
      //print(v.x + "," + v.y + "|"); // debug
      vertices[i] = box2d.vectorPixelsToWorld(new Vec2(origin.x + v.x, origin.y + v.y));
    }

    // Create the chain!
    try {
      chain.createChain(vertices, vertices.length);
    } catch (Exception e) {
      e.printStackTrace();
      exit();
    }
    
    // The edge chain is now attached to a body via a fixture
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(0,0)));
    body = box2d.world.createBody(bd);
    // Shortcut, we could define a fixture if we
    // want to specify frictions, restitution, etc.
    body.createFixture(chain,1);


    body.setUserData(this);
  }
}