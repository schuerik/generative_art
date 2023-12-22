

int fieldSize = 50;
int particleCount = 10000; 
VectorField field;
Particle[] particles;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new VectorField(fieldSize, 0.04, 0.01, 3, 4);
  field.update();
  
  particles = new Particle[particleCount];
  resetParticles();
}

void draw()
{
  //background(255);
  field.update();
  
  for (int i=0; i < particleCount; i++)
  {
    particles[i].update();
  }
}

void resetParticles()
{
  for (int i=0; i < particleCount; i++)
  {
    ParticleOptions opt = new ParticleOptions();
    opt.sat = i % 2 == 0 ? 0 : 255;
    FieldParticle p = new FieldParticle(opt);
    p.setField(field);
    particles[i] = p;
  }
}
