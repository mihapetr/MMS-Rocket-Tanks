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
ArrayList<Explosion> explosions; // A list of all active explosions;

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

// player variables
int currentPlayer; // 1 for the first player, 2 for the second player
int playerOneScore;
int playerTwoScore;
int turnsPerPlayer = 3;
int currentTurnNumber;
boolean gameOver;
boolean tankIsMoving;
int tankMovementStartTime;
int tankMovementDuration = 2000;
int tankMovementsPerPlayer = 4;
int playerOneTankMovementsLeft;
int playerTwoTankMovementsLeft;
int projectileStartTime;
int projectileMinDuration = 1000;
boolean projectileIsActive; // active until all explosions and projectiles removed

// button properties
int universalButtonYValue = 640;

int restartButtonX; // depends on screen width, initialized in setup
int restartButtonY = 170;
int restartButtonWidth = 180;
int restartButtonHeight = 50;

int fireButtonX; // depends on screen width, initialized in setup
int fireButtonY = universalButtonYValue;
int fireButtonWidth = 200;
int fireButtonHeight = 50;

int rotateLeftButtonX; // depends on screen width, initialized in setup
int rotateLeftButtonY = universalButtonYValue;
int rotateLeftButtonWidth = 50;
int rotateLeftButtonHeight = 50;

int rotateRightButtonX; // depends on screen width, initialized in setup
int rotateRightButtonY = universalButtonYValue;
int rotateRightButtonWidth = 50;
int rotateRightButtonHeight = 50;

int rotateButtonX; // depends on screen width, initialized in setup
int rotateButtonY = universalButtonYValue;
int rotateButtonWidth = 130;
int rotateButtonHeight = 50;

int powerButtonX; // depends on screen width, initialized in setup
int powerButtonY = universalButtonYValue;
int powerButtonWidth = 120;
int powerButtonHeight = 50;

int powerIncreaseButtonX; // depends on screen width, initialized in setup
int powerIncreaseButtonY = universalButtonYValue;
int powerIncreaseButtonWidth = 50;
int powerIncreaseButtonHeight = 50;

int powerDecreaseButtonX; // depends on screen width, initialized in setup
int powerDecreaseButtonY = universalButtonYValue;
int powerDecreaseButtonWidth = 50;
int powerDecreaseButtonHeight = 50;

int moveLeftButtonX; // depends on screen width, initialized in setup
int moveLeftButtonY = universalButtonYValue;
int moveLeftButtonWidth = 50;
int moveLeftButtonHeight = 50;

int moveRightButtonX; // depends on screen width, initialized in setup
int moveRightButtonY = universalButtonYValue;
int moveRightButtonWidth = 50;
int moveRightButtonHeight = 50;

int moveButtonX; // depends on screen width, initialized in setup
int moveButtonY = universalButtonYValue;
int moveButtonWidth = 100;
int moveButtonHeight = 50;

SPG tank;   // playable self propelled gun
SPG tank2;
Ground ground;
Surface surface;

/*************************** SYSTEM FUNCTIONS *******************************/

void setup() {

  size(1300, 700);  // Mihael : za moj ekran trenutno da ne koristim fullScreen()
  // smooth(); // commented to maximize physics calculations

  initializeGame();
  setupButtonXPositions();
}

void draw() {

  background(255);
  //surface.display();

  ground.display();

  // We must always step through time!
  box2d.step();

  displayExplosions();
  
  displayBoundaries();
  
  displayAndHandleTanks(); 
  
  displayGUI();
  
  checkForFire();
  
  displayShells();
  
  // for testing the impact
  /*rectMode(CORNER);
  rect(tank.getPositionX(), tank.getPositionY(), 40, 18);
  rect(tank2.getPositionX(), tank2.getPositionY(), 40, 12);
  */
  
  // shells that leave the screen, we delete them
  removeLostShells();
  
  // explosions that reach full width are removed
  removeFinishedExplosions();
  
  // checks for all projectile related actions to be finished and checks for game end
  endOfTurn();
}

