// TODO:
//* [x] Split grid into rectangles
//* [x] calculate occurances of colors
//* [x] select two colors
//* [ ] consider quantizing colors
//* [ ] draw elipses
//* [ ] get directions
//* [ ] rotate ellipses based on direction
//* [ ] webcam feed

import java.util.Map;

PImage img;
int canvas_width = 640;
int canvas_height = 480;
int block_size = 10;

void setup() {  
  size(640, 480);
  img = loadImage("val.jpg");
  
  noLoop();
}

void draw() {
  image(img, 0, 0);
  
  for(int y = 0; y < img.height; y += block_size) {
    for(int x = 0; x < img.width; x += block_size) {
      IntDict hist = countColors(img.get(x, y, block_size, block_size));
      println(hist);
      println(hist.keyArray()[0], ": ", str(hist.valueArray()[0]));
      
      String[] colors = hist.keyArray();
      color c1 = unhex(colors[0]);
      color c2 = unhex(colors[colors.length/2]);
      color c3 = unhex(colors[colors.length/2 + colors.length/4]);
      
      noStroke();
      
      fill(red(c2), green(c2), blue(c2));
      rect(x, y, block_size, block_size);
      
      fill(red(c1), green(c1), blue(c1));
      rect(x+block_size/4, y+block_size/4, block_size/2+1, block_size/2+1);
      
      fill(red(c3), green(c3), blue(c3));
      rect(x+block_size/2, y+block_size/2, block_size/4+1, block_size/4+1);
    } 
  }
}

IntDict countColors(PImage img) {
  IntDict a = new IntDict();
  color[] pixels = img.pixels;
  
  for(int i = 0; i < img.height * img.width; i += 1) {
    String colorStr = hex(pixels[i]);
    if(a.hasKey(colorStr)) {
      a.set(colorStr, a.get(colorStr) + 1);
    }
    else {
      a.set(colorStr, 1);
    }
  }
  a.sortValuesReverse();
  return a;
}