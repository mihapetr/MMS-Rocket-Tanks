/********************** SHIFFMAN CODE ********************************/

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

// A reference to our box2d world
Box2DProcessing box2d;

/*************************** GAME VARS *******************************/

ArrayList<Boundary> boundaries; // A list we'll use to track fixed objects
ArrayList<Box> boxes; // A list for all of our rectangles

boolean fire = false; // tech. variable for firing logic

// controls:
final char _fireBtn = ' '; // control button for firing
final int _rotateLeft = LEFT;
final int _rotateRight = RIGHT;
final int _scaleUp = UP;
final int _scaleDown = DOWN;

Vec2 firePosition; // where projectiles spawn
Vec2 crosshair = new Vec2(30, 15); // initial projectile speed
float rotateGun = 0;
final float w = 0.05;  // gun rotation speed
final float powerStep = 1;  // power modification scale
float modPower = 0f;
PVector nCrosshair;

/*************************** SYSTEM FUNCTIONS *******************************/

void setup() {
  size(1200, 600);  // Mihael : za moj ekran trenutno da ne koristim fullScreen()
  // smooth(); // commented to maximize physics calculations

  firePosition = new Vec2(width/5,2*height/3);

  // template code for world generation : Box2D
  createWorld();

  // Create ArrayLists to hold projectiles
  boxes = new ArrayList<Box>();

  // ground generation
  createTestFloor();
}

void draw() {

  background(255);

  myRotate(crosshair, rotateGun * w);
  nCrosshair = new PVector(crosshair.x, crosshair.y);
  nCrosshair.normalize();
  nCrosshair.mult(modPower * powerStep);
  // !!!! VEC2 NEMA IMPLEMENTIRANE OPERATORE !!!!
  myAdd(crosshair, nCrosshair);
  drawGun();

  // We must always step through time!
  box2d.step();

  if (fire) {
    fire  = false;
    
    Box p = new Box(firePosition.x, firePosition.y);
    boxes.add(p);
  }

  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }

  // Display all the boxes
  for (Box b: boxes) {
    b.display();
  }
  
  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }
}

void keyPressed() {

  // shoot if fire button pressed
  if(key == _fireBtn){
    fire = true;
  }

  if(keyCode == _rotateLeft) {
    rotateGun = 1f;
  }

  if(keyCode == _rotateRight) {
    rotateGun = -1f;
  }

  if(keyCode == _scaleUp) {
    modPower = 1f;
  }

  if(keyCode == _scaleDown) {
    modPower = -1f;
  }
}

void keyReleased() {
  
  if(keyCode == _rotateLeft) {
    rotateGun = 0f;
  }

  if(keyCode == _rotateRight) {
    rotateGun = 0f;
  }

  if(keyCode == _scaleUp || keyCode == _scaleDown) {
    modPower = 0f;
  }
}

/*************************** HELP FUNCTIONS *******************************/

void createWorld() {

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);
}

// just a box for now
void createTestFloor() {

  boundaries = new ArrayList<Boundary>();
  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, height-50, width, 10));
}

// draws the gun
void drawGun() {

  stroke(255,0,0);
  noFill();
  ellipse(firePosition.x, firePosition.y, 10, 10);
  stroke(0);
  line(firePosition.x, firePosition.y, firePosition.x + crosshair.x, firePosition.y - crosshair.y);

}

// rotate vector v for angle amount
void myRotate(Vec2 v, float angle) {

  PVector aux = new PVector(v.x,v.y);
  aux.rotate(angle);
  v.x = aux.x;
  v.y = aux.y;
}

void myAdd(Vec2 v, PVector p) {

  PVector aux = new PVector(v.x, v.y);
  aux.add(p);
  v.x = aux.x;
  v.y = aux.y;
}