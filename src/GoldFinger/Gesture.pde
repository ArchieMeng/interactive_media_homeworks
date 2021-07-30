// Referrence: Golan Levin. (2004). Golan Levin and collaborators. Flong - Interactive Art by Golan Levin and Collaborators. https://www.flong.com/projects/yellowtail/
// source code: https://github.com/processing/processing-docs/blob/master/exhibition/works/yellowtail/yellowtail.pde
import beads.*;

class Gesture {
  public ArrayList<Point> points = new ArrayList<Point>(); // record of user input codes
  private boolean activated = false;
  private float wConst = 32;
  private final String SOUND_FILE_PATH = "234269__moddingtr__snake-hss-effect.wav"; // sound from https://freesound.org/people/ModdingTR/sounds/234269/
  private AudioContext ac;
  private Panner panner;
  private Gain g;
  private Glide freqSetter;
  
  public Gesture() {
    ac = new AudioContext(2048);
    SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(SOUND_FILE_PATH));
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    freqSetter = new Glide(ac, 1);
    player.setRate(freqSetter);
    panner = new Panner(ac);
    panner.setPos(0);
    panner.addInput(player);
    g = new Gain(ac, 2, 0.3);
    g.addInput(panner);
    ac.out.addInput(g);
  }
  
  public void addPoint(float x, float y) {
    float presure;
    if (this.points.size() > 0) {
      Point last_p = this.points.get(this.points.size() - 1);
      presure = wConst / last_p.distance(x, y);
    } else {
      presure = 1;
    }
    points.add(new Point(x, y, presure));
  }
  
  public void activate() {
    this.activated = true;
    this.ac.start();
  }
  
  public void update() {
    if (this.activated) {
      float vx = this.points.get(1).x - this.points.get(0).x;
      float vy = this.points.get(1).y - this.points.get(0).y;
      
      
      for (int i = 0; i < this.points.size() - 1; i++) {
        this.points.get(i).x = this.points.get(i + 1).x;
        this.points.get(i).y = this.points.get(i + 1).y;
      }
      Point p = this.points.get(this.points.size() - 1);
      float d1 = constrain(this.points.get(this.points.size() - 2).distance(p), 1, 3);
      Point pre_p = p.copy();
      
      p.x += vx;
      p.y += vy;
      
      float d2 = constrain(p.distance(pre_p), 1, 3); 
      this.freqSetter.setValue((d2 / d1) / 3);
      p = p.mirrorToScreen();
      this.panner.setPos(map(p.x, 0, width, -1, 1));
    }
  }
  
  public void draw() {
    Point last_p = this.points.get(0).mirrorToScreen();
    float w = last_p.p;
    int cnt = 0;
    for (int i = 1; i < this.points.size(); i++) {
      Point p = this.points.get(i).mirrorToScreen();
      if(p != this.points.get(i)) {
        cnt++;
      }
      w = constrain((p.p + last_p.p) / 2, w - 1, w + 1);
      stroke(lerpColor(color(0, 128, 255), color(255, 128, 0), w / wConst));
      strokeWeight(w / 2);
      
      line(last_p.x, last_p.y, p.x, p.y);
      last_p = p;
    }
    
    // if all the points are out of boundary, move them back to screen (within 2 times screen range so that mirror function works).
    if (cnt == this.points.size() - 2) {
      for (int i = 0; i < this.points.size(); i++) {
        this.points.set(i, this.points.get(i).mirrorToScreen());
      }
    }
  }
}
