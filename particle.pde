class ParticleOptions
{
  float cap = 5;    // -1 is no cap
  int wrap = 1;     // 0 is mirror; 1 is wrap around
  int sat = 0;      // saturation 0 to 255
}

class Particle
{
  PVector pos;
  PVector vel;
  PVector acc;
  
  ParticleOptions opt;
  
  Particle()
  {
    pos = new PVector(random(width), random(height));
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    
    opt = new ParticleOptions();
  }
  
  Particle(ParticleOptions options)
  {
    pos = new PVector(random(width), random(height));
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    
    opt = options;
  }
  
  
  Particle(PVector position)
  {
    pos = position;
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    
    opt = new ParticleOptions();
  }
  
  Particle(PVector position, ParticleOptions options)
  {
    pos = position;
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    
    opt = options;
  }
  
  Particle(PVector position, PVector velocity, PVector acceleration)
  {
    pos = position;
    vel = velocity;
    acc = acceleration;
    
    opt = new ParticleOptions();
  }
  
  Particle(PVector position, PVector velocity, PVector acceleration, ParticleOptions options)
  {
    pos = position;
    vel = velocity;
    acc = acceleration;
    
    opt = options;
  }
  
  void addForce(PVector acceleration)
  {
    this.acc.add(acceleration);
  }
  
  void applyForce()
  {
    // apply accelaration
    this.vel.add(this.acc);
    if (this.opt.cap > 0)
    {
      this.vel.limit(this.opt.cap);
    }
    this.acc.mult(0);
    
    // apply velocity
    this.pos.add(this.vel);
    if (this.opt.wrap == 0)
    {
      if (this.pos.x > width)
      {
        this.pos.x = width - (this.pos.x - width);
      }
      if (this.pos.x < 0)
      {
        this.pos.x = -1 * this.pos.x;
      } 
      if (this.pos.y > height)
      {
        this.pos.y = height - (this.pos.y - height);
      }
      if (this.pos.y < 0)
      {
        this.pos.y = -1 * this.pos.y;
      } 
    }
    else if (this.opt.wrap == 1)
    {
      if (this.pos.x > width)
      {
        this.pos.x = this.pos.x - width;
      }
      if (this.pos.x < 0)
      {
        this.pos.x = width - this.pos.x;
      } 
      if (this.pos.y > height)
      {
        this.pos.y = this.pos.y - height;
      }
      if (this.pos.y < 0)
      {
        this.pos.y = height - this.pos.y;
      }
    }
  }
  
  void redraw()
  {
    strokeWeight(2);
    stroke(this.opt.sat);
    point(this.pos.x, this.pos.y);
  }
  
  void update()
  {
    this.applyForce();
    this.redraw();
  }
}

class FieldParticle extends Particle
{
  VectorField field;
  
  FieldParticle(ParticleOptions options)
  {
    super(options);
  }
  
  void setField(VectorField field)
  {
    this.field = field;
  }
  
  void update()
  {
    this.addForce(this.field.getByCoord(floor(this.pos.x), floor(this.pos.y)));
    super.update();
  }
}