void keyPressed() {

  // shoot if fire button pressed
  if(key == _fireBtn && gameOver == false){
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
    Explosion e = createExplosion(((Projectile)o2).getPositionX(), ((Projectile)o2).getPositionY(), "test");
    giveOrTakePoints(e);
    ((Projectile)o1).delete = true;
  }
  if(o2.getClass() == Projectile.class) {
    Explosion e = createExplosion(((Projectile)o2).getPositionX(), ((Projectile)o2).getPositionY(), "test");
    giveOrTakePoints(e);
    ((Projectile)o2).delete = true;
  }

  if(o1.getClass() == SPG.class && o2.getClass() == Ground.class){
    ((SPG)o1).onGround = true;
  }
  if(o2.getClass() == SPG.class && o1.getClass() == Ground.class){
    ((SPG)o2).onGround = true;
  }
}

void endContact(Contact cp) {

  Object o1 = cp.getFixtureA().getBody().getUserData();
  Object o2 = cp.getFixtureB().getBody().getUserData();

  if(o1.getClass() == SPG.class && o2.getClass() == Ground.class){
    ((SPG)o1).onGround = false;
  }
  if(o2.getClass() == SPG.class && o1.getClass() == Ground.class){
    ((SPG)o2).onGround = false;
  }
}

Explosion createExplosion(float x, float y, String type){
  Explosion e = new Explosion(x,y,type);
  explosions.add(e);
  return e;
}

void initializeGame(){
  
  // template code for world generation : Box2D
  createWorld();
  //surface = new Surface();

  // Create ArrayLists to hold projectiles
  shells = new ArrayList<Projectile>();

  // Create ArrayLists to hold explosions;
  explosions = new ArrayList<Explosion>();
  
  // ground generation (deprecated)
  createTestFloor();

  // testing
  ground = new Ground("ground.svg", new Vec2(0, 200));

  // defining a new SPG
  DefSPG def = new DefSPG();
  def.colour = new PVector(10,60,10);
  def.name = "Pero";
  def.startPos = new PVector(40,500);
  def.tank_svg = loadShape("hull.svg"); // holds collision box info and display info : children paths c_box, image

  // creating first SPG
  tank = new SPG(def);

  // change start settings
  def.colour = new PVector(10,10,50);
  def.startPos = new PVector(1000, 400);
  def.name = "Igaly";

  // second SPG
  tank2 = new SPG(def);
  tank2.gun.direction.rotate(PI);
  
  // initialize players
  playerOneScore = 0;
  playerTwoScore = 1;
  currentPlayer = int(random(1, 3)); // randomly choose 1 or 2
  currentTurnNumber = 1;
  gameOver = false;
  tankIsMoving = false;
  projectileIsActive = false;
  playerOneTankMovementsLeft = tankMovementsPerPlayer;
  playerTwoTankMovementsLeft = tankMovementsPerPlayer;
}

void gameOver(){
  gameOver=true;
}

