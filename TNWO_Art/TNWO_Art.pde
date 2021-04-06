import oscP5.*;
import netP5.*;

//OSC Info For Data Reciver
OscP5 oscP5;
NetAddress myRemoteLocation;

//Colours
color purple = color(136, 3, 252); //Purple
color red = color(255, 0, 0); //Red
color mixRP = color(199,21,133); //Redy Purple
color blue = color(91, 208, 242); //Blue
color green = color(152, 255, 138); //Green

//Jitter Value
int jitterValue = 5;

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

//Highest Thirst
int maxThirst = 0;
//Adverage Thirst
int advThirst = 0;
//Lowest Thirst
int lowestThirst = 0;

//Highest Speed
int maxSpeed = 0;
//Adverage Speed
int advSpeed = 0;
//Lowest Speed
int lowestSpeed = 0;

//Oldest Human
int maxAge = 0;
//Adverage Age
int advAge = 0;
//Lowest Age
int lowestAge = 0;

void setup(){
	size(800, 800);
	//fullScreen();
	frameRate(10);
	
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
	//Creates A Gradient Background
	setGradient(0, 0, width, height, blue, green);

	//Works Out Which Squares Should Be What Color
	int purpleSquareCount = int(map(purpleHumans, 0, purpleHumans + redHumans + mixedHumans, 0, squareCount));
	int mixedSquareCount = int(map(mixedHumans, 0, purpleHumans + redHumans + mixedHumans, 0, squareCount));

	//Used To Know How Many Squares Have Been Drawn
	int inLoopSqaureCount = 1;

	//Loops Through All The Squares
	for (int y = yMinBound + (spacingSize / 2); y < yMaxBound; y += squareSize + spacingSize) {
		for (int x = xMinBound + (spacingSize / 2); x < xMaxBound; x += squareSize + spacingSize) {

			//Rotation For Purple Squares
			float purpleRotate = (maxSpeed - lowestSpeed) + inLoopSqaureCount;

			//Rotation For Red Squares
			float redRotate = (maxThirst - lowestThirst) + inLoopSqaureCount;

			//Rotation For Mixed Squares
			float mixedRotate = (maxAge - lowestAge) + inLoopSqaureCount;

			//Checks Whether It Is A Purple Or Red Square
			if (inLoopSqaureCount <= purpleSquareCount) {
				//Sets The Outline To Purple
				stroke(purple);

				//Creates A New PushPop Matrix Allowing Translations To Only Effect This Square
				pushMatrix();
					//Moves The Start Pos (0,0) To This Location
					translate(x + (squareSize / 2), y + (squareSize / 2));

					//Creates A New Rotation Angle To Apply To Anything After It
					rotate(radians(purpleRotate + Jitter()));

					//Draws The Rectangle With The Rotation At The Translated Pos
					rect(-(squareSize / 2), -(squareSize / 2), squareSize, squareSize);

				//Pops The Matrix
				popMatrix();
			}
			else {
				if (inLoopSqaureCount <= purpleSquareCount + mixedSquareCount) {
					//Sets The Outline To The Mixed Colour
					stroke(mixRP);

					//Creates A New PushPop Matrix Allowing Translations To Only Effect This Square
					pushMatrix();
						//Moves The Start Pos (0,0) To This Location
						translate(x + (squareSize / 2), y + (squareSize / 2));

						//Creates A New Rotation Angle To Apply To Anything After It
						rotate(radians(mixedRotate + Jitter()));

						//Draws The Rectangle With The Rotation At The Translated Pos
						rect(-(squareSize / 2), -(squareSize / 2), squareSize, squareSize);

					//Pops The Matrix
					popMatrix();
				}
				else{
					//Sets The Outline To Red
					stroke(red);

					//Creates A New PushPop Matrix Allowing Translations To Only Effect This Square
					pushMatrix();
						//Moves The Start Pos (0,0) To This Location
						translate(x + (squareSize / 2), y + (squareSize / 2));

						//Creates A New Rotation Angle To Apply To Anything After It
						rotate(radians(redRotate + Jitter()));

						//Draws The Rectangle With The Rotation At The Translated Pos
						rect(-(squareSize / 2), -(squareSize / 2), squareSize, squareSize);
						
					//Pops The Matrix
					popMatrix();
				}
			}

			//Increments The Squares Drawn Counter
			inLoopSqaureCount++;
		}
	}
}

//Creates A Randome "Jitter" Value From The Range In The Global Var
int Jitter(){
	return int(random(-jitterValue, jitterValue));
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
	advThirst = theOscMessage.get(4).intValue();
	//Gets The Lowest Thirst Value
	lowestThirst = theOscMessage.get(5).intValue();

	//Gets The Highest Speed
	maxSpeed = theOscMessage.get(6).intValue();
	//Gets The Adverage Speed
	advSpeed = theOscMessage.get(7).intValue();
	//Gets The Lowest Speed
	lowestSpeed = theOscMessage.get(8).intValue();

	//Gets The Oldest
	maxAge = theOscMessage.get(9).intValue();
	//Gets The Adverage Age
	advAge = theOscMessage.get(10).intValue();
	//Gets The Youngest
	lowestAge = theOscMessage.get(11).intValue();
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