import oscP5.*;
import netP5.*;

//OSC Info For Data Reciver
OscP5 oscP5;
NetAddress myRemoteLocation;

//Run Type
RunTypes runType = RunTypes.Fadeout;

//Mutiplier For The Lines
int mutiplier = 10;

//The Time Before Lines Dissapear
int shrinkVal = 50;

//Colours
color purple = color(136, 3, 252); //Purple
color red = color(255, 0, 0); //Red
color mixRP = color(199,21,133); //Redy Purple
color blue = color(91, 208, 242); //Blue
color green = color(152, 255, 138); //Green

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

//ArrayList Of All The Lines
ArrayList<Line> lines = new ArrayList<Line>();

//PVectors Of The Lines
PVector blueLine, greenLine, redLine, purpleLine;

void setup(){
	size(800, 800);

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

void draw(){
	//Runs The Draw Loop If It's Recived A New OSC Msg
	if(drawNow == true){
		//Clears The Screen
		background(0);

		//Creates A Random Angle
		int blueAngle = int(random(360));
		//Works Out The Move Size
		int blueRadius = maxThirst - advThirst + mutiplier;

		//Creates A New Move Postion
		PVector newBlue = new PVector(BoundsCheck(int(blueLine.x + (cos(radians(blueAngle)) * blueRadius)), 0), 
									  BoundsCheck(int(blueLine.y + (sin(radians(blueAngle)) * blueRadius)), 1));
							
		//Creates The New Blue Line
		lines.add(new Line(blueLine, newBlue, blue, currentTick));

		//Updates The Current Pos
		blueLine = newBlue;


		//Creates A Random Angle
		int greenAngle = int(random(360));
		//Works Out The Move Size
		int greenRadius = maxSpeed - advSpeed + mutiplier;

		//Creates A New Move Position
		PVector newGreen = new PVector(BoundsCheck(int(greenLine.x + (cos(radians(greenAngle)) * greenRadius)), 0), 
									   BoundsCheck(int(greenLine.y + (sin(radians(greenAngle)) * greenRadius)), 1));

		//Creates The New Blue Line
		lines.add(new Line(greenLine, newGreen, green, currentTick));

		//Updates The Current Pos
		greenLine = newGreen;


		//Creates A Random Angle
		int purpleAngle = int(random(360));
		//Works Out The Move Size
		int purpleRadius = int(map(purpleHumans, 0, purpleHumans + redHumans, 0, blueRadius)) + mutiplier;

		//Creates A New Move Position
		PVector newPurple = new PVector(BoundsCheck(int(purpleLine.x + (cos(radians(purpleAngle)) * purpleRadius)), 0), 
									    BoundsCheck(int(purpleLine.y + (sin(radians(purpleAngle)) * purpleRadius)), 1));

		//Creates The New Blue Line
		lines.add(new Line(purpleLine, newPurple, purple, currentTick));

		//Updates The Current Pos
		purpleLine = newPurple;


		//Creates A Random Angle
		int redAngle = int(random(360));
		//Works Out The Move Size
		int redRadius = int(map(redHumans, 0, purpleHumans + redHumans, 0, greenRadius)) + mutiplier;

		//Creates A New Move Position
		PVector newRed = new PVector(BoundsCheck(int(redLine.x + (cos(radians(redAngle)) * redRadius)), 0), 
									 BoundsCheck(int(redLine.y + (sin(radians(redAngle)) * redRadius)), 1));

		//Creates The New Blue Line
		lines.add(new Line(redLine, newRed, red, currentTick));

		//Updates The Current Pos
		redLine = newRed;

		switch (runType) {
			case Forever:
				//Loops Through All The Lines In The Array List
				for (Line l : lines) {
					//Sets The Line Colour
					stroke(l.colour);

					//Draws The Line
					line(l.startPos.x, l.startPos.y, l.endPos.x, l.endPos.y);
				}
				break;
			
			case Fadeout:
				//Loops Through All The Lines In The Array List
				//Backwards To Remove Old Lines Correctly
				for (int i = lines.size() - 1; i >= 0 ; i--) {
					//Current Line
					Line l = lines.get(i);

					//Removes Lines That Are Too Old
					if(currentTick - l.dob > shrinkVal){
						lines.remove(i);
					}

					//Sets The Line Colour
					stroke(l.colour, map(currentTick - l.dob, 0, shrinkVal, 255, 0));

					//Draws The Line
					line(l.startPos.x, l.startPos.y, l.endPos.x, l.endPos.y);
				}
				break;

			case Shrink:
				//Loops Through All The Lines In The Array List
				//Backwards To Remove Old Lines Correctly
				for (int i = lines.size() - 1; i >= 0 ; i--) {
					//Current Line
					Line l = lines.get(i);

					//Removes Lines That Are Too Old
					if(currentTick - l.dob > shrinkVal){
						lines.remove(i);
					}

					//Sets The Line Colour
					stroke(l.colour);

					//Draws The Line
					line(l.startPos.x, l.startPos.y, l.endPos.x, l.endPos.y);
				}
				break;

			case Fadein:
				//Loops Through All The Lines In The Array List
				//Backwards To Remove Old Lines Correctly
				for (int i = lines.size() - 1; i >= 0 ; i--) {
					//Current Line
					Line l = lines.get(i);

					//Removes Lines That Are Too Old
					if(currentTick - l.dob > shrinkVal){
						lines.remove(i);
					}

					//Sets The Line Colour
					stroke(l.colour, map(currentTick - l.dob, 0, shrinkVal, 0, 255));

					//Draws The Line
					line(l.startPos.x, l.startPos.y, l.endPos.x, l.endPos.y);
				}
				break;
		}


		//Updates The Last Ticks Info
		lastPurple = purpleHumans;
		lastRed = redHumans;
		lastMixed = mixedHumans;

		//Stops The Draw Func From Running Till The Next OSC Msg
		drawNow = false;
	}
}

//Checks The New Pos Fits On The Screen If It Doesn't It Moves It Across The Screen
int BoundsCheck(int loc, int axis){
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
void oscEvent(OscMessage theOscMessage){
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

public enum RunTypes{
	Forever, Fadeout, Shrink, Fadein;
}