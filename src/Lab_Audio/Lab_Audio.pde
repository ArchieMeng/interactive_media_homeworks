import beads.*;
import java.util.ArrayList; 
 
AudioContext ac;
ArrayList<TrackCircle> tracks = new ArrayList<TrackCircle>();
boolean circling = false;

void setup() {
  size(800, 600);
}

color fore = color(255, 102, 204);
color back = color(0,0,0);

/*
 * Just do the work straight into Processing's draw() method.
 */
void draw() {
  //set the background
  background(back);
  
  //if (circling) {
  //  playCircling(0.05);
  //}
  
  for (int i = 0; i < tracks.size(); i++) {
    tracks.get(i).draw();
  }
  
  textSize(min(width, height) / 12);
  if (key != 0) {
    if (key != CODED) {
      text("" + key, 0, height - min(width, height) / 12);
    } else {
      if (keyCode == CONTROL)
        text("CONTROL", 0, height - min(width, height) / 12);
    }
  }
}

// create a new SIN wave track
TrackCircle createTrackCircle(float x, float y, float r) {
  TrackCircle tc = new TrackCircle(x, y, r);
  tracks.add(tc);
  tc.getAC().start();
  return tc;
}

void importTrack(File selection) {
  if (selection != null) {
    String filePath = selection.getAbsolutePath();
    AudioContext ac = new AudioContext(2048);
    SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(filePath));
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    TrackCircle tc = new TrackCircle(mouseX, mouseY, min(height, width) / 5, ac, player);
    tc.setRateRange(0, 10);
    player.setRate(tc.freqSetter);
    tc.setRate(0.1);
    tracks.add(tc);
    tc.getAC().start();
  }
}

void deleteTrackCircle(float x, float y) {
  for (int i = 0; i < tracks.size(); i++) {
    TrackCircle tc = tracks.get(i);
    if (tc.isInside(x, y)) {
      tc.getGain().setGain(0);
      tracks.remove(i);
      break;
    }
  }
}

void deleteAllTrackCircles(float x, float y) {
  ArrayList<TrackCircle> g_tracks = new ArrayList<TrackCircle>();
  for (int i = 0; i < tracks.size(); i++) {
    TrackCircle tc = tracks.get(i);
    if (tc.isInside(x, y)) {
      g_tracks.add(tc);
    }
  }
  for (int i = 0; i < g_tracks.size(); i++) {
    TrackCircle tc = g_tracks.get(i);
    tc.getGain().setGain(0);
    tracks.remove(tc);
  }
}

void splitTrackCircles(float x, float y) {
  ArrayList<TrackCircle> g_tracks = new ArrayList<TrackCircle>();
  for (int i = 0; i < tracks.size(); i++) {
    TrackCircle tc = tracks.get(i);
    if (tc.isInside(x, y)) {
      g_tracks.add(tc);
    }
  }
  
  if (g_tracks.size() > 1) {
    float theta = 2 * PI / g_tracks.size();
    if (g_tracks.size() == 2) {
      TrackCircle tc1 = g_tracks.get(0);
      TrackCircle tc2 = g_tracks.get(1);
      tc1.move(x, y - 0.5 * tc1.getR());
      tc2.move(x, y + 0.5 * tc2.getR());
    } else {
      TrackCircle tc1 = g_tracks.get(0);
      tc1.move(x + tc1.getR(), y);
      for (int i = 1; i < g_tracks.size(); i++) {
        TrackCircle tc2 = g_tracks.get(i);
        float r2 = tc2.getR();
        float d2 = r2;
        tc2.move(x + d2 * cos(i * theta), y + d2 * sin(i * theta));
        tc1 = tc2;
      }
    }
  }
}

// merge all the selected tracks insize pos(x, y), use the previous tracks as Gain modifiers for the last track
void mergeTrackCircles(float x, float y) {
  ArrayList<TrackCircle> g_tracks = new ArrayList<TrackCircle>(); //<>//
  for (int i = 0; i < tracks.size(); i++) {
    TrackCircle tc = tracks.get(i);
    if (tc.isInside(x, y)) {
      g_tracks.add(tc);
    }
  }
  
  if (g_tracks.size() > 1) {
    TrackCircle tc = g_tracks.get(0);
    UGen merged = tc.getOutput();
    for (int i = 1; i < g_tracks.size(); i++) {
      //Todo implement merge
      tc = g_tracks.get(i);
      merged = g_tracks.get(i).merge(tc);
    }
    Glide freqMod = tc.getFreqModifier();
    deleteAllTrackCircles(x, y);
    AudioContext new_ac = new AudioContext(2048);
    tc = new TrackCircle(mouseX, mouseY, min(height, width) / 5, new_ac, merged);
    tc.setRateRange(0, 5);
    tc.setRate(0.2);
    tc.setFreqModifier(freqMod);
    tracks.add(tc);
    tc.getAC().start();
  }
}

//void playCircling(float speed) {
//  for (int i = 0; i < tracks.size(); i++) {
//    TrackCircle tc = tracks.get(i);
//    float theta;
//    if (tc.x > width / 2) {
//      theta = PI + atan((tc.y - height / 2) / (tc.x - width / 2));
//    } else {
//      theta = atan((tc.y - height / 2) / (tc.x - width / 2));
//    }
//    float r = sqrt(pow(tc.x - width / 2, 2) + pow(tc.y - height / 2, 2));
//    tc.move(width / 2 + r * cos(theta + speed), height / 2 + r * sin(theta + speed));
//  }
//}

void mouseDragged() 
{
  for (int i = 0; i < tracks.size(); i++) {
    TrackCircle tc = tracks.get(i);
    if (tc.isInside(pmouseX, pmouseY)) {
      if (key == CODED) {
        if (keyCode == CONTROL) {
          Gain g = tc.getGain();
          
          // change sound volume
          g.setGain(map(map(g.getGain(), 0, 1, 0, height) + (pmouseY - mouseY), 0, height, 0, 1));
          
          // change frequency by setting playback rate
          tc.setRate(map(map(tc.getRate(), 0, 1, 0, tc.getR()) + (mouseX - pmouseX), 0, tc.getR(), 0, 1));
        }
      } else {
        tc.move(mouseX, mouseY);
      }
    }
  }
}

void keyReleased(){
  switch(key) {
    case 'c':
    case 'C':
      // press c to add a new track
      createTrackCircle(mouseX, mouseY, min(width, height) / 5);
      break;
    case 's':
    case 'S':
      // press s to split grouped tracks
      splitTrackCircles(mouseX, mouseY);
      break;
    case 'd':
    case 'D':
      // press d to delete track
      deleteTrackCircle(mouseX, mouseY);
    break;
    case 'i':
    case 'I':
      selectInput("Select the audio to import", "importTrack");
      break;
    case 'm':
    case 'M':
      mergeTrackCircles(mouseX, mouseY);
      break;
    //case 'r':
    //case 'R':
    //  circling = !circling;
    //  break;
  }
  
  key = 0;
  keyCode = 0;
}
