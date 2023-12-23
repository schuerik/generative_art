import processing.sound.*;
Amplitude amp;
AudioIn in;

int fieldSize = 32;
int particleCount = 10000; 
SoundField field;

int bg = 255;
float rt = 0;

void setup()
{
  size(1000, 1000);
  background(255);
  
  field = new SoundField(this, fieldSize, 2);
  field.update();
  
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

void draw()
{ 
  float val = max(0, 255 - floor(amp.analyze() * (width/fieldSize) * 1600));
  val = floor((4*bg + val)/5);
  bg = (int) val;
  
  background(val);
  rotateCanvas();
 
  scale(0.5 + (sin(frameCount/1000f)+1)/2);
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
