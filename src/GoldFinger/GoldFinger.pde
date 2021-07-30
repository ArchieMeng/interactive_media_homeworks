ArrayList<Gesture> gestureList = new ArrayList<Gesture>();
int currentGestureID = 0;
boolean mouseDown = false;

void setup() {
  size(852, 480);
  System.out.println("running dir: " + System.getProperty("user.dir"));
}
// Todo:
// add sound
// add doppler effects to both color and sound.
// add HRTF to simulate sound from above and under head

void draw() {
  background(0,0,0);
  for (int i = 0; i < gestureList.size(); i++) {
    gestureList.get(i).update();
    gestureList.get(i).draw();
  }
}

void mousePressed()
{
  mouseDown = true;
  Gesture g = new Gesture();
  gestureList.add(g);
  g.addPoint(mouseX, mouseY);
}

void mouseDragged(){
  mouseDown = true;
  Gesture g = gestureList.get(currentGestureID);
  g.addPoint(mouseX, mouseY);
}

void mouseMoved (Event evt, int x, int y){
  mouseDown = false;
}

void mouseReleased(){
  mouseDown = false;
  Gesture g = gestureList.get(currentGestureID);
  if(g.points.size() > 1) {
    g.activate();
    currentGestureID++;
  } else {
    gestureList.remove(currentGestureID);
  }
}
