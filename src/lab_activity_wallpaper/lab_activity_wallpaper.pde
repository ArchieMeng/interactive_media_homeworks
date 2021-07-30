DataGenerator dataGen;
float min, max;
float v, oldV;
int index = 0;

// change this URL to whatever you like from EIF
// String csvURL = "http://eif-research.feit.uts.edu.au/api/dl/?rFromDate=2020-08-19T21%3A18%3A54&rToDate=2020-08-21T21%3A18%3A54&rFamily=weather&rSensor=AT";
String csvURL = "Air.csv";

float graphRatio = 0.2;
int interNum = 1;
SliderBar interNumBar, alphaBar;
float sliderX, sliderY;
float sliderHandleW = 12, sliderBarW;
float alpha = 30;

void setup() {
  size(640, 360);
  frameRate(30);
  
  // load the data for a humidity censor in csv format.
  dataGen = new DataGenerator(csvURL, interNum);
  dataGen.loadData();
  max = dataGen.get(0);
  min = dataGen.get(0);
  while (index < dataGen.len()) {
    float cur = dataGen.get(index);
    max = max > cur ? max : cur;
    min = min < cur ? min : cur;
    index++;
  }
  sliderX = width / 8;
  sliderY = height / 12;
  sliderBarW = width / 3;
  interNumBar = new SliderBar(sliderX, sliderY, sliderBarW, sliderHandleW, 0, 20);
  alphaBar = new SliderBar(sliderX + sliderBarW + 40, sliderY, sliderBarW, sliderHandleW, 10, 90);
}

void draw() {
  index = index < dataGen.len() ? index : 0;
  v = dataGen.get(index); // index is the row, 1 is the column with the data.
  v = normalize(v, min, max);
  
  // set background color
  background(lerpColor(color(255, 255, 255), color(255, 166, 143), v));
  // draw wave based on tempature
  drawWave(lerpColor(color(0, 127, 255, alpha), color(255, 0, 0, alpha), v), color(0, 200, 255, alpha), 20);
  
  
  // set and draw interNum with sliderbar
  textSize(18);
  fill(0);
  text("slow down speed", sliderX - width / 8, sliderY + sliderHandleW / 2);
  interNumBar.setBarControlGUI();
  interNum = int(interNumBar.getVal());
  dataGen.setInterNum(interNum);
  
  // set and draw interNum with sliderbar
  textSize(18);
  fill(0);
  text("alpha", sliderX + 2 * sliderBarW + width / 16, sliderY + sliderHandleW / 2);
  alphaBar.setBarControlGUI();
  alpha = alphaBar.getVal();
  index++;
  
  // drawSensorGraph();
}


void drawSensorGraph() {
  // for debug usages
  float y = 0;
  index = index < dataGen.len() ? index : 0;
    
  // read the 2nd column (the 1), and read the row based on index which increments each draw()
  y = dataGen.get(index); // index is the row, 1 is the column with the data.
  y = normalize(y, min, max);
  
  for (int i = 1; i < index; i++) {
    pushMatrix();
    stroke(0);
    strokeWeight(3);
    line(width * (i - 1) / dataGen.len(), height - normalize(dataGen.get(i - 1), min, max) * graphRatio * height, width * i / dataGen.len(), height - normalize(dataGen.get(i), min, max) * graphRatio * height);
    strokeWeight(1);
    popMatrix();
  }
  for (int i = 0; i < index; i++) {
    pushMatrix();
    fill(0);
    ellipse(width * i / dataGen.len(), height - normalize(dataGen.get(i), min, max) * graphRatio * height, 3, 3);
    popMatrix();
  } //<>//
}

