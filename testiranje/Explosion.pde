// A rectangular box
class Explosion {

  // We need to keep track of a Body and a width and height
  Body body;
  float maxWidth;
  float currentWidth;
  float x;
  float y;
  float growthSpeed = 2f;
  String type;

  // Constructor
  Explosion(float x, float y, String type) {
    maxWidth = 250;
    currentWidth = 1;
    this.x = x;
    this.y = y;
    this.type = type;
  }

  // This function removes the particle from the box2d world
  void removeExplosion() {
    currentWidth = 0;
    growthSpeed = 0;
  }

  // Is the particle ready for deletion?
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
    popMatrix();
  }

}
