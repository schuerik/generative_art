import processing.sound.*;
Amplitude amp;
AudioIn in;

int fieldSize = 20;
int particleCount = 10000; 
VectorField field;
FieldParticle[] particles;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new VectorField(fieldSize, 0.8, 0.01, 4, 5);
  field.update();
  
  particles = new FieldParticle[particleCount];
  resetParticles();
  
  in = new AudioIn(this, 0);
  in.start();
  amp = new Amplitude(this);
  amp.input(in);
}

void draw()
{
  //background(255);
   
  
  field.noiseLevel = rnd(amp.analyze() * 400, 2);
  field.noiseScale = rnd(amp.analyze() * 20, 3);
  //println(field.noiseLevel, field.noiseScale);
  field.update();
  
  for (int n=0; n < 10; n++)
  {
    for (int i=0; i < particleCount; i++)
    {
      particles[i].progress();
    }
    //field.update();
  }
  
  for (int i=0; i < particleCount; i++)
  {
    int lvl = max(0, 255 - min(255, round(amp.analyze() * 28000)));
    int cur = particles[i].opt.light;
    int diff = cur - lvl;
    
    particles[i].opt.light -= floor(diff / 16);
    particles[i].update();
  }
}

void resetParticles()
{
  for (int i=0; i < particleCount; i++)
  {
    ParticleOptions opt = new ParticleOptions();
    opt.wrap = 1;
    //opt.light = i % 2 == 0 ? 0 : 255;  
    FieldParticle p = new FieldParticle(opt);
    p.setField(field);
    particles[i] = p;
  }
}
