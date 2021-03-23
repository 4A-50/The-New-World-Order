import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TheNewWorldOrder_Sim extends PApplet {

//Time Between Ticks In Seconds
float tickTime = 1f;

//The Current Tick Count
int tickCount = 0;

//Ground Colours
int sand = color(255, 221, 138); //Sand
int grass = color(152, 255, 138); //Grass
int water = color(91, 208, 242); //Water
int cliff = color(181, 183, 181); //Cliff

//Tribe Colours
int purple = color(136, 3, 252); //Purple
int red = color(255, 0, 0); //Red

//Image Width & Height
int imgWidth = 512;
int imgHeight = 512;

//Outline Images
PImage outline;

//Valid Pixel List
boolean[][] validPixels = new boolean[imgWidth][imgHeight];

//Spawn Images
PImage spawns;

//Humans
ArrayList<Human> humans = new ArrayList<Human>();

//Min Time Between Mates
int minMateTime = 2;

public void setup(){
    

    background(255, 255, 255);
    noStroke();
    rectMode(CENTER);

    //Loads The Background Image File In Then Loads All Of It's Pixels
    outline = loadImage("outline.png");
    outline.loadPixels();

    //Loads The Spawn Image File In Then Loads All Of It's Pixels
    spawns = loadImage("spawns.png");
    spawns.loadPixels();

    //Loops Through Every Pixel And Checks If It Is A Valid Pixel From It's Colour
    for (int x = 0; x < imgWidth; ++x) {
        for (int y = 0; y < imgHeight; ++y) {
            int currentPixel = outline.pixels[x + y * width];

            if (currentPixel == sand || currentPixel == grass){
                validPixels[x][y] = true;
            }
        }
    }

    //Loops Through Every Pixel And Checks If It Is A Spawn Point
    for (int x = 0; x < imgWidth; ++x) {
        for (int y = 0; y < imgHeight; ++y) {
            int currentPixel = spawns.pixels[x + y * width];

            //If The Pixel Is Purple Spawn A Purple Tribesman
            if (currentPixel == purple){
                humans.add(new Human(humans.size() + 1, new Coords(x, y), purple, 0, 13, 13)); //Adds The New Human To The Object List
            }

            //If The Pixel Is Red Spawn A Red Tribesman
            if (currentPixel == red){
                humans.add(new Human(humans.size() + 1, new Coords(x, y), red, 0, 13, 13)); //Adds The New Human To The List
            }
        }
    }
}

public void draw(){
    //Draws The Background Image Onto Screen
    image(outline, 0, 0);

    //Prints The Tick Count On Screen
    fill(0);
    text("Tick: " + tickCount, 5, 15);
    text("Day: " + tickCount / 4, 5, 30);

    //Loops Thorugh All Humans To Perform Tick Actions
    //Loops Backwards (Final Item -> First Item) For Clean And Easy Killings
    for (int i = humans.size() - 1; i >= 0 ; i--) {
        //The Current Human
        Human currentHuman = humans.get(i);

        //Tells The Human To Do Any Tick Based Updates
        currentHuman.Tick();

        //Checks If The Human Is Dehydrated Or Not
        if(currentHuman.currentThirst != 0){
            //Checks If The Human Is Old Enough To Mate & Hasn't Mated In The Last 2 Days
            if(currentHuman.dateOfBirth <= tickCount / 4 - minMateTime && currentHuman.lastPregnancy <= tickCount / 4 - minMateTime){
                //Gets The Nearest Mate That Isn't It's Self
                int mateCheck = CheckForMates(currentHuman.currentPos.x, currentHuman.currentPos.y, currentHuman.id);

                //If There Is A Possible Mate Then Mate
                if (mateCheck != -1) {
                    Mate(currentHuman, humans.get(mateCheck));
                }
            }

            //Moves Them In A Random Direction
            currentHuman.Move();
        }
        else{
            //Kills The Human
            humans.remove(i);
        }
    }

    //Draws The Humans Onto The Screen
    for (int i = 0; i < humans.size(); i++) {
        fill(humans.get(i).tribeColour);
        rect(humans.get(i).currentPos.x, humans.get(i).currentPos.y, 2, 2);
    }

    tickCount++; // Updates The Tick Counter

    //Pause The Simulation For The Tick Time
    delay(PApplet.parseInt(tickTime * 1000)); //Converts From Seconds To Millis For The Func
}

//Creates A New Child Based Of The Mum & Dad
public void Mate(Human dad, Human mum){
    //The Child Object
    Human child = new Human(humans.size() + 1, dad.currentPos, dad.tribeColour, tickCount / 4, dad.maxThirst, mum.maxThirst);

    dad.GiveBirth(tickCount / 4);
    mum.GiveBirth(tickCount / 4);

    //Adds The Child To The List Of Humans
    humans.add(child);
}

//Checks Through All Humans To See If Ones Within 3 Pixels To Mate With
public int CheckForMates(int x, int y, int currentHumanID){
    //Mate Count Started At -1 To Be Used If No Mates;
    int mateCount = -1;

    //Loops Through All The Humans
    for (int i = 0; i < humans.size(); i++) {
        Human currentHuman = humans.get(i);

        //Checks The Current Human Isn't It's Self
        if(currentHuman.id != currentHumanID){
            //Sees How Far Way The Current Human Is
            if (dist(x,y, currentHuman.currentPos.x, currentHuman.currentPos.y) <= 2) {
                //If The Human Is Old Enough To Mate Sent Their ID Out
                if(currentHuman.dateOfBirth <= tickCount / 4 - minMateTime && currentHuman.lastPregnancy <= tickCount / 4 - minMateTime){
                    return i;
                }
            }
        }
    }

    //If No Mate Is Found Return -1
    return mateCount;
}

public boolean CheckValidPos(int xPos, int yPos){
    int checkCount = 0;

    //Checks No Other Humans Have The Same Space
    for (int i = 0; i < humans.size(); i++) {
        if(humans.get(i).currentPos.x == xPos && humans.get(i).currentPos.y == yPos){
            checkCount++;
        }
    }

    //Checks If It's A Valid Spawn Pixel
    if(validPixels[xPos][yPos] == false){
        checkCount++;
    }

    if (checkCount == 0) {
        return true;
    }else{
        return false;
    }
}
public class Coords{
    public int x;
    public int y;

    public Coords (int xCoord, int yCoord) {
        x = xCoord;
        y = yCoord;
    }
}
public class Human{
    //Objects ID
    int id;

    //Objects Start Position As A Coord Class
    Coords startPos;

    //The Objects Current Position
    Coords currentPos;

    //The Colour Of Its Tribe
    int  tribeColour;

    //Date Of Birth
    int dateOfBirth;

    //Water Value
    int currentThirst;

    //Max Water
    int maxThirst;

    //Pregnancy Date
    int lastPregnancy = 0;

    public Human (int _id, Coords _startPos, int tColour, int dob, int dadMaxThirst, int mumMaxThirst) {
        id = _id;
        startPos = _startPos;
        currentPos = _startPos;
        tribeColour = tColour;
        dateOfBirth = dob;

        //Randomly Picks One Of The Parents Max Thirsts
        maxThirst = PApplet.parseInt(random(2)) == 1? dadMaxThirst : mumMaxThirst;
        currentThirst = maxThirst;
    }

    //Moves The Human
    public void Move(){
        boolean newLoc = false;

        //Generates A New Random Location For A Human To Move To
        while (newLoc == false) {
            int orientation = PApplet.parseInt(random(4));
            int distance = PApplet.parseInt(random(4));

            int newX = 0;
            int newY = 0;

            //North
            if (orientation == 0) {
                newX = currentPos.x;
                newY = currentPos.y - distance;
            }
            //East
            if (orientation == 1) {
                newX = currentPos.x + distance;
                newY = currentPos.y;
            }
            //South
            if (orientation == 2) {
                newX = currentPos.x;
                newY = currentPos.y + distance;
            }
            //West
            if (orientation == 3) {
                newX = currentPos.x - distance;
                newY = currentPos.y;
            }

            if(CheckValidPos(newX, newY) == true){
                currentPos = new Coords(newX, newY);

                newLoc = true;
            }
        }
    }

    //Happens Once A Tick
    public void Tick(){
        currentThirst--;
    }

    public void GiveBirth(int currentDay){
        lastPregnancy = currentDay;
    }
}
  public void settings() {  size(512, 512); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TheNewWorldOrder_Sim" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