void drawWave(color ca, color cb, int n) {
  float spd = map(interNum, 0, 20, 0.04, 0.005);
  float offset = map(frameCount % (map(interNum, 0, 20, 1, 10) * frameRate), 0, (map(interNum, 0, 20, 1, 10) * frameRate), 0, 2 *PI);

  noFill();

  for (int i = 0; i < n; i++) {
    color c = lerpColor(ca, cb, i / (n - 1.));

    stroke(c);
    strokeWeight(1);

    beginShape();
    fill(c);
    for (float x = -5; x <= width + 5; x++) {
      float y = map(noise(x * 0.00125, i * 0.015, frameCount * spd), 0, 1, 0, height);
      y *= 0.3 * (sin(map(x, -5, width + 5, 0, .75 * PI) + offset) + 1) + 0.6;
      vertex(x, y);
    }
    for (float x = width + 5; x >= -5; x--) {
      float y = map(noise(x * 0.0025, i * 0.1, frameCount * (spd + 0.01)), 0, 1, 0, height);
      y *= 0.3 * (sin(map(x, -5, width + 5, 0, .75 * PI) + offset) + 1) + 0.6;
      vertex(x, y - height / 10);
    }
    endShape();
  }
}

float normalize(float val, float min, float max) {
  return (val - min) / (max - min);
}

void setBackgroundColor(float v) {
  //if (v > 2 / 3.) {
  //  background(255, 255 * (1 - v) * 3, 0);
  //} else if (v < 2 / 3. && v > 1/ 3.) {
  //  background(255 * (v - 1 / 3.) * 3, 255, 0);
  //} else {
  //  background(0, 255, 255 * (1 / 3. - v) * 3);
  //}
  background(lerpColor(color(0, 255, 255), color(255, 0, 0), v));
}

float linearInterpolation(float x, float x0, float y0, float x1, float y1) {
  if (x1 == x0 || y1 == y0)
    return y0;
  return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
}

class SliderBar {
  private float sliderBarX, sliderBarY, sliderBarW, sliderHandleX, sliderHandleY, sliderHandleW, val, sliderMin, sliderMax;
  private boolean isOnSliderHandle = false;
  
  SliderBar(float sliderBarX, float sliderBarY, 
            float sliderBarW, float sliderHandleW,
            float sliderMin, float sliderMax) {
            this.sliderBarX = sliderBarX;
            this.sliderBarY = sliderBarY;
            this.sliderBarW = sliderBarW;
            this.sliderHandleW = sliderHandleW;
            this.sliderHandleX = sliderBarX + sliderBarW / 3;
            this.sliderHandleY = sliderBarY;
            this.sliderMin = sliderMin;
            this.sliderMax = sliderMax;
    
  }
  
  void setBarControlGUI() {
    
    stroke(0);
    line(sliderBarX, sliderBarY, sliderBarX+sliderBarW, sliderBarY);
    fill(0, 0, 255);
    rect(sliderHandleX-sliderHandleW/2, sliderHandleY-sliderHandleW/2, sliderHandleW, sliderHandleW);
  
    if (isOnSliderHandle &&  mouseX>sliderBarX && mouseX < sliderBarX + sliderBarW) {
      sliderHandleX = mouseX;
    }
    // detect if mouse is on control/anchor point
    if (mousePressed && dist(mouseX, mouseY, sliderHandleX, sliderHandleY) < sliderHandleW/2) {
      isOnSliderHandle = true;
    } else if (!mousePressed){
      isOnSliderHandle = false;
    }
  
    // ensures slider handle values between to sliderMin to sliderMax
    this.val = map(sliderHandleX, sliderBarX, sliderBarX+sliderBarW, sliderMin, sliderMax);
  } // END setCurvature()
  
  float getVal() {
    return this.val;
  }
}

class DataGenerator {
  private String csvURL;
  private Table data;
  private int interNum = 0;
 
  DataGenerator(String url, int interNum) {
    this.csvURL = url;
    this.interNum = interNum;
  }
  
  void setInterNum(int i) {
    this.interNum = i;
  }
  
  void loadData(){
    this.data = loadTable(this.csvURL, "csv");
  }
  
  int len() {
    int n = data.getRowCount();
    return n + (n - 1) * this.interNum;
  }
  
  float get(int i) {
    if (i >= this.len() - 1) {
      return this.data.getFloat(this.data.getRowCount() - 1, 1);
    }
    return linearInterpolation(i / (this.interNum + 1.), i / (this.interNum + 1), this.data.getFloat(i / (this.interNum + 1), 1), i / (this.interNum + 1.) + 1, this.data.getFloat(i / (this.interNum + 1) + 1, 1));
  }
}
