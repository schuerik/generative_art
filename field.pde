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
    
  PVector getCoord(int x, int y)
  {
    int px = floor(x*this.scale + this.scale/2f);
    int py = floor(y*this.scale + this.scale/2f);
    
    return new PVector(px, py);
  }
  
  T get(int x, int y)
  {
    return (T) this.field[x][y];
  }
  
  T getByCoord(PVector coord)
  {
    return this.getByCoord(floor(coord.x), floor(coord.y));
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
  int lvl;
  float std = 0;
  float mean = 0;
  
  SoundField(PApplet app, int resolution, int level)
  {
    super(resolution);
    
    this.lvl = level;
    
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
    this.mean = 0.0;
    for (int i = 0; i < this.spectrum.length; i++) 
    {
      this.mean += this.spectrum[i];
    }
    this.mean /= this.bands;
    
    // The variance
    float variance = 0;
    for (int i = 0; i < this.spectrum.length; i++) 
    {
      variance += pow(this.spectrum[i] - this.mean, 2);
    }
    variance /= this.bands;
    
    // Standard Deviation
    this.std = sqrt(variance);
    super.update();
  }
  
  protected Float createElement(int x, int y)
  {
    return this.spectrum[x*y];
  }
  
  protected void drawElement(int x, int y) 
  {   
    float value = this.get(x, y);
    float dev = pow(value - this.mean, 2);
    dev = floor(dev * 1000000000);
    int val = floor(value * this.scale * 100 * this.lvl);
    
    if (val < 1)
      return;
        
    float rectSize = this.scale/sqrt(2);
    PVector coords = this.getCoord(x, y);
    
    pushMatrix();
    strokeWeight(val);
    translate(coords.x-25, coords.y-25);
    rectMode(CENTER);

    // inner rectangle
    pushMatrix();
    push();
    colorMode(HSB);
    fill(floor(this.std*500000), 255, 255, dev);
    rotate(((frameCount%500)+1) / 500.f * TWO_PI);
    rect(0, 0, rectSize/sqrt(2), rectSize/sqrt(2));
    pop();
    popMatrix();
            
    // outer rectangle
    pushMatrix();
    stroke(0);
    fill(0, 0, 0, 0);
    rotate(((frameCount%500)+1) / 500.f * -TWO_PI);
    rect(0, 0, rectSize, rectSize);
    popMatrix();
    popMatrix();    
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
    PVector coords = this.getCoord(x, y);  
    float noise = this.get(x, y);
        
    stroke(0);
    strokeWeight(floor(noise * this.scale/20));
    point(coords.x, coords.y);
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
    PVector coords = this.getCoord(x, y); 
    
    PVector vec = this.get(x, y).copy();
    float arrowScale = this.scale / 10;
    vec.setMag(vec.mag() * arrowScale);
        
    push();
    stroke(0);
    strokeWeight(1);
    fill(0);
    translate(coords.x, coords.y);
    line(-vec.x/2, -vec.y/2, vec.x/2, vec.y/2);
    rotate(vec.heading());
    translate(vec.mag()/2 - arrowScale, 0);
    triangle(0, arrowScale / 2, 0, -arrowScale / 2, arrowScale, 0);
    pop();
  }
}
