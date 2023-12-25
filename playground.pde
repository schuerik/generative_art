import processing.sound.*;
Amplitude amp;
AudioIn in;

int fieldSize = 32;
ArrayList<Particle> particles = new ArrayList<Particle>();
SoundField field;
VectorField vField;
NoiseField nField;

int bg = 255;
float rt = 0;

float ns = 0;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new SoundField(this, fieldSize, 2);
  field.update();
  
  vField = new VectorField(fieldSize, 0.6, 0.01, 0.5, 1);
  vField.update();
  nField = new NoiseField(fieldSize, 0.02, 0.1, 4);
  nField.update();
  
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
}

void rotateCanvas()
{
  translate(width/2, height/2);
  rt += TWO_PI/1000;
  rotate(rt);
}

void scaleCanvas()
{
  scale(0.5 + (sin(frameCount/1000f)+1)/2);
}

void drawFrame()
{
  // Remove dead particles
  for (int i = particles.size() - 1; i >= 0; i--) 
  {
    Particle p = particles.get(i);
    if (!p.alive()) 
    {
      particles.remove(i);
    }
  }

  // Give birth to new particles
  if (frameCount % 10 == 0)
  {
    for (int x=0; x < fieldSize; x++)
    {
      for (int y=0; y < fieldSize; y++)
      {
        float val = min(1, field.get(x, y) * 250);
        int size = floor(val * 10);
        if (size < 10)
          continue;
        PVector pos = field.getCoord(x, y);
        ParticleOptions opt = new ParticleOptions();
        opt.ttl = floor(val * 200);
        opt.size = size; 
        opt.light = 255;
        opt.sat = 255;
        opt.hue = floor(nField.getByCoord(pos) * 16);
        FieldParticle p = new FieldParticle(pos, opt);
        particles.add(p);
        p.setField(vField);
      }
    }
  }
  
  // Update particle fields
  float val = max(1, amp.analyze() * (width/fieldSize) * 5);
  val = (4*ns + val)/5f;
  ns = val;
  vField.noiseScale = val;
  vField.update();
  nField.update();
  
  // Draw particles
  for (Particle p : particles) 
  {
    p.update();
  }
  
  field.draw();
}

void drawTiled()
{
  pushMatrix();
  translate(-50, -50);
  drawFrame();
  popMatrix();
  
  rotate(PI/2);
  pushMatrix();
  translate(-50, 50);
  drawFrame();
  popMatrix();
  
  rotate(PI/2);
  pushMatrix();
  translate(50, 50);
  drawFrame();
  popMatrix();
  
  rotate(PI/2);  
  pushMatrix();
  translate(50, -50);
  drawFrame();
  popMatrix();
}

void draw()
{ 
  float val = max(0, 255 - floor(amp.analyze() * (width/fieldSize) * 1600));
  val = ceil((5*bg + val)/6f);
  bg = (int) val;
  colorMode(HSB);
  //background((frameCount/10) % 255, max(0, min(255, floor(-0.015*pow(val-127, 2) + 260))), val);
  background(val);
  
  rotateCanvas();
  scaleCanvas();
 
  field.update();
 
  drawTiled();
}
