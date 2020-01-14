class Cell {
  int i, j;
  boolean[] walls = {true, true, true, true};  // every wall is active twice (once on both sides of the wall)
  boolean visited = false;

  Cell(int ii, int jj) {  // input coords
    i = ii;
    j = jj;
  }

  Cell checkNeighbors() {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();

    Cell top    = grid.get(index(i, j-1));  // top wall
    Cell right  = grid.get(index(i+1, j));  // right wall
    Cell bottom = grid.get(index(i, j+1));  // bottom wall
    Cell left   = grid.get(index(i-1, j));  // left wall

    // add neighbours to neighbors array
    if (top != null && !top.visited) {
      neighbors.add(top);
    }
    if (right != null && !right.visited) {
      neighbors.add(right);
    }
    if (bottom != null && !bottom.visited) {
      neighbors.add(bottom);
    }
    if (left != null && !left.visited) {
      neighbors.add(left);
    }

    if (neighbors.size() > 0) {
      int r = floor(random(0, neighbors.size()));
      return neighbors.get(r);
    } else {
      return null;
    }
  }

  // returns index based on coords
  int index(int i, int j) {
    if (i < 0 || j < 0 || i > cols-1 || j > rows-1) {  // check if valid coord
      return 0;
    }
    return i + j * cols;
  }

  // highlight cell in different color
  void highlight(color c) {
    int x = this.i*w;
    int y = this.j*w;
    noStroke();
    fill(c);  //0, 0, 255, 100
    rect(x, y, w, w);
  }

  // display this cell
  void show() {
    int x = this.i*w;
    int y = this.j*w;
    
    if (this.visited) {
      noStroke();
      fill(255, 0, 255, 100);
      rect(x, y, w, w);
    }
    
    stroke(255);
    strokeWeight(10);
    if (this.walls[0]) {
      line(x, y, x + w, y);
    }
    if (this.walls[1]) {
      line(x + w, y, x + w, y + w);
    }
    if (this.walls[2]) {
      line(x + w, y + w, x, y + w);
    }
    if (this.walls[3]) {
      line(x, y + w, x, y);
    }
  }
}
