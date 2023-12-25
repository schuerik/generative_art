class ParticleOptions
{
  float cap = 1;    // -1 is no cap
  int wrap = 1;     // 0 is mirror; 1 is wrap around
  int hue = 0;      // hue 0 to 255
  int sat = 0;      // saturation 0 to 255
  int light = 0;    // lightness 0 to 255
  int size = 2;     // size on canvas
  int ttl = 50;     // number of updates to survive; negative numbers == infinite
  int tail = 50;     // length of the particle tail
}

class Particle
{
  PVector pos;
  PVector vel;
  PVector acc;
  
  ParticleOptions opt;
  
  ArrayList<PVector> track = new ArrayList<PVector>();
  
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
  
  void fixEdges()
  {
    if (this.pos.x > width)
    {
      this.fixXTooBig();
    }
    if (this.pos.x < 0)
    {
      this.fixXNegativ();
    } 
    if (this.pos.y > height)
    {
      this.fixYTooBig();
    }
    if (this.pos.y < 0)
    {
      this.fixYNegativ();
    }
  }
  
  void fixXNegativ()
  {
    if (this.opt.wrap == 0)
    {
      this.pos.x = -1 * this.pos.x;
    }
    else if (this.opt.wrap == 1)
    {
      this.pos.x = width + this.pos.x;
      this.track.add(new PVector(0, this.pos.y));   
    }    
  }
  
  void fixYNegativ()
  {
    if (this.opt.wrap == 0)
    {
      this.pos.y = -1 * this.pos.y;
    }
    else if (this.opt.wrap == 1)
    {
      this.pos.y = height + this.pos.y;
      this.track.add(new PVector(this.pos.x, 0));     
    }    
  }
  
  void fixXTooBig()
  {
    if (this.opt.wrap == 0)
    {
      this.pos.x = width - (this.pos.x - width);
    }
    else if (this.opt.wrap == 1)
    {
      this.pos.x = this.pos.x - width;
      this.track.add(new PVector(width-1, this.pos.y));
    }    
  }
  
  void fixYTooBig()
  {
    if (this.opt.wrap == 0)
    {
      this.pos.y = height - (this.pos.y - height);
    }
    else if (this.opt.wrap == 1)
    {
      this.pos.y = this.pos.y - height;
      this.track.add(new PVector(this.pos.x, height-1));
    }
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
    this.fixEdges();
    
    // manage tail
    this.track.add(this.pos.copy());
    if (this.track.size() > this.opt.tail)
      this.track.remove(0);
  }
  
  boolean alive()
  {
    return this.opt.ttl != 0;
  }
  
  void redraw()
  {
    strokeWeight(this.opt.size);
    colorMode(HSB);
    stroke(this.opt.hue, this.opt.sat, this.opt.light);
    point(this.pos.x, this.pos.y);
    
    for(PVector coord : this.track)
    {
      point(coord.x, coord.y);
    }
  }
  
  void update()
  {
    if (!this.alive())
      return;
    this.applyForce();
    this.redraw();
    this.opt.ttl -= 1;
  }
}

class FieldParticle extends Particle
{
  VectorField field;
  
  FieldParticle(ParticleOptions options)
  {
    super(options);
  }
  
  FieldParticle(PVector position, ParticleOptions options)
  {
    super(position, options);
  }
  
  void setField(VectorField field)
  {
    this.field = field;
  }
  
  void progress()
  {
    this.addForce(this.field.getByCoord(floor(this.pos.x), floor(this.pos.y)));
  }
  
  void update()
  {
    if (!this.alive())
      return;
    this.progress();   
    super.update();
  }
}
