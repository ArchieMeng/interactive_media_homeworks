class Point {
  public float x, y, p; // x-pos, y-pos, presure
  
  Point(float x, float y, float p) {
    this.x = x;
    this.y = y;
    this.p = p;
  }
  
  public float distance(Point p) {
    return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2));
  }
  
  public float distance(float x, float y) {
    return sqrt(pow(x - this.x, 2) + pow(y - this.y, 2));
  }
  
  public boolean equals(Point p) {
    return p.x == x && p.y == y && p.p == this.p;
  }
  
  public Point copy() {
    return new Point(x, y, p);
  }
  
  public Point mirrorToScreen() {
    float newX = x % (2 * width);
    float newY = y % (2 * height);
    newX = newX > 0 ? newX: -newX;
    newX = newX > width ? 2 * width - newX: newX;
    newY = newY > 0 ? newY: -newY;
    newY = newY > height ? 2 * height - newY: newY;
    return new Point(newX, newY, p);
  }
}
