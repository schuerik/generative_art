String toHSL(int hue, int sat, int light)
{
  return "hsl(" + hue + ", " + sat + ", " + light + ")";  
}

float rnd(float num, int digits)
{
  float factor = pow(10, digits);
  return round(num * factor) / factor;
}
