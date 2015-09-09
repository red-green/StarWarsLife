/**
 * A Processing implementation of Game of Life
 * By Joan Soler-Adillon
 *
 * Press SPACE BAR to pause and change the cell's values with the mouse
 * On pause, click to activate/deactivate cells
 * Press R to randomly reset the cells' grid
 * Press C to clear the cells' grid
 *
 * The original Game of Life was created by John Conway in 1970
 
 # Heavily modified by Jackson Servheen
 # Added support for Generations algorithm, zooming, drawing in realtime,
   Speed and step adjustment, change algorithms with keys, wraparound
 */

// Size of cells
int cellSize = 3;

int grow = 2;

int states = 5;

int zoom = 1;

int tranx=0,trany=0;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 70;

// Variables for timer
int interval = 10;
int lastRecordedTime = 0;

int step = 1;

// Colors for active/inactive cells
color alive = color(0, 200, 0);
color dead = color(0);

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

// Pause
boolean pause = false;

void setup() {
  size (600,640);

  // Instantiate arrays 
  cells = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];

  // This stroke will draw the background grid
  stroke(48);
  strokeWeight(0.1);

  noSmooth();

  // Initialization of cells
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      if (state < probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = states;
      }
      cells[x][y] = int(state); // Save state of each cell
    }
  }
  background(0); // Fill in black in case cells don't cover all the windows
  
  frameRate(200);
}


void draw() {

  scale(zoom);
  translate(tranx,trany);
  //Draw grid
  if(pause){ stroke(48);}else{noStroke();}
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if (cells[x][y]==3) {
        fill(255,0,0); // If alive
      } else if (cells[x][y]==2) {
        fill(255,128,0); // If alive
      } else if (cells[x][y]==1) {
        fill(255,255,0); // If alive
      }
      else {
        fill(0); // If dead
      }
      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  
  // Iterate if timer ticks
  /*if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      for (int i = 0; i < step; i++)
        iteration();
      lastRecordedTime = millis();
    }
  }*/
  if (!pause) {
  for (int i = 0; i < step; i++)
    iteration();
  }
  // Create  new cells manually on pause
  if (mousePressed) {
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, (width/zoom)/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, (height/zoom)/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);

    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver]!=0) { // Cell is alive
      cells[xCellOver][yCellOver]=0; // Kill
      fill(dead); // Fill with kill color
    }
    else { // Cell is dead
      cells[xCellOver][yCellOver]=3; // Make alive
      fill(alive); // Fill alive color
    }
  } 
  else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }
}



void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }
    int txx=0,tyy=0;
  // Visit each cell:
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
            txx = xx;
            tyy = yy;
            
            if (xx<0)
              txx = width/cellSize-1;
            if (xx>=width/cellSize)
             txx = 0;
            if (yy<0)
              tyy = height/cellSize-1;
            if (yy>=height/cellSize)
              tyy = 0;
            
            if (cellsBuffer[txx][tyy]==states){
              neighbours ++; // Check alive neighbours and count them
            } 
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      cells[x][y]--;
      if (cellsBuffer[x][y]==states) { // The cell is alive: kill it if necessary
        if (neighbours == grow || neighbours == 3 || neighbours == 4 || neighbours == 5) {
          cells[x][y]=states; // Die unless it has 2 or 3 neighbours
        }
      } else if (cellsBuffer[x][y] != 0) { //taking up space
        //cells[x][y]--;
      } else { // The cell is dead: make it live if necessary      
        if (neighbours == 2 ) {
          cells[x][y]=states; // Only if it has 3 neighbours
        }
      } // End of if
      if (cells[x][y] < 0) cells[x][y] = 0;
    } // End of y loop
  } // End of x loop
} // End of function

void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = states;
        }
        cells[x][y] = int(state); // Save state of each cell
      }
    }
  }
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
  }
  if (key == 'z')
    grow = -grow;
  
  if (key == '-') step /= 5;
  if (key == '=') step *= 5;
  if (step < 1) step = 1;
  
  if (key == 'o') zoom--;
  if (key == 'p') zoom++;
  
  if (keyCode == UP) trany+= cellSize;
  if (keyCode == DOWN) trany-= cellSize;
  if (keyCode == LEFT) tranx+= cellSize;
  if (keyCode == RIGHT) tranx-= cellSize;
  
  println("Step: " + step + "  Framerate: " + 1000/interval);
}

