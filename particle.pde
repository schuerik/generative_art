class ParticleOptions
{
  float cap = 5;    // -1 is no cap
  int wrap = 1;     // 0 is mirror; 1 is wrap around
  int hue = 0;      // hue 0 to 255
  int sat = 0;      // saturation 0 to 255
  int light = 0;    // lightness 0 to 255
  int size = 10;     // size on canvas
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
  }
  
  void redraw()
  {
    strokeWeight(this.opt.size);
    colorMode(HSB);
    stroke(this.opt.hue, this.opt.sat, this.opt.light);
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
  
  void progress()
  {
    //print(this.pos.x, this.pos.y, "\n");
    this.addForce(this.field.getByCoord(floor(this.pos.x), floor(this.pos.y)));
  }
  
  void update()
  {
    this.progress();   
    super.update();
  }
}

class FieldPathParticle extends FieldParticle
{
  PVector prevPos;
  
  FieldPathParticle(ParticleOptions options)
  {
    super(options);
  }
  
  void fixXNegativ()
  {
    super.fixXNegativ();
    if (this.opt.wrap == 1)
    {
      this.prevPos.x = width-1;
    }   
  }
  
  void fixYNegativ()
  {
    super.fixYNegativ();
    if (this.opt.wrap == 1)
    {
      this.prevPos.y = width-1;
    }   
  }
  
  void fixXTooBig()
  {
    super.fixXTooBig();
    if (this.opt.wrap == 1)
    {
      this.prevPos.x = 0;
    }   
  }
  
  void fixYTooBig()
  {
    super.fixYTooBig();
    if (this.opt.wrap == 1)
    {
      this.prevPos.y = 0;
    }
  }
  
  void update()
  {
    prevPos = this.pos.copy();
    super.update();
  }
  
  void redraw()
  {
    strokeWeight(this.opt.size);
    colorMode(HSB);
    stroke(this.opt.hue, this.opt.sat, this.opt.light);
    line(this.prevPos.x, this.prevPos.y, this.pos.x, this.pos.y);
  }
}
