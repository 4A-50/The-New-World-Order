import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TNWO_Art extends PApplet {




//OSC Info For Data Reciver
OscP5 oscP5;
NetAddress myRemoteLocation;

//Colours
int purple = color(136, 3, 252); //Purple
int red = color(255, 0, 0); //Red
int mixRP = color(199,21,133); //Redy Purple
int blue = color(91, 208, 242); //Blue
int green = color(152, 255, 138); //Green

//Bounds
int xMinBound;
int xMaxBound;
int yMinBound;
int yMaxBound;

//Square Count
int squareCount;

//Square Size
int squareSize = 50;

//Spacing Size
int spacingSize = 25;

//Current Tick
int currentTick = 0;

//Purple Human Count
int purpleHumans = 0;
//Red Human Count
int redHumans = 0;
//Mixed Human Count
int mixedHumans = 0;

//The Last Ticks Purples
int lastPurple = 0;
//The Last Ticks Reds
int lastRed = 0;
//The Last Ticks Mixed
int lastMixed = 0;

//Highest Thirst
int maxThirst = 0;
//Adverage Thirst
int advThirst = 0;

//Highest Speed
int maxSpeed = 0;
//Adverage Speed
int advSpeed = 0;

//Oldest Human
int maxAge = 0;
//Adverage Age
int advAge = 0;

//Runs The Draw Func
boolean drawNow = false;

//PVectors Of The Lines
PVector blueLine, greenLine, redLine, purpleLine;

public void setup(){
	
	
  	noFill();

	//Starts An OSC Reciver On Local IP With Port 12000
	oscP5 = new OscP5(this, 12000);
	myRemoteLocation = new NetAddress("127.0.0.1", 12000);

	//Creates A Black Background
	background(0);

	//Works Out The Center Of The Screen
	PVector center = new PVector(width / 2, height / 2);

	//Starts All The Lines In The Center Of The Screen
	blueLine = new PVector(center.x, center.y);
	greenLine = new PVector(center.x, center.y);
	redLine = new PVector(center.x, center.y);
	purpleLine = new PVector(center.x, center.y);
}

public void draw(){
	//Runs The Draw Loop If It's Recived A New OSC Msg
	if(drawNow == true){
		//Blue Colour
		stroke(blue);

		//Creates A Random Angle
		int blueAngle = PApplet.parseInt(random(360));
		//Works Out The Move Size
		int blueRadius = maxThirst - advThirst;

		//Creates A New Move Postion
		PVector newBlue = new PVector(BoundsCheck(PApplet.parseInt(blueLine.x + (cos(radians(blueAngle)) * blueRadius)), 0), 
									  BoundsCheck(PApplet.parseInt(blueLine.y + (sin(radians(blueAngle)) * blueRadius)), 1));
							
		//Draws The Lines Between The Current Pos and New One
		line(blueLine.x, blueLine.y, newBlue.x, newBlue.y);

		//Updates The Current Pos
		blueLine = newBlue;
		

		//Green Colour
		stroke(green);

		//Creates A Random Angle
		int greenAngle = PApplet.parseInt(random(360));
		//Works Out The Move Size
		int greenRadius = maxSpeed - advSpeed;

		//Creates A New Move Position
		PVector newGreen = new PVector(BoundsCheck(PApplet.parseInt(greenLine.x + (cos(radians(greenAngle)) * greenRadius)), 0), 
									   BoundsCheck(PApplet.parseInt(greenLine.y + (sin(radians(greenAngle)) * greenRadius)), 1));

		//Draws The Lines Between The Current Pos and New One
		line(greenLine.x, greenLine.y, newGreen.x, newGreen.y);

		//Updates The Current Pos
		greenLine = newGreen;


		//Purple Colour
		stroke(purple);

		//Creates A Random Angle
		int purpleAngle = PApplet.parseInt(random(360));
		//Works Out The Move Size
		int purpleRadius = lastPurple - purpleHumans;

		//Creates A New Move Position
		PVector newPurple = new PVector(BoundsCheck(PApplet.parseInt(purpleLine.x + (cos(radians(purpleAngle)) * purpleRadius)), 0), 
									    BoundsCheck(PApplet.parseInt(purpleLine.y + (sin(radians(purpleAngle)) * purpleRadius)), 1));

		//Draws The 
		line(purpleLine.x, purpleLine.y, newPurple.x, newPurple.y);

		//Updates The Current Pos
		purpleLine = newPurple;


		//Red Colour
		stroke(red);

		//Creates A Random Angle
		int redAngle = PApplet.parseInt(random(360));
		//Works Out The Move Size
		int redRadius = lastRed - redHumans;

		//Creates A New Move Position
		PVector newRed = new PVector(BoundsCheck(PApplet.parseInt(redLine.x + (cos(radians(redAngle)) * redRadius)), 0), 
									 BoundsCheck(PApplet.parseInt(redLine.y + (sin(radians(redAngle)) * redRadius)), 1));

		//Draws The 
		line(redLine.x, redLine.y, newRed.x, newRed.y);

		//Updates The Current Pos
		redLine = newRed;


		//Updates The Last Ticks Info
		lastPurple = purpleHumans;
		lastRed = redHumans;
		lastMixed = mixedHumans;

		//Stops The Draw Func From Running Till The Next OSC Msg
		drawNow = false;
	}
}

//Checks The New Pos Fits On The Screen If It Doesn't It Moves It Across The Screen
public int BoundsCheck(int loc, int axis){
    if(axis == 0){
        if (loc < 0) {
            noStroke();
            return width;
        }

        if (loc > width){
            noStroke();
            return 0;
        }
    }
    else{
        if (loc < 0) {
            noStroke();
            return height;
        }

        if (loc > height){
            noStroke();
            return 0;
        }
    }

    return loc;
}

//Runs When An OCS Message Is Recived
public void oscEvent(OscMessage theOscMessage){
	//Gets The Curent Tick
	currentTick = theOscMessage.get(0).intValue();

	//Gets The Purple Human Count
	purpleHumans = theOscMessage.get(1).intValue();
	//Gets The Red Human Count
	redHumans = theOscMessage.get(2).intValue();
	//Gets The Mixed Human Count
	mixedHumans = theOscMessage.get(3).intValue();

	//Gets The Highest Thirst Value
	maxThirst = theOscMessage.get(4).intValue();
	//Gets The Adverage Thirst Value
	advThirst = theOscMessage.get(5).intValue();

	//Gets The Highest Speed
	maxSpeed = theOscMessage.get(6).intValue();
	//Gets The Adverage Speed
	advSpeed = theOscMessage.get(7).intValue();

	//Gets The Oldest
	maxAge = theOscMessage.get(8).intValue();
	//Gets The Adverage Age
	advAge = theOscMessage.get(9).intValue();

	drawNow = true;
}
  public void settings() { 	size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TNWO_Art" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
