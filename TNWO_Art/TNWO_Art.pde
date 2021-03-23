import oscP5.*;
import netP5.*;

//OSC Info For Data Reciver
OscP5 oscP5;
NetAddress myRemoteLocation;

//Purple
color purple = color(136, 3, 252);
//Red
color red = color(255, 0, 0);

//Number Of Purple Humans
int purpleHumans = 0;

//Number Of Red Humans
int redHumans = 0;

void setup(){
	size(800, 800);
  
  noStroke();

	//Starts An OSC Reciver On Local IP With Port 12000
	oscP5 = new OscP5(this, 12000);
	myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw(){
  //Sets The Background To Grey
	background(150);

  //Creates The Purple Rectangle
  fill(purple);
  float pM = map(purpleHumans, 0, purpleHumans + redHumans, 0, width);
  rect(0, 0, pM, height);
  
  //Creates The Red Rectangle
  fill(red);
  float rM = map(redHumans, 0, purpleHumans + redHumans, 0, width);
  rect(pM, 0, rM, height);
}

//Runs When An OCS Message Is Recived
void oscEvent(OscMessage theOscMessage){
	//Gets The Purple Human Count
	purpleHumans = theOscMessage.get(0).intValue();
  //Gets The Red Human Count
  redHumans = theOscMessage.get(1).intValue();
}
