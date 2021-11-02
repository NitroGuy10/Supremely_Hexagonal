import java.util.HashSet;
import java.util.Arrays;

HashSet<Integer> keyboard = new HashSet();
float speed = 1.0;
float rotation = 0;
float rotationSpeed = 0.001;
double time = 0;
double deltaTime = 0;
float gameStartTime = 0;

color highColor;
color midColor;
color lowColor;

String gameState = "init";
float animationStartTime = -1;
float animationVariable = 0;

ArrayList<Obstacle> obstacles = new ArrayList();
float nextObstacleTypeTime = -1;
float obstacleVariable = 0;
final String[] obstacleTypes = {"game_random", "game_tri", "game_one"};
boolean[] killZones = new boolean[6];

float playerPosition = 0;
float functionalPlayerPosition = 0;
boolean reverseControls = false;
boolean gameOver = true;
int numObstaclesTotal = 0;
int score = -3;

////////// Settings //////////
final int frameRate = 144;
final boolean doObstacleTypes = false;
final boolean doSuperCrazyWobble = false;
//////////////////////////////

void setup ()
{
  size(1000, 1000, P2D);
  frameRate(frameRate);
  
  colorMode(HSB);
}

void draw ()
{
  if (gameState.equals("init"))
  {
    // gameState = "game";
    gameState = "animation_start";
    gameStartTime = millis();
    animationStartTime = gameStartTime;
  }
  
  // Time logic
  doKeyboard();
  deltaTime = (((millis() - gameStartTime) / 10.5) * 2.4) - time;
  time += deltaTime;
  
  // Game logic
  if (!gameOver)
  {    
    speed = (float) (1 + (time / 2500));
    
    // Define colors
    int hue = (int) (time / 60) % 256;
    highColor = color(hue, 255, 200);
    midColor = color(hue, 255, 100);
    lowColor = color(hue, 255, 50);
    
    // Calculate player position
    if (playerPosition >= 0)
    {
      functionalPlayerPosition = playerPosition % (126 * 6);
    }
    else
    {
      functionalPlayerPosition = (126 * 6) + (playerPosition % (126 * 6));
    }
    // println(playerPosition + " --> " + functionalPlayerPosition + " --> ZONE: " + ((int)functionalPlayerPosition / 126));
    
    if (doObstacleTypes && time > nextObstacleTypeTime)
    {
      nextObstacleTypeTime = getTime() + random(500, 2000);
      obstacleVariable = -5;

      String prevGameState = gameState;
      while (prevGameState.equals(gameState))
      {
        gameState = obstacleTypes[(int) random(obstacleTypes.length)];
      }
      println(gameState);
    }
    
    
    // Spawn new obstacles
    if (time > (numObstaclesTotal + 1) * (100 - speed * 10))
    {
      if (gameState.equals("game_random"))
      {
        if (obstacleVariable < 0) {}
        else if (obstacleVariable % 4 == 0)
        {
          boolean[] presence = {true, true, true, true, true, true};
          for (int i = 0; i < random(1.01, 3); i++)
          {
            presence[(int) random(6)] = false;
          }
          obstacles.add(new Obstacle(30, presence));
          score++;
        }
        obstacleVariable++;
      }
      else if (gameState.equals("game_tri"))
      {
        if (obstacleVariable < 0) {}
        else if (obstacleVariable % 3 == 0)
        {
          if (random(1) > 0.5)
          {
            obstacles.add(new Obstacle(30, new boolean[] {true, false, true, false, true, false}));
          }
          else
          {
            obstacles.add(new Obstacle(30, new boolean[] {false, true, false, true, false, true}));
          }
          score++;
        }
        obstacleVariable++;
      }
      else if (gameState.equals("game_one"))
      {
        if (obstacleVariable < 0) {}
        else if (obstacleVariable % 5 == 0)
        {
          boolean[] presence = {true, true, true, true, true, true};
          presence[(int) random(6)] = false;
          obstacles.add(new Obstacle(30, presence));
          score++;
        }
        obstacleVariable++;
      }
      
      numObstaclesTotal++;
    }
    
    // Update obstacles
    for (int i = 0; i < obstacles.size(); i++)
    {
      if (!obstacles.get(i).update())
      {
        i--;
      }
    }
    
    // Manage kill zones and gameover
    if (killZones[min(5, (int) functionalPlayerPosition / 126)])
    {
      //textAlign(CENTER, CENTER);
      //textSize(500);
      //fill(highColor);
      //text("dead", 0, 0);
      gameOver = true;
      
      gameState = "animation_gameover";
      animationStartTime = getTime();
      animationVariable = 1;
      //obstacles.clear();
      rotationSpeed = -0.003;
    }
    killZones = new boolean[6];
  }
  else
  {
    // animations and whatever
    if (gameState.equals("animation_gameover"))
    {
      if (getTime() - animationStartTime < 500)
      {
        rotationSpeed = -0.8 / (getTime() - animationStartTime);
        if (getTime() - animationStartTime > 20 * animationVariable && getTime() - animationStartTime < 150)
        {
          Obstacle o = new Obstacle(10, new boolean[] {true, true, true, true, true, true});
          o.position = 100;
          obstacles.add(o);
          animationVariable++;
        }
        
        
        for (Obstacle o : obstacles)
        {
          o.position += deltaTime * 3.5;
        }
      }
      else
      {
        obstacles.clear();
        gameState = "dead";
      }
    }
    else if (gameState.equals("animation_start"))
    {
      for (int i = 0; i < obstacles.size(); i++)
      {
        obstacles.get(i).position -= deltaTime * 7;
        if (obstacles.get(i).position + obstacles.get(i).thickness < 100)
        {
          obstacles.remove(i);
          i--;
        }
      }
      if (obstacles.isEmpty())
      {
        gameState = "game_random";
        numObstaclesTotal = 0;
        gameOver = false;
        speed = 1.0;
        score = -3;
      }
    }
  }
  
  /////////// Draw stuff ///////////
  //println(time);
  
  rotation += (getDeltaTime() * rotationSpeed);
  
  background(lowColor);
  translate(width / 2, height / 2);
  if (doSuperCrazyWobble)
  {
    scale(sin(getTime() * 0.01) + 1);
  }
  else
  {
    scale(sin(getTime() * 0.015 * (speed / 10 + 1)) * 0.1 + 1);
  }
  rotate(rotation);
  
  
  // Draw background
  noStroke();
  fill(midColor);
  for (int section = 0; section < 6; section += 2)
  {
    pushMatrix();
    rotate(section * 2 * PI / 6);
    quad(cos(PI / 3) * 100, sin(PI / 3) * 100,
      cos(PI / 3) * 1000, sin(PI / 3) * 1000,
      cos(2 * PI / 3) * 1000, sin(2 * PI / 3) * 1000,
      cos(2 * PI / 3) * 100, sin(2 * PI / 3) * 100);
    popMatrix();
  }
  
  // Draw player
  if (!gameOver)
  {
    fill(highColor);
    pushMatrix();
    rotate(floor(functionalPlayerPosition / 126) * -2 * PI / 6);
    circle((functionalPlayerPosition % 126) - 63, 110, 10);
    popMatrix();
  }
  
  
  // Draw center hexagon
  stroke(highColor);
  strokeWeight(5);
  for (int section = 0; section < 6; section++)
  {
    pushMatrix();
    rotate(section * 2 * PI / 6);
    line(cos(PI / 3) * 100, sin(PI / 3) * 100, cos(2 * PI / 3) * 100, sin(2 * PI / 3) * 100);
    popMatrix();
  }
  
  // Display obstacles
  noStroke();
  fill(highColor);
  for (Obstacle o : obstacles)
  {
    o.display();
  }
  
  // Display score
  if (gameOver)
  {
    fill(highColor);
    pushMatrix();
    rotate(-rotation);
    textAlign(CENTER, CENTER);
    textSize(80);
    text(score, 0, 0);
    popMatrix();
  }
}

void keyPressed ()
{
  if (key == ENTER || key == RETURN)
  {
    keyboard.add(-1);
  }
  else if (!keyboard.contains(keyCode))
  {
    keyboard.add(keyCode);
  }
}

void keyReleased ()
{
  if (key == ENTER || key == RETURN)
  {
    keyboard.remove(-1);
  }
  else if (keyboard.contains(keyCode))
  {
    keyboard.remove(keyCode);
  }
}

void doKeyboard ()
{
  if (keyboard.contains(-1) && gameOver)
  {
    startGame();
  }
  if (keyboard.contains(LEFT))
  {
      playerPosition += (1.825 + (speed / 8)) * deltaTime;
  }
  else if (keyboard.contains(RIGHT))
  {
    playerPosition -= (1.825 + (speed / 8)) * deltaTime;
  }
}

float getTime ()
{
  return (float) time;
}

float getDeltaTime ()
{
  return (float) deltaTime;
}

void startGame ()
{
  //obstacles.clear();
  gameState = "animation_start";
  //gameState = "game";
  rotationSpeed = 0.001;
  gameStartTime = millis() + 1;
  time = 1;
}
