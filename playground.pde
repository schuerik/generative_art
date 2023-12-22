int fieldSize = 32;
int particleCount = 10000; 
SoundField field;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new SoundField(this, fieldSize, 2);
  field.update();
}

void rotateCanvas()
{
  translate(width/2, height/2);
  rotate(((frameCount%1000)+1) / 1000.f * TWO_PI);
}

void draw()
{ 
  background(255);
  rotateCanvas();
  
  scale(0.75);
  field.update();
  
  
  pushMatrix();
  translate(-50, -50);
  field.redraw();
  popMatrix();
  
  rotate(PI/2);
  pushMatrix();
  translate(-50, 50);
  field.redraw();
  popMatrix();
  
  rotate(PI/2);
  pushMatrix();
  translate(50, 50);
  field.redraw();
  popMatrix();
  
  rotate(PI/2);  
  pushMatrix();
  translate(50, -50);
  field.redraw();
  popMatrix();
  
}