void mousePressed() {
  float restartButtonHalfWidth = restartButtonWidth / 2.0;
  float restartButtonHalfHeight = restartButtonHeight / 2.0;
  float fireButtonHalfWidth = fireButtonWidth / 2.0;
  float fireButtonHalfHeight = fireButtonHeight / 2.0;
  float rotateLeftButtonHalfWidth = rotateLeftButtonWidth / 2.0;
  float rotateLeftButtonHalfHeight = rotateLeftButtonHeight / 2.0;
  float rotateRightButtonHalfWidth = rotateRightButtonWidth / 2.0;
  float rotateRightButtonHalfHeight = rotateRightButtonHeight / 2.0;
  float powerIncreaseButtonHalfWidth = powerIncreaseButtonWidth / 2.0;
  float powerIncreaseButtonHalfHeight = powerIncreaseButtonHeight / 2.0;
  float powerDecreaseButtonHalfWidth = powerDecreaseButtonWidth / 2.0;
  float powerDecreaseButtonHalfHeight = powerDecreaseButtonHeight / 2.0;
  float moveLeftButtonHalfWidth = moveLeftButtonWidth / 2.0;
  float moveLeftButtonHalfHeight = moveLeftButtonHeight / 2.0;
  float moveRightButtonHalfWidth = moveRightButtonWidth / 2.0;
  float moveRightButtonHalfHeight = moveRightButtonHeight / 2.0;
  
  if (gameOver == true &&
      mouseX >= restartButtonX - restartButtonHalfWidth && mouseX <= restartButtonX + restartButtonHalfWidth &&
      mouseY >= restartButtonY - restartButtonHalfHeight && mouseY <= restartButtonY + restartButtonHalfHeight) {
    initializeGame();
  }
  
  else if (gameOver == false && tankIsMoving == false && projectileIsActive == false &&
      mouseX >= fireButtonX - fireButtonHalfWidth && mouseX <= fireButtonX + fireButtonHalfWidth &&
      mouseY >= fireButtonY - fireButtonHalfHeight && mouseY <= fireButtonY + fireButtonHalfHeight) {
    fire = true;
  }
  
  else if (gameOver == false &&
      mouseX >= rotateLeftButtonX - rotateLeftButtonHalfWidth && mouseX <= rotateLeftButtonX + rotateLeftButtonHalfWidth &&
      mouseY >= rotateLeftButtonY - rotateLeftButtonHalfHeight && mouseY <= rotateLeftButtonY + rotateLeftButtonHalfHeight) {
    rotateGun = -1f;
  }
  
  else if (gameOver == false &&
      mouseX >= rotateRightButtonX - rotateRightButtonHalfWidth && mouseX <= rotateRightButtonX + rotateRightButtonHalfWidth &&
      mouseY >= rotateRightButtonY - rotateRightButtonHalfHeight && mouseY <= rotateRightButtonY + rotateRightButtonHalfHeight) {
    rotateGun = 1f;
  }
  
  else if (gameOver == false &&
      mouseX >= powerIncreaseButtonX - powerIncreaseButtonHalfWidth && mouseX <= powerIncreaseButtonX + powerIncreaseButtonHalfWidth &&
      mouseY >= powerIncreaseButtonY - powerIncreaseButtonHalfHeight && mouseY <= powerIncreaseButtonY + powerIncreaseButtonHalfHeight) {
    modPower = 1f;
  }
  
  else if (gameOver == false &&
      mouseX >= powerDecreaseButtonX - powerDecreaseButtonHalfWidth && mouseX <= powerDecreaseButtonX + powerDecreaseButtonHalfWidth &&
      mouseY >= powerDecreaseButtonY - powerDecreaseButtonHalfHeight && mouseY <= powerDecreaseButtonY + powerDecreaseButtonHalfHeight) {
    modPower = -1f;
  }
  
  else if (gameOver == false && tankIsMoving == false &&
      mouseX >= moveLeftButtonX - moveLeftButtonHalfWidth && mouseX <= moveLeftButtonX + moveLeftButtonHalfWidth &&
      mouseY >= moveLeftButtonY - moveLeftButtonHalfHeight && mouseY <= moveLeftButtonY + moveLeftButtonHalfHeight) {
    if (currentPlayer == 1 && playerOneTankMovementsLeft > 0) {
      playerOneTankMovementsLeft --;
      tankIsMoving = true;
      tankMovementStartTime = millis();
      moveDir = -1f;
    }
    else if (currentPlayer == 2 && playerOneTankMovementsLeft > 0) {
      playerTwoTankMovementsLeft --;
      tankIsMoving = true;
      tankMovementStartTime = millis();
      moveDir = -1f;
    }
  }
  
  else if (gameOver == false && tankIsMoving == false &&
      mouseX >= moveRightButtonX - moveRightButtonHalfWidth && mouseX <= moveRightButtonX + moveRightButtonHalfWidth &&
      mouseY >= moveRightButtonY - moveRightButtonHalfHeight && mouseY <= moveRightButtonY + moveRightButtonHalfHeight) {
    
    if (currentPlayer == 1 && playerOneTankMovementsLeft > 0) {
      playerOneTankMovementsLeft --;
      tankIsMoving = true;
      moveDir = 1f;
      tankMovementStartTime = millis();
    }
    else if (currentPlayer == 2 && playerTwoTankMovementsLeft > 0) {
      playerTwoTankMovementsLeft --;
      tankIsMoving = true;
      moveDir = 1f;
      tankMovementStartTime = millis();
    }
  }
}

