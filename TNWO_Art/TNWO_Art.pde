import oscP5.*;
import netP5.*;

//OSC Info For Data Reciver
OscP5 oscP5;
NetAddress myRemoteLocation;

//Draw Bool
boolean drawNow = false;

//Colours
color purple = color(136, 3, 252); //Purple
color red = color(255, 0, 0); //Red
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

//Purple Human Count
int purpleHumans = 0;
//Red Human Count
int redHumans = 0;
//Mixed Human Count
int mixedHumans = 0;

//Highest Thirst Value
int maxThirst = 0;
//Adverage Thirst Value
int advThirst = 0;

//Highest Speed
int maxSpeed = 0;
//Adverage Speed
int advSpeed = 0;

void setup(){
	size(800, 800);
	//fullScreen();
	
  	noFill();

	//Works Out The Safe Area And Count For Squares
	CreateSafeArea();

	//Starts An OSC Reciver On Local IP With Port 12000
	oscP5 = new OscP5(this, 12000);
	myRemoteLocation = new NetAddress("127.0.0.1", 12000);

	//Creates A Gradient Background
	setGradient(0, 0, width, height, blue, green);
}

void draw(){
	//Only Runs The Draw Function When OSC Data Comes In
	//Works Better Then A Delay Or Frame Limit As I Can Just Change Sim Speed
	if (drawNow == true) {
		//Creates A Gradient Background
		setGradient(0, 0, width, height, blue, green);

		//Works Out Which Squares Should Be What Color
		int purpleSquareCount = int(map(purpleHumans, 0, purpleHumans + redHumans, 0, squareCount));

		//Used To Know How Many Squares Have Been Drawn
		int inLoopSqaureCount = 1;

		//Loops Through All The Squares
		for (int y = yMinBound + (spacingSize / 2); y < yMaxBound; y += squareSize + spacingSize) {
			for (int x = xMinBound + (spacingSize / 2); x < xMaxBound; x += squareSize + spacingSize) {

				//Mapped Rotation For Purple Squares
				float purpleRotate = map(advSpeed + inLoopSqaureCount, 0, advThirst + squareCount, 0, 45);

				//Mapped Rotation For Red Squares
				float redRotate = map(advThirst + inLoopSqaureCount, 0, maxThirst + squareCount, 0, 45);

				//Checks Whether It Is A Purple Or Red Square
				if (inLoopSqaureCount <= purpleSquareCount) {
					//Sets The Outline To Purple
					stroke(purple);

					//Creates A New PushPop Matrix Allowing Translations To Only Effect This Square
					pushMatrix();
						//Moves The Start Pos (0,0) To This Location
						translate(x + (squareSize / 2), y + (squareSize / 2));

						//Creates A New Rotation Angle To Apply To Anything After It
						rotate(radians(purpleRotate));

						//Draws The Rectangle With The Rotation At The Translated Pos
						rect(-(squareSize / 2), -(squareSize / 2), squareSize, squareSize);

					//Pops The Matrix
					popMatrix();
				}
				else {
					//Sets The Outline To Red
					stroke(red);

					//Creates A New PushPop Matrix Allowing Translations To Only Effect This Square
					pushMatrix();
						//Moves The Start Pos (0,0) To This Location
						translate(x + (squareSize / 2), y + (squareSize / 2));

						//Creates A New Rotation Angle To Apply To Anything After It
						rotate(radians(redRotate));

						//Draws The Rectangle With The Rotation At The Translated Pos
						rect(-(squareSize / 2), -(squareSize / 2), squareSize, squareSize);
						
					//Pops The Matrix
					popMatrix();
				}

				//Increments The Squares Drawn Counter
				inLoopSqaureCount++;
			}
		}

		drawNow = false;
	}
}

//Runs When An OCS Message Is Recived
void oscEvent(OscMessage theOscMessage){
	//Gets The Purple Human Count
	purpleHumans = theOscMessage.get(0).intValue();
	//Gets The Red Human Count
	redHumans = theOscMessage.get(1).intValue();
	//Gets The Mixed Human Count
	mixedHumans = theOscMessage.get(2).intValue();

	//Gets The Highest Thirst Value
	maxThirst = theOscMessage.get(3).intValue();
	//Gets The Adverage Thirst Value
	advThirst = theOscMessage.get(4)).intValue();

	//Gets The Highest Speed
	maxSpeed = theOscMessage.get(5).intValue();
	//Gets The Adverage Speed
	advSpeed = theOscMessage.get(6).intValue();

	drawNow = true;
}

void CreateSafeArea(){
	xMinBound = width / 8;
	xMaxBound = (width / 8) * 7;
	yMinBound = height / 8;
	yMaxBound = (height / 8) * 7;

	for (int y = yMinBound + (spacingSize / 2); y < yMaxBound; y += squareSize + spacingSize) {
		for (int x = xMinBound + (spacingSize / 2); x < xMaxBound; x += squareSize + spacingSize) {
			squareCount++;
		}
	}
}

void setGradient(int x, int y, float w, float h, color c1, color c2) {
	strokeWeight(1);

  	for (int i = y; i <= y+h; i++) {
		float inter = map(i, y, y+h, 0, 1);
		color c = lerpColor(c1, c2, inter);
		stroke(c);
		line(x, i, x+w, i);
    }

	strokeWeight(5);
}