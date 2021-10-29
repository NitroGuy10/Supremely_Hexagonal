import java.util.HashSet;
import java.util.Arrays;

final int frameRate = 144;
HashSet<Integer> keyboard = new HashSet();
float speed = 1.0;
float rotationSpeed = 0.001;
float time = 0;

color highColor = color(200, 0, 0);
color midColor = color(100, 0, 0);
color lowColor = color(50, 0, 0);

String animation = "init";
float animationStart = -1;

ArrayList<Obstacle> obstacles = new ArrayList();
boolean[] killZones = new boolean[6];

float playerPosition = 0;
float functionalPlayerPosition = 0;
boolean reverseControls = false;
boolean gameOver = false;

void setup ()
{
  size(1000, 1000, P2D);
  frameRate(frameRate);
}

void draw ()
{
  doKeyboard();
  if (!gameOver)
  {
    time = frameCount * (frameRate / 60.0);
    
    background(lowColor);
    translate(width / 2, height / 2);
    rotate(time * rotationSpeed);
    //scale(sin(time * 0.01) + 1);  // SUPER COOL GAME MODE
    scale(sin(time * 0.015) * 0.1 + 1);
    
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
    
    if (round(time) % 150 == 0)
    {
      boolean[] presence = {true, true, true, true, true, true};
      for (int i = 0; i < random(1, 3); i++)
      {
        presence[(int) random(6)] = false;
      }
      obstacles.add(new Obstacle(30, presence));
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
      playerPosition += 3.5;
  }
  else if (keyboard.contains(RIGHT))
  {
    playerPosition -= 3.5;
  }
}
