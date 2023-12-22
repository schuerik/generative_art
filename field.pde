import processing.sound.*;

abstract class Field<T>
{
  int size;
  float scale; 
  
  protected Object[][] field;
  
  Field(int resolution)
  {
    this.size = resolution;
    this.scale = width / resolution;
    
    this.field = new Object[size][size];
  }
  
  protected abstract T createElement(int x, int y);
  
  protected abstract void drawElement(int x, int y); 
  
  void update()
  {
    for (int x=0; x < size; x++)
    {
      for (int y=0; y < size; y++)
      {
        this.field[x][y] = this.createElement(x, y);
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

abstract class BaseNoiseField<T> extends Field<T>
{  
  float noiseScale; 
  float noiseSpeed; 
  float noiseLevel;
  
  BaseNoiseField(int resolution, float coherence, float speed, float flux)
  {
    super(resolution);
    
    this.noiseScale = coherence;
    this.noiseSpeed = speed;
    this.noiseLevel = flux;
  }
  
  protected T createElement(int x, int y)
  {
    float nx = x * this.noiseScale;
    float ny = y * this.noiseScale;
    float ns = noise(nx, ny, frameCount * noiseSpeed) * noiseLevel * TWO_PI;
        
    return this.createElement(ns);
  }
  
  protected abstract T createElement(float value);
}

class SoundField extends Field<Float>
{
  FFT fft;
  AudioIn in;
  int bands;
  float[] spectrum;
  int amp;
  
  SoundField(PApplet app, int resolution, int amplitude)
  {
    super(resolution);
    
    this.amp = amplitude;
    
    bands = resolution*resolution;
    spectrum = new float[bands];
    this.fft = new FFT(app, bands);
    this.in = new AudioIn(app, 0);
    in.start();
    fft.input(in);
  }
  
  void update()
  {
    fft.analyze(spectrum);
    super.update();
  }
  
  protected Float createElement(int x, int y)
  {
    return this.spectrum[x*y];
  }
  
  protected void drawElement(int x, int y) 
  {
    int px = floor(x*this.scale + this.scale/2);
    int py = floor(y*this.scale + this.scale/2);
    
    float value = this.get(x, y);
    int val = floor(value * this.scale * 100 * this.amp);
    
    if (val == 0)
      return;
        
    stroke(0);
    strokeWeight(val);
    push();
    translate(px-25, py-25);
    rotate(((frameCount%500)+1) / 500.f * -TWO_PI);
    rect(0, 0, this.scale/sqrt(2), this.scale/sqrt(2));
    pop();
  }
}

class NoiseField extends BaseNoiseField<Float>
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

class VectorField extends BaseNoiseField<PVector>
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
