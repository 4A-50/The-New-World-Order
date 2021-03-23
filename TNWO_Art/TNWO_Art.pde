import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int humanCount = 0;

void setup() {
  size(800, 800);
  strokeWeight(5);
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw(){
  noStroke();
  fill(0, 20);
  rect(0, 0, width, height);
  
  stroke(255);
  noFill();
  rect(0, 0, humanCount, humanCount); 
}

void oscEvent(OscMessage theOscMessage)
{
  humanCount = theOscMessage.get(0).intValue();
}
