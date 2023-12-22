
abstract class Field<T>
{
  int size;
  float scale; 
  
  float noiseScale; 
  float noiseSpeed; 
  float noiseLevel;
  
  protected Object[][] field;
  
  Field(int resolution, float coherence, float speed, float flux)
  {
    this.size = resolution;
    this.scale = width / resolution;
    this.noiseScale = coherence;
    this.noiseSpeed = speed;
    this.noiseLevel = flux;
    
    this.field = new Object[size][size];
  }
  
  protected abstract T createElement(float value);
  
  protected abstract void drawElement(int x, int y); 
  
  void update()
  {
    for (int x=0; x < size; x++)
    {
      for (int y=0; y < size; y++)
      {
        float nx = x * noiseScale;
        float ny = y * noiseScale;
        float ns = noise(nx, ny, frameCount * noiseSpeed) * noiseLevel * TWO_PI;
        
        this.field[x][y] = this.createElement(ns);
      }
    }
  }
  
  T get(int x, int y)
  {
    return (T) this.field[x][y];
  }
  
  T getByCoord(int px, int py)
  {
    float x_off = max(0, px - this.scale/2);
    float y_off = max(0, py - this.scale/2);
    
    int x = floor(x_off/this.scale);
    int y = floor(y_off/this.scale);
    
    return (T) this.field[x][y];
  } 
     
  void redraw()
  {    
    for (int x=0; x < size; x++)
    {
      for (int y=0; y < size; y++)
      {
        this.drawElement(x, y);
      }
    }
  }
  
  void draw()
  {    
    this.update();
    this.redraw();
  }
  
}

class NoiseField extends Field<Float>
{
  NoiseField(int resolution, float coherence, float speed, float flux)
  {
    super(resolution, coherence, speed, flux);
  }
  
  protected Float createElement(float value)
  {
    return value;
  }
  
  protected void drawElement(int x, int y) 
  {
    int px = floor(x*this.scale + this.scale/2);
    int py = floor(y*this.scale + this.scale/2);
    
    float noise = this.get(x, y);
        
    stroke(0);
    strokeWeight(floor(noise * this.scale/20));
    point(px, py);
  }
}

class VectorField extends Field<PVector>
{
  float force;
  
  VectorField(int resolution, float coherence, float speed, float flux, float force)
  {
    super(resolution, coherence, speed, flux);
    this.force = force;
  }
  
  protected PVector createElement(float value)
  {
    PVector v = PVector.fromAngle(value);
    v.setMag(v.mag() * this.force);
    return v;
  }
 
  protected void drawElement(int x, int y) 
  {
    int px = floor(x*this.scale + this.scale/2);
    int py = floor(y*this.scale + this.scale/2);
    
    PVector vec = this.get(x, y).copy();
    float arrowScale = this.scale / 10;
    vec.setMag(vec.mag() * arrowScale);
        
    push();
    stroke(0);
    strokeWeight(1);
    fill(0);
    translate(px, py);
    line(-vec.x/2, -vec.y/2, vec.x/2, vec.y/2);
    rotate(vec.heading());
    translate(vec.mag()/2 - arrowScale, 0);
    triangle(0, arrowScale / 2, 0, -arrowScale / 2, arrowScale, 0);
    pop();
  }
}
