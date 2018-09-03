import processing.video.*;

final int CANVAS_WIDTH = 1280;
final int CANVAS_HEIGHT = 720;
final int CAM_WIDTH = 320;
final int CAM_HEIGHT = 180;
final int BLOCK_SIZE = 6;
final boolean RENDER_FULL_SCREEN = true;
final boolean SHOW_FPS = true;

Capture cam;
PGraphics pg;

void settings() {
  if(RENDER_FULL_SCREEN) {
    fullScreen();
  } else {
    size(CANVAS_WIDTH, CANVAS_HEIGHT);
  }

  // we render to a smaller graphics buffer and upscale it to fit the canvas
  // size. Turn off smoothing so nearest-neighbours interpolation is used
  // instead of whatever processing uses (maybe bilinear/bicubic).
  noSmooth();
}

void setup() {  
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
    cam = new Capture(this, CAM_WIDTH, CAM_HEIGHT, cameras[0]);
    cam.start();
  }

  // setup text
  textAlign(LEFT);
  textSize(32);

  pg = createGraphics(CAM_WIDTH, CAM_HEIGHT);
}

void draw() {
  if (cam.available()) { 
    // Reads the new frame
    cam.read(); 
  } 

  pg.beginDraw();
  
  for(int y = 0; y < cam.height; y += BLOCK_SIZE) {
    for(int x = 0; x < cam.width; x += BLOCK_SIZE) {
      pg.pushMatrix();
      pg.translate(x, y);

      // drawSmiles(pg, cam, x, y);
      // drawMaxFreqPixelate(pg, cam, x, y);
      drawPixelateWithCornerDot(pg, cam, x, y);
      // drawEyeBalls(pg, cam, x, y);
      
      pg.popMatrix();
    } 
  }

  if(SHOW_FPS) {
    pg.fill(255);
    pg.text(str(frameRate), 0, 32);
  }

  pg.endDraw();

  image(pg, 0, 0, width, height);
}

void drawSmiles(PGraphics pg, Capture cam, int x, int y) {
  IntDict hist = countColors(cam.get(x, y, BLOCK_SIZE, BLOCK_SIZE));
  
  String[] colors = hist.keyArray();
  color c1 = unhex(colors[0]);
  color c2 = unhex(colors[colors.length/2]);
  color c3 = unhex(colors[3*colors.length/4]);
  
  pg.noStroke();
  
  pg.fill(red(c2), green(c2), blue(c2));
  pg.rect(0, 0, BLOCK_SIZE, BLOCK_SIZE);
  
  pg.fill(red(c1), green(c1), blue(c1));
  pg.rect(2, 2, 3, 3);
  
  pg.fill(red(c1), green(c1), blue(c1));
  pg.rect(6, 2, 3, 3);
  
  pg.noFill();
  pg.stroke(red(c1), green(c1), blue(c1));
  pg.arc(6, 8, 7, 3, 0, PI);
}

void drawMaxFreqPixelate(PGraphics pg, Capture cam, int x, int y) {
  IntDict hist = countColors(cam.get(x, y, BLOCK_SIZE, BLOCK_SIZE));
  
  String[] colors = hist.keyArray();
  color c1 = unhex(colors[0]);

  pg.noStroke();

  pg.fill(red(c1), green(c1), blue(c1));
  
  pg.rect(0, 0, BLOCK_SIZE, BLOCK_SIZE);
}

void drawPixelateWithCornerDot(PGraphics pg, Capture cam, int x, int y) {
  IntDict hist = countColors(cam.get(x, y, BLOCK_SIZE, BLOCK_SIZE));
  
  String[] colors = hist.keyArray();
  color c1 = unhex(colors[0]);
  color c2 = unhex(colors[colors.length/2]);

  pg.noStroke();
  
  pg.fill(c2);
  pg.rect(0, 0, BLOCK_SIZE, BLOCK_SIZE);
  
  pg.fill(c1);
  pg.rect(BLOCK_SIZE/2, BLOCK_SIZE/2, BLOCK_SIZE/2, BLOCK_SIZE/2);
}

void drawEyeBalls(PGraphics pg, Capture cam, int x, int y) {
  IntDict hist = countColors(cam.get(x, y, BLOCK_SIZE, BLOCK_SIZE));
  
  String[] colors = hist.keyArray();
  color c1 = unhex(colors[0]);
  color c2 = unhex(colors[colors.length/2]);
  color c3 = unhex(colors[colors.length/2 + colors.length/4]);
  
  pg.noStroke();
  
  pg.fill(red(c2), green(c2), blue(c2));
  pg.rect(0, 0, BLOCK_SIZE, BLOCK_SIZE);
  
  color white = lerpColor(c1, #FFFFFF, 0.5);
  pg.fill(red(white), green(white), blue(white));
  pg.translate(BLOCK_SIZE/2, BLOCK_SIZE/2);
  pg.ellipse(0, 0, BLOCK_SIZE/2+1, BLOCK_SIZE/3+1);
  
  pg.fill(red(c3), green(c3), blue(c3));
  pg.ellipse(0, 0, (BLOCK_SIZE/2+1)/2, (BLOCK_SIZE/3+1)/2);
  
  pg.fill(red(c1), green(c1), blue(c1));
  pg.ellipse(0, 0, (BLOCK_SIZE/2+1)/4, (BLOCK_SIZE/3+1)/4);
}

/**
 * Returns an IntDict with keys mapping to colours with value set to
 * frequency of a colour's occurrence. Keys are sorted by values,
 * with highest frequency colours at the start.
 */
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