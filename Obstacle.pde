public class Obstacle
{
  private int thickness;  // Because height, width, and length are already used by Processing lol
  private float position;  // How close the bottom edge of the shape is to the center
  private boolean[] presence;
  private float creationTime;
  
  public Obstacle (int thickness, boolean[] presence)
  {
    creationTime = time;
    this.thickness = thickness;
    this.presence = presence;
  }
  
  public boolean update ()
  {
    position = 1200 + (time - creationTime) * -speed;
    
    if (position < 110 + 20 && !(position + thickness < 110 + 20))
    {
      for (int i = 0; i < 6; i++)
      {
        killZones[i] = presence[i];
      }
    }
    
    if (position + thickness < 100)
    {
      obstacles.remove(this);
      return false;
    }
    
    return true;
  }
  
  public void display ()
  {
    float bottomPosition = position;
    if (position < 100)
    {
      bottomPosition = 100;
    }
    for (int section = 0; section < 6; section++)
    {
      if (presence[section])
      {
        pushMatrix();
        rotate(section * -2 * PI / 6);
        quad(cos(PI / 3) * bottomPosition, sin(PI / 3) * bottomPosition,
        cos(PI / 3) * (position + thickness), sin(PI / 3) * (position + thickness),
        cos(2 * PI / 3) * (position + thickness), sin(2 * PI / 3) * (position + thickness),
        cos(2 * PI / 3) * bottomPosition, sin(2 * PI / 3) * bottomPosition);
        popMatrix();
      }
    }
  }
}
