import java.util.*;

public class TrackCircle {
  private AudioContext ac;
  private float x, y;
  private float r;
  private float rate;
  private Panner p;
  private Gain g;
  private Glide freqSetter;
  private final int n_points = 2048;
  private float rMin = 20, rMax = 2000;
  private int delay = 10;
  private UGen out;
  
  TrackCircle(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.ac = new AudioContext(2048);
    rate = 0.1;
    freqSetter = new Glide(ac, map(rate, 0, 1, rMin, rMax));
    WavePlayer wp = new WavePlayer(ac, freqSetter, Buffer.SINE);
    p = new Panner(ac);
    p.setPos(map(this.x, 0, width, -1, 1));
    p.addInput(wp);
    this.out = p;
    g = new Gain(ac, 2, 0.2);
    g.addInput(p);
    ac.out.addInput(g);
  }
  
  TrackCircle(float x, float y, float r, AudioContext ac, UGen in) {
    // Caution: This constructor won't set frequence modifier.
    this.x = x;
    this.y = y;
    this.r = r;
    this.ac = ac;
    freqSetter = new Glide(ac, map(rate, 0, 1, rMin, rMax));
    p = new Panner(ac);
    p.setPos(map(this.x, 0, width, -1, 1));
    p.addInput(in);
    this.out = p;
    g = new Gain(ac, 2, 0.2);
    g.addInput(p);
    ac.out.addInput(g);
  }
  
  public void move(float x, float y) {
    this.x = x;
    this.y = y;
    p.setPos(map(this.x, 0, width, -1, 1));
  }
  
  public void setR(float r) { this.r = r; }
  
  public void setRate(float r) {
    // in case rate running out of the range of (0, 1)
    r = min(1, max(0, r));
    this.rate = r;
    this.freqSetter.setValue(map(rate, 0, 1, rMin, rMax));
  }
  
  public void setDelay(int delay) {
    this.delay = delay;
  }
  public void setRateRange(float min, float max) {
    this.rMin = min;
    this.rMax = max;
  }
  
  public void setFreqModifier(Glide _) {
    this.freqSetter = _;
  }
  
  public float getRate() { return this.rate; }
  
  public float getR() { return r; }
  
  AudioContext getAC() { return this.ac; }
  
  Gain getGain() { return this.g; }
  
  Glide getFreqModifier() { return this.freqSetter; }
  
  UGen getOutput() { return this.out; }
  
  public boolean isInside(float x, float y) {
    float dist = sqrt((this.x - x) * (this.x - x) + (this.y - y) * (this.y - y));
    return dist < r;
  }
  
  public void draw() {
    pushMatrix();
    beginShape();
    translate(x, y);
    float vOffset = 0.;
    for(int i = 0; i < n_points; i++) {
      //for each point work out where in the current audio buffer we are
      int buffIndex = i * ac.getBufferSize() / n_points;
      vOffset = ((0.7 + ac.out.getValue(0, buffIndex)) * r);
      vOffset = min(vOffset, r);
      stroke(fore);
      noFill();
      vertex(vOffset * cos(2 * PI * i / n_points), vOffset * sin(2 * PI * i / n_points));
    }
    endShape(CLOSE);
    popMatrix();
  }
  
  public UGen merge(TrackCircle tc) {
    Gain mod_g = new Gain(ac, 2, tc.getOutput());
    mod_g.addInput(this.out);
    Gain g = new Gain(ac, 2, 2);
    g.addInput(mod_g);
    return g;
  }
}
