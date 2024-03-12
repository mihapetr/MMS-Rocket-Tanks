/********************** SHIFFMAN CODE ********************************/

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// A reference to our box2d world
Box2DProcessing box2d;

/*************************** GAME VARS *******************************/

ArrayList<Boundary> boundaries; // A list we'll use to track fixed objects
ArrayList<Projectile> shells; // A list for all of our rectangles

boolean fire = false; // tech. variable for firing logic

// controls:
final char _fireBtn = ' ';
final int _rotateLeft = LEFT;
final int _rotateRight = RIGHT;
final int _scaleUp = UP;
final int _scaleDown = DOWN;
final int _moveRight = 'd';
final int _moveLeft = 'a';

float rotateGun = 0f;
final float w = 0.008;  // gun traverse speed
final float powerStep = 0.3;  // power modification scale
float modPower = 0f;
float moveDir = 0f;
float maxPower = 50f;

SPG tank;   // playable self propelled gun
SPG tank2;

/*************************** SYSTEM FUNCTIONS *******************************/

void setup() {

  size(1200, 600);  // Mihael : za moj ekran trenutno da ne koristim fullScreen()
  // smooth(); // commented to maximize physics calculations

  // template code for world generation : Box2D
  createWorld();

  // Create ArrayLists to hold projectiles
  shells = new ArrayList<Projectile>();

  // ground generation
  createTestFloor();

  // defining a new SPG
  DefSPG def = new DefSPG();
  def.colour = new PVector(50,10,10);
  def.name = "Pero";
  def.startPos = new PVector(50,400);
  def.tank_svg = loadShape("hull.svg"); // holds collision box info and display info : children paths c_box, image

  // creating first SPG
  tank = new SPG(def);

  def.colour = new PVector(10,10,50);
  def.startPos = new PVector(1000, 400);
  // second SPG
  tank2 = new SPG(def);
  tank2.gun.direction.rotate(PI);
}

void draw() {

  background(255);

  // We must always step through time!
  box2d.step();

  tank.move();
  tank.gun.aim();   // move gun on command
  tank.display();

  tank2.display();
  
  // to display gun power
  strokeWeight(10);
  strokeCap(SQUARE);
  stroke(tank.gun.power / maxPower * 255, 255 - tank.gun.power / maxPower * 255, 0);
  line(50,50,50 + 2*tank.gun.power,50);
  strokeWeight(1);

  if (fire) {
    tank.gun.fire();
  }

  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }

  // Display all the shells
  for (Projectile b: shells) {
    b.display();
  }
  
  // shells that leave the screen, we delete them
  removeLostShells();
}

void keyPressed() {

  // shoot if fire button pressed
  if(key == _fireBtn){
    fire = true;
  }

  if(key == _moveRight) {
    moveDir = 1f;
  }

  if(key == _moveLeft) {
    moveDir = -1f;
  }

  if(keyCode == _rotateLeft) {
    rotateGun = -1f;
  }

  if(keyCode == _rotateRight) {
    rotateGun = 1f;
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

  if(key == _moveLeft || key == _moveRight) {
    moveDir = 0f;
  }
}

void beginContact(Contact cp) {

  // dohvati objekte u koliziji
  Object o1 = cp.getFixtureA().getBody().getUserData();
  Object o2 = cp.getFixtureB().getBody().getUserData();

  if(o1.getClass() == Projectile.class) {
    ((Projectile)o1).delete = true;
  }
  if(o2.getClass() == Projectile.class) {
    ((Projectile)o2).delete = true;
  }
}

void endContact(Contact cp) {

}

/*************************** HELP FUNCTIONS *******************************/

void createWorld() {

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);
  box2d.listenForCollisions();
}

// just a box for now
void createTestFloor() {

  boundaries = new ArrayList<Boundary>();
  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, height-50, width, 10));
}

void removeLostShells() {

  // (note they have to be eed from both the box2d world and our list
  for (int i = shells.size()-1; i >= 0; i--) {
    Projectile b = shells.get(i);
    if (b.done()) {
      shells.remove(i);
    }
  }
}