void mouseReleased(){
  rotateGun = 0f;
  modPower = 0f;
}

void displayAndHandleTanks(){
  
  if(tankIsMoving){
    if(millis() - tankMovementStartTime >= tankMovementDuration){
      tankIsMoving = false;
    }
  }

  if(currentPlayer == 1){
    if(tankIsMoving){
      tank.move();
    }
    tank.gun.aim();   // move gun on command
  }
  else if(currentPlayer == 2){
    if(tankIsMoving){
      tank2.move();
    }
    tank2.gun.aim();
  }
  
  tank.display();
  tank2.display();
}

void giveOrTakePoints(Explosion e){
  if (currentPlayer == 1){
    println(dist(e.x, e.y, tank.getPositionX(), tank.getPositionY()));
  }
  
  
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
  //boundaries.add(new Boundary(width/2, height-50, width, 10));
  
  //Zvonimir testne boundaries
  boundaries.add(new Boundary(5, height/2 - 60, 10, 580));
  boundaries.add(new Boundary(width-5, height/2 - 60, 10, 580));
  boundaries.add(new Boundary(width/2, height-130, width, 25));
}

void checkForFire() {
  if (fire) {
    projectileIsActive = true;
    if(currentPlayer == 1) {
      tank.gun.fire();
    }
    else if(currentPlayer == 2){
      tank2.gun.fire();
    }
  }
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

void removeFinishedExplosions() {
  
  for (int i = explosions.size()-1; i >= 0; i--) {
    Explosion e = explosions.get(i);
    if (e.done()) {
      explosions.remove(i);
    }
  }
}

void endOfTurn(){
  if(explosions.size() == 0 && shells.size() == 0 && projectileIsActive == true){
    projectileIsActive = false;
      currentTurnNumber++;
      if(currentTurnNumber > 2*turnsPerPlayer){
        gameOver();
      } 
      else {
        if(currentPlayer == 1) {
          currentPlayer = 2;
        }
        else if(currentPlayer == 2){
          currentPlayer = 1;
        }
      }
  }
}

/**************************** GUI FUNCTIONS *******************************/
void displayGUI(){
  
  if(gameOver == false){
    displayGunPowers();
    displayTurnCounter();
    displayGunAngle();
    displayMovesLeft();
  }
  else{
    displayGameOverMessage();
  }
  
  displayPlayerNames();
  displayScores();
  displayButtons();
}

void displayPlayerNames(){
  
  textSize(22);
  
  fill(currentPlayer == 1 && gameOver == false ? color(255, 0, 0) : color(0));
  textAlign(LEFT, TOP);
  text(tank.name, 50, 20); 
  
  fill(currentPlayer == 2 && gameOver == false ? color(255, 0, 0) : color(0));
  textAlign(RIGHT, TOP);
  text(tank2.name, width-50, 20);
}

void displayGunPowers(){
  
  // to display gun power line of tank
  strokeWeight(10);
  strokeCap(SQUARE);
  stroke(tank.gun.power / maxPower * 255, 255 - tank.gun.power / maxPower * 255, 0);
  line(50,50,50 + 2*tank.gun.power,50);
  strokeWeight(1);
  stroke(0);
  
  // to display gun power line of tank2
  strokeWeight(10);
  strokeCap(SQUARE);
  stroke(tank2.gun.power / maxPower * 255, 255 - tank2.gun.power / maxPower * 255, 0);
  line(width - 172,50,width - 172 + 2*tank2.gun.power,50);
  strokeWeight(1);
  stroke(0);
  
  // to display gun power number of tanks
  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  text(int(tank.gun.power*2), 52 + 2*tank.gun.power, 45); 
  text(int(tank2.gun.power*2), width - 170 + 2*tank2.gun.power, 45); 
}

void displayScores(){
  
  textSize(22);
  
  fill(currentPlayer == 1 && gameOver == false ? color(255, 0, 0) : color(0));
  textAlign(LEFT, TOP);
  text(playerOneScore, 60 + textWidth(tank.name), 20);
  
  fill(currentPlayer == 2 && gameOver == false ? color(255, 0, 0) : color(0));
  textAlign(RIGHT, TOP);
  text(playerTwoScore, width - 60 - textWidth(tank2.name), 20);
}

void displayTurnCounter(){
  
  textSize(22);
 
  fill(0);
  textAlign(CENTER, TOP);
  text("TURN: " + currentTurnNumber + "/" + 2*turnsPerPlayer , width/2, 20);
}

void displayGameOverMessage(){
  
  textSize(36);
  
  fill(0);
  textAlign(CENTER, TOP);
  if(playerOneScore > playerTwoScore){
    text(tank.name + "WINS!", width/2, 100);
  }
  else if(playerOneScore < playerTwoScore){
    text(tank2.name + " WINS!", width/2, 100);
  }
  else{  
    text("IT'S A TIE!", width/2, 100);
  }
  
  fill(0);
  rect(restartButtonX, restartButtonY, restartButtonWidth, restartButtonHeight);
  fill(255,255,255);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("RESTART GAME", restartButtonX, restartButtonY, restartButtonWidth, restartButtonHeight);
}

void displayGunAngle(){
  
  textSize(16);
  
  textAlign(LEFT, TOP);
  if(degrees(atan2(tank.gun.direction.x, tank.gun.direction.y)) < 0) {
    text("angle: " + (360 + int(degrees(atan2(tank.gun.direction.x, tank.gun.direction.y)) + degrees(tank.body.getAngle())) -90) + " \u00B0", 50, 62);
  }
  else{
    text("angle: " + (int(degrees(atan2(tank.gun.direction.x, tank.gun.direction.y)) + degrees(tank.body.getAngle())) -90) + " \u00B0", 50, 62);
  }
  
  textAlign(RIGHT, TOP);
  if(degrees(atan2(tank2.gun.direction.x, tank2.gun.direction.y)) < 0) {
    text("angle: " + (360 + int(degrees(atan2(tank2.gun.direction.x, tank2.gun.direction.y)) + degrees(tank2.body.getAngle())) -90) + " \u00B0", width-50, 62);
  }
  else{
    text("angle: " + (int(degrees(atan2(tank2.gun.direction.x, tank2.gun.direction.y)) + degrees(tank2.body.getAngle())) -90) + " \u00B0", width-50, 62);
  }
  
}

void displayMovesLeft(){
  
  textSize(16);
  
  textAlign(LEFT, TOP);
  fill(color(0));
  textAlign(LEFT, TOP);
  text("moves left: " + playerOneTankMovementsLeft, 50, 82); 
  
  fill(color(0));
  textAlign(RIGHT, TOP);
  text("moves left: " + playerTwoTankMovementsLeft, width-50, 82);
}

void displayBoundaries(){
  
  for (Boundary wall: boundaries) {
    wall.display();
  }
}

void displayExplosions(){
  
  for (Explosion e: explosions){
    e.display();
  }
}

void displayShells() {
  for (Projectile b: shells) {
    b.display();
  }
}

void setupButtonXPositions(){
  restartButtonX = width/2;
  fireButtonX = width/2;
  
  rotateLeftButtonX = width/2 - fireButtonWidth/2 - rotateRightButtonWidth - rotateButtonWidth - rotateLeftButtonWidth/2 - 270;
  rotateButtonX = width/2 - fireButtonWidth/2 - rotateRightButtonWidth - rotateButtonWidth/2 - 265;
  rotateRightButtonX = width/2 - fireButtonWidth/2  - rotateRightButtonWidth/2 - 260;
  
  moveLeftButtonX = width/2 + fireButtonWidth/2 + moveLeftButtonWidth/2 + 15;
  moveButtonX = width/2 + fireButtonWidth/2 + moveLeftButtonWidth + moveButtonWidth/2 + 20;
  moveRightButtonX = width/2 + fireButtonWidth/2  + moveButtonWidth + moveLeftButtonWidth + moveRightButtonWidth/2 + 25;
  
  powerButtonX = width/2 - fireButtonWidth/2 - powerIncreaseButtonWidth - powerDecreaseButtonWidth - powerButtonWidth/2 - 25;
  powerIncreaseButtonX = width/2 - fireButtonWidth/2 - powerDecreaseButtonWidth - powerIncreaseButtonWidth/2 - 20;
  powerDecreaseButtonX = width/2 - fireButtonWidth/2  - powerDecreaseButtonWidth/2 - 15;
}

void displayButtons(){
  
  rectMode(CENTER);
  textSize(34);
  textAlign(CENTER, CENTER);
  
  // fire button
  fill(color(212, 81, 0));
  rect(fireButtonX, fireButtonY, fireButtonWidth, fireButtonHeight);
  fill(color(255, 241, 41));
  text("FIRE", fireButtonX, fireButtonY, fireButtonWidth, fireButtonHeight);
  
  // rotate buttons
  fill(color(73, 1, 77));
  rect(rotateButtonX, rotateButtonY, rotateButtonWidth, rotateButtonHeight);
  rect(rotateLeftButtonX, rotateLeftButtonY, rotateLeftButtonWidth, rotateLeftButtonHeight);
  rect(rotateRightButtonX, rotateRightButtonY, rotateRightButtonWidth, rotateRightButtonHeight);
  fill(color(255, 241, 41));
  text("ROTATE",rotateButtonX, rotateButtonY, rotateButtonWidth, rotateButtonHeight);
  text("\u2190",rotateLeftButtonX, rotateLeftButtonY, rotateLeftButtonWidth, rotateLeftButtonHeight);
  text("\u2192",rotateRightButtonX, rotateRightButtonY, rotateRightButtonWidth, rotateRightButtonHeight);
  
  // power buttons
  fill(color(45, 166, 2));
  rect(powerIncreaseButtonX, powerIncreaseButtonY, powerIncreaseButtonWidth, powerIncreaseButtonHeight);
  rect(powerButtonX, powerButtonY, powerButtonWidth, powerButtonHeight);
  rect(powerDecreaseButtonX, powerDecreaseButtonY, powerDecreaseButtonWidth, powerDecreaseButtonHeight);
  fill(color(255, 241, 41));
  text("+",powerIncreaseButtonX, powerIncreaseButtonY, powerIncreaseButtonWidth, powerIncreaseButtonHeight);
  text("POWER",powerButtonX, powerButtonY, powerButtonWidth, powerButtonHeight);
  text("-",powerDecreaseButtonX, powerDecreaseButtonY, powerDecreaseButtonWidth, powerDecreaseButtonHeight);
  
  //move buttons
  fill(color(0, 33, 179));
  rect(moveButtonX, moveButtonY, moveButtonWidth, moveButtonHeight);
  rect(moveLeftButtonX, moveLeftButtonY, moveLeftButtonWidth, moveLeftButtonHeight);
  rect(moveRightButtonX, moveRightButtonY, moveRightButtonWidth, moveRightButtonHeight);
  fill(color(255, 241, 41));
  text("MOVE",moveButtonX, moveButtonY, moveButtonWidth, moveButtonHeight);
  text("\u2190",moveLeftButtonX, moveLeftButtonY, moveLeftButtonWidth, moveLeftButtonHeight);
  text("\u2192",moveRightButtonX, moveRightButtonY, moveRightButtonWidth, moveRightButtonHeight);
  
}
