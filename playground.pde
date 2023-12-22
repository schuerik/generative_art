

int fieldSize = 50;
int particleCount = 10000; 
VectorField field;
Particle[] particles;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new VectorField(fieldSize, 0.05, 0.01, 3, 5);
  field.update();
  
  particles = new Particle[particleCount];
  for (int i=0; i < particleCount; i++)
  {
    FieldParticle p = new FieldParticle();
    p.setField(field);
    particles[i] = p;
  }
}

void draw()
{
  if (frameCount % 500 == 0)
  {
    resetImage();  
  }
  
  for (int i=0; i < particleCount; i++)
  {
    particles[i].update();
  }
}

void resetImage()
{
  background(255);
  field.update();
  for (int i=0; i < particleCount; i++)
  {
    FieldParticle p = new FieldParticle();
    p.setField(field);
    particles[i] = p;
  }
}
