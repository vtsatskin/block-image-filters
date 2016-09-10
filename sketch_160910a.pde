import processing.video.*;

Capture cam;
int canvas_width = 640;
int canvas_height = 480;
int block_size = 12;

void setup() {  
  size(640, 480);
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, canvas_width, canvas_height, cameras[0]);
    cam.start();
  }
}

void draw() {
  if (cam.available()) { 
    // Reads the new frame
    cam.read(); 
  } 
  image(cam, 0, 0);
  
  for(int y = 0; y < cam.height; y += block_size) {
    for(int x = 0; x < cam.width; x += block_size) {
      pushMatrix();
      translate(x, y);

      IntDict hist = countColors(cam.get(x, y, block_size, block_size));
      
      String[] colors = hist.keyArray();
      color c1 = unhex(colors[0]);
      color c2 = unhex(colors[colors.length/2]);
      color c3 = unhex(colors[3*colors.length/4]);
      
      noStroke();
      
      fill(red(c2), green(c2), blue(c2));
      rect(0, 0, block_size, block_size);

      fill(red(c1), green(c1), blue(c1));
      rect(2, 2, 3, 3);
      
      fill(red(c1), green(c1), blue(c1));
      rect(6, 2, 3, 3);
      
      noFill();
      stroke(red(c1), green(c1), blue(c1));
      arc(6, 8, 7, 3, 0, PI);
      
      popMatrix();
    } 
  }
}

IntDict countColors(PImage cam) {
  IntDict a = new IntDict();
  color[] pixels = cam.pixels;
  
  for(int i = 0; i < cam.height * cam.width; i += 1) {
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