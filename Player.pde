class Player {
  int radius;
  boolean begin = false;
  boolean hittingLine = false;
  int numHits = 0;

  Player(int rr) {
    radius = rr;
  }
  
  void show() {
    noStroke();
    fill(40);
    if (!begin)  // display player if maze is not being drawn
      ellipse(w/2, w/2, radius, radius);
    else
      ellipse(px, py, radius, radius);
  }
  
  void update() {
    checkBeginState();

    if (begin && hitLine()) {
      if (!hittingLine) {    // hits a line only once
        hittingLine = true;
        numHits++;
        player.begin = false;
      }
      textSize(200);
      textAlign(CENTER);
      fill(255, 0, 50);
      text("HIT LINE", width/2, height/2 - 5);
    }

    if (begin && hitFinish) {  // completes maze
      textSize(800);
      textAlign(CENTER);
      fill(50, 0, 150);
      text("WINNER", width/2, height/2 + 300);
    }
  }

  void checkBeginState() {    // player returns to beginning state after maze is rebuilt
    if (!begin && px < w*0.7 && px > 10 && py < w*0.7 && py > 10)
      begin = true;
  }

  boolean hitFinish = false;
  boolean hitLine() {    // TODO refactor with an array containing walls rather
    loadPixels();        // than checking each pixel in this fashion
    int skip = 8;
    for (int y = 0; y < height; y += skip) {
      for (int x = 0; x < width; x += skip) {
        int index = x + y * width;
        int b = round(brightness(pixels[index]));
        int d = distance(x, y, px, py);
        if (b > 240 && d - 120 < 0) {    //w = 539, d - 172
          return true;
        }
        if (px > width - 390 && py > height - 400) //w = 539, width - 750, height - 700
          hitFinish = true;
        else
          hitFinish = false;
      }
    }
    return false;
  }
}
