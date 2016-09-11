// TODO:
//* [x] Split grid into rectangles
//* [x] calculate occurances of colors
//* [x] select two colors
//* [ ] consider quantizing colors
//* [x] draw elipses
//* [ ] get directions
//* [ ] rotate ellipses based on direction
//* [x] webcam feed
//* [ ] background subtraction
//* [x] pyramids
//* [x] eyes
//* [x] edges

import java.util.Map;
import gab.opencv.*;

PImage img;
PImage canny;
OpenCV opencv;
int canvas_width = 825;
int canvas_height = 825;
int block_size = 12;

void setup() {  
  size(825, 825);
  img = loadImage("val.jpg");
  
  opencv = new OpenCV(this, img);
  opencv.findCannyEdges(20,75);
  canny = opencv.getSnapshot();
  
  canny.filter(BLUR, 0.7);
  noLoop();
}

void draw() {
  for(int y = 0; y < img.height; y += block_size) {
    for(int x = 0; x < img.width; x += block_size) {
      pushMatrix();
      translate(x, y);
      
      IntDict hist = countColors(img.get(x, y, block_size, block_size));
      
      String[] colors = hist.keyArray();
      color c1 = unhex(colors[0]);
      color c2 = unhex(colors[colors.length/2]);
      color c3 = unhex(colors[3*colors.length/4]);
      
      noStroke();
      
      fill(red(c1), green(c1), blue(c1));
      rect(0, 0, block_size, block_size);
      
      PImage edgeImg = createImage(block_size, block_size, RGB);
      edgeImg.loadPixels();
      for(int i = 0; i < edgeImg.pixels.length; i++) {
        edgeImg.pixels[i] = c2;
      }
      edgeImg.updatePixels();
      edgeImg.mask(canny.get(x, y, block_size, block_size));
      
      image(edgeImg, 0, 0);

      popMatrix();
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