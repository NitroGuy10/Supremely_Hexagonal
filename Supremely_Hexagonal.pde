import java.util.HashSet;
import java.util.Arrays;

final int frameRate = 144;
HashSet<Integer> keyboard = new HashSet();
float speed = 1.0;
float rotationSpeed = 0.001;
double time = 0;
double deltaTime = 0;
float gameStartTime = 0;

color highColor = color(200, 0, 0);
color midColor = color(100, 0, 0);
color lowColor = color(50, 0, 0);

String gameState = "init";
float animationStartTime = -1;

ArrayList<Obstacle> obstacles = new ArrayList();
boolean[] killZones = new boolean[6];

float playerPosition = 0;
float functionalPlayerPosition = 0;
boolean reverseControls = false;
boolean gameOver = false;
int numObstaclesTotal = 0;

void setup ()
{
  size(1000, 1000, P2D);
  frameRate(frameRate);
}

void draw ()
{
  if (gameState.equals("init"))
  {
    gameStartTime = millis();
  }
  doKeyboard();
  if (!gameOver)
  {
    deltaTime = (((millis() - gameStartTime) / 10.5) * 2.4) - time;
    time += deltaTime;
    
    background(lowColor);
    translate(width / 2, height / 2);
    rotate(getTime() * rotationSpeed);
    //scale(sin(time * 0.01) + 1);  // SUPER COOL GAME MODE
    scale(sin(getTime() * 0.015) * 0.1 + 1);
    
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
    
    // Manage kill zones
    if (killZones[min(5, (int) functionalPlayerPosition / 126)])
    {
      textAlign(CENTER, CENTER);
      textSize(500);
      fill(highColor);
      text("dead", 0, 0);
      gameOver = true;
    }
    killZones = new boolean[6];
    
    // Draw player
    fill(highColor);
    pushMatrix();
    rotate(floor(functionalPlayerPosition / 126) * -2 * PI / 6);
    circle((functionalPlayerPosition % 126) - 63, 110, 10);
    popMatrix();
    
    
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
    
    // Spawn new obstacles
    // TODO if gameState == "game_random"
    if (time > (numObstaclesTotal + 1) * 300)
    {
      boolean[] presence = {true, true, true, true, true, true};
      for (int i = 0; i < random(1.01, 3); i++)
      {
        presence[(int) random(6)] = false;
      }
      obstacles.add(new Obstacle(30, presence));
      numObstaclesTotal++;
    }
    
    // Update and display obstacles
    noStroke();
    fill(highColor);
    for (int i = 0; i < obstacles.size(); i++)
    {
      if (obstacles.get(i).update())
      {
        obstacles.get(i).display();
      }
      else
      {
        i--;
      }
    }
  }
  else
  {
    
  }
  
  // Draw stuff
  if (gameState.equals("init"))
  {
    gameState = "animation_start";
    animationStartTime = getTime();
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
    gameOver = false;
    obstacles.clear();
  }
  if (keyboard.contains(LEFT))
  {
      playerPosition += 2 * deltaTime;
  }
  else if (keyboard.contains(RIGHT))
  {
    playerPosition -= 2 * deltaTime;
  }
}

float getTime ()
{
  return (float) time;
}
