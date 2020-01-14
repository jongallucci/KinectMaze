import org.openkinect.processing.*;  // kinect interface library
Kinect kinect;
int[] depth;    // depth information

int minthresh = 0;    // thresholds for depth
int maxthresh = 600;
PImage img;
int kw, kh;           // kinect width and height
float prevX = 0;
float prevY = 0;

int rows, cols;
int numCells;
int w = 425;
ArrayList<Cell> grid = new ArrayList<Cell>();
Cell current;

ArrayList<Cell> stack = new ArrayList<Cell>();

Player player;
int px;
int py;

void setup() {
  fullScreen();
  rows = floor(height/w);
  cols = floor(width/w);
  numCells = rows * cols;

  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      grid.add(new Cell(i, j));
    }
  }
  current = grid.get(0);        // current position
  player = new Player(w - 200); // proportional player size

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  depth = kinect.getRawDepth();  // raw depth information

  kw = kinect.width;
  kh = kinect.height;

  img = createImage(kw, kh, RGB);  // creates program board
}

boolean mazeComplete = false;
void draw() {
  background(51);
  depth = kinect.getRawDepth();  // refresh user input

  for (int i = 0; i < numCells; i++) {
    grid.get(i).show();    // display grid
  }

  current.visited = true;
  current.highlight(color(70, 0, 200, 255));  // set colors to highligted color after being visited

  Cell next = current.checkNeighbors();
  if (next != null) {
    next.visited = true;
    stack.add(current);
    removeWalls(current, next);
    current = next;
  } else if (stack.size() > 0)
    current = stack.remove(stack.size() - 1);

  if (mazeComplete)
    MazeComplete();  

  Cell end = grid.get(grid.size()-1);
  if (end.visited && current.index(current.i, current.j) == 0)
    mazeComplete = true;

  // FPS counter for debugging 
  textSize(80);
  fill(255, 255, 10);
  textAlign(LEFT);
  text(nf(frameRate, 0, 2) + " FPS", width - 420, 100);

  // number of times the user hit a wall
  textSize(80);
  fill(255, 255, 10);
  textAlign(LEFT);
  text(player.numHits + " Hits", width - 420, 190);

  player.hittingLine = false;
}

// removes unneeded wall after maze path is genereted
void removeWalls(Cell one, Cell two) {
  int x = one.i - two.i;
  if (x == 1) {
    one.walls[3] = false;
    two.walls[1] = false;
  } else if (x == -1) {
    one.walls[1] = false;
    two.walls[3] = false;
  }
  int y = one.j - two.j;
  if (y == 1) {
    one.walls[0] = false;
    two.walls[2] = false;
  } else if (y == -1) {
    one.walls[2] = false;
    two.walls[0] = false;
  }
}

void MazeComplete() {  
  background(51);
  for (int i = 0; i < numCells; i++) {
    grid.get(i).show();
  }
  current.highlight(color(70, 0, 200, 255));                    //highlights start square 
  grid.get(grid.size()-1).highlight(color(150, 20, 40, 255));   //highlights end square

  float sumX = 0;
  float sumY = 0;
  float count = 0;

  img.loadPixels();
  for (int i = 0; i < kw; i++) {
    for (int j = 0; j < kh; j++) {
      int index = i + (j * kw);
      int d = depth[index];
      if (d > minthresh && d < maxthresh) {      // user is within range to control player object
        img.pixels[index] = color(255, 0, 105);
        sumX += i;  // used later to average digit representation of where the user's hand is
        sumY += j;
        count++;
      } else {
        img.pixels[index] = color(50);
      }
    }
  }
  img.updatePixels();
  image(img, 0, 0);

  if (count != 0) {
    float avgX = sumX / count;
    float avgY = sumY / count;

    avgX = map(avgX, 0, kw, width, 0);
    avgY = map(avgY, 0, kh, 0, height);

    float easing = 0.02;      // smooths movements
    float targetX = avgX;
    float dx = targetX - prevX;
    prevX += dx * easing;

    float targetY = avgY;
    float dy = targetY - prevY;
    prevY += dy * easing;

    stroke(180);
    ellipse(avgX, avgY, 80, 80);
    prevX = avgX;
    prevY = avgY;

    px = round(avgX);
    py = round(avgY);
  } else {
    player.begin = false;
  }

  player.show();
  player.update();
}

// gets a rough distance between two xs and ys
// made to avoid squareroot to reduce lag
int distance(int x1, int y1, int x2, int y2) {
  int dx = abs(x2 - x1);
  int dy = abs(y2 - y1);
  if (dy > dx)
    return round(0.41*dx + 0.9412246*dy);
  return round(0.41*dy + 0.9412246*dx);
}
