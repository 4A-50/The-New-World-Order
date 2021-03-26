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

public class TNWO_Sim extends PApplet {




//OSC Info To Send Data To Art Sketch
OscP5 oscP5;
NetAddress myRemoteLocation;

//Used To Save Simulation Data To A JSON File
JSONObject  json;

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

//Water Pixels
boolean[][] waterPixels = new boolean[imgWidth][imgHeight];

//Spawn Images
PImage spawns;

//Humans
ArrayList<Human> humans = new ArrayList<Human>();

//All Humans Alive Or Dead Count
int allHumans = 0;

//Min Time Between Mates
int minMateTime = 2;

//Mutation Chance
int mutationChance = 10;

public void setup(){
    

    background(255, 255, 255);
    noStroke();

    //Starts oscP5, Listening For Incoming Messages At Port 12000
    oscP5 = new OscP5(this,12000);
    //IP Address Of Reciver And Port
    myRemoteLocation = new NetAddress("127.0.0.1",12000);

    //Starts Json Object
    json = new JSONObject();

    //Loads The Background Image File In Then Loads All Of It's Pixels
    outline = loadImage("outline.png");
    outline.loadPixels();

    //Loads The Spawn Image File In Then Loads All Of It's Pixels
    spawns = loadImage("spawns.png");
    spawns.loadPixels();

    //Loops Through Every Pixel And Checks If It Is A Valid Pixel From It's Colour
    for (int y = 0; y < imgWidth; y++) {
        for (int x = 0; x < imgHeight; x++) {
            int currentPixel = outline.pixels[x + y * width];

            if (currentPixel == sand || currentPixel == grass){
                validPixels[x][y] = true;
            }

            if(currentPixel == water){
                waterPixels[x][y] = true;
            }
        }
    }

    //Loops Through Every Pixel And Checks If It Is A Spawn Point
    for (int y = 0; y < imgWidth; y++) {
        for (int x = 0; x < imgHeight; x++) {
            int currentPixel = spawns.pixels[x + y * width];

            //If The Pixel Is Purple Spawn A Purple Tribesman
            if (currentPixel == purple){
                humans.add(new Human(allHumans += 1, new Coords(x, y), purple, 0, 13, 13, 15, 15, 3, 3)); //Adds The New Human To The Object List
            }

            //If The Pixel Is Red Spawn A Red Tribesman
            if (currentPixel == red){
                humans.add(new Human(allHumans += 1, new Coords(x, y), red, 0, 13, 13, 15, 15, 3, 3)); //Adds The New Human To The List
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
            //Looks Around For Water
            Coords nearestWater = Look(currentHuman);

            //Checks It Actualy Saw Water
            if(nearestWater.x != currentHuman.currentPos.x + currentHuman.eyeSight + 5 && nearestWater.y != currentHuman.currentPos.y + currentHuman.eyeSight + 5){
                //Checks The Humans Target Isn't Null
                if(currentHuman.target != null){
                    if(dist(currentHuman.currentPos.x, currentHuman.currentPos.x, nearestWater.x, nearestWater.y) < dist(currentHuman.currentPos.x, currentHuman.currentPos.x, currentHuman.target.x, currentHuman.target.y)){
                        currentHuman.target = nearestWater;
                    }
                }
                else{
                    currentHuman.target = nearestWater;
                }
            }

            //Checks It's Neighbouring Pixels For Water
            DrinkWater(currentHuman);

            //Checks If The Human Is Old Enough To Mate & Hasn't Mated In The Last 2 Days
            if(currentHuman.dateOfBirth <= tickCount / 4 - minMateTime && currentHuman.lastPregnancy <= tickCount - minMateTime){
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

    //Sends The Simulation Data To The Art Sketch Via OSC
    SendOSCMessage();
    //Saves The Simulation Data To JSON File
    SaveJson();

    tickCount++; // Updates The Tick Counter

    //Pause The Simulation For The Tick Time
    delay(PApplet.parseInt(tickTime * 1000)); //Converts From Seconds To Millis For The Func
}

//Searches The Humans Eyesight For The Nearest Water
public Coords Look(Human currentHuman){
    //List Of All Seeable Water Pixels
    ArrayList<Coords> nearWater = new ArrayList<Coords>();

    //Closest Water Pixel Initialised Further Out Then They Can See
    Coords nearestWaterPixel = new Coords(currentHuman.currentPos.x + currentHuman.eyeSight + 5, currentHuman.currentPos.y + currentHuman.eyeSight + 5);

    //Loops Through All The Pixels In The Humans Eyesight Range
    for (int y = currentHuman.currentPos.y - currentHuman.eyeSight; y <= currentHuman.currentPos.y + (currentHuman.eyeSight + 1); y++) {
        for (int x = currentHuman.currentPos.x - currentHuman.eyeSight; x <= currentHuman.currentPos.x + (currentHuman.eyeSight + 1); x++) {
            if(waterPixels[x][y] == true){
                nearWater.add(new Coords(x, y));
            }
        }
    }

    //Finds The Closest Water Pixel
    for (int i = 0; i < nearWater.size(); ++i) {
        if (dist(currentHuman.currentPos.x, currentHuman.currentPos.x, nearWater.get(i).x, nearWater.get(i).y) < 
            dist(currentHuman.currentPos.x, currentHuman.currentPos.x, nearestWaterPixel.x, nearestWaterPixel.y)) {
            nearestWaterPixel = nearWater.get(i);
        }
    }

    //Returns The Nearest Water Pixel Location
    return nearestWaterPixel;
}

//Searches The Neighbouring Pixels For A Water One To Drink From
public void DrinkWater(Human currentHuman){
    for (int y = currentHuman.currentPos.y - 1; y <= currentHuman.currentPos.y + 2; y++) {
        for (int x = currentHuman.currentPos.x - 1; x <= currentHuman.currentPos.x + 2; x++) {
            if(waterPixels[x][y] == true){
                currentHuman.Drink();
                return;
            }
        }
    }
}

//Creates A New Child Based Of The Mum & Dad
public void Mate(Human dad, Human mum){
    //The Child Object
    Human child = new Human(allHumans += 1, dad.currentPos, dad.tribeColour, tickCount / 4, dad.maxThirst, mum.maxThirst, dad.eyeSight, mum.eyeSight, dad.speed, mum.speed);

    dad.GiveBirth(tickCount);
    mum.GiveBirth(tickCount);

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
                if(currentHuman.dateOfBirth <= tickCount / 4 - minMateTime && currentHuman.lastPregnancy <= tickCount - minMateTime){
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

//Sends The Humans Array To The Art Sketch
public void SendOSCMessage(){
    //The Number Of Purple Humans
    int purpleHumans = 0;
    //Number Of Red Humans
    int redHumans = 0;

    //Highest Thirst Value
    int highestThirst = 0;
    //Adverage Thirst Value
    int advThirst = 0;

    //Higest Speed Value
    int highestSpeed = 0;
    //Adverage Speed Value
    int advSpeed = 0;

    //Gets The Info From Each Human
    for (int i = 0; i < humans.size(); ++i) {
        Human currentHuman = humans.get(i);

        //Gets The Humans Colour
        if (currentHuman.tribeColour == purple) {
            purpleHumans++;
        }
        else{
            redHumans++;
        }

        //Checks If It's The Highest Thirst
        if(currentHuman.maxThirst > highestThirst){
            highestThirst = currentHuman.maxThirst;
        }

        //Checks If It's The Highest Speed
        if(currentHuman.speed > highestSpeed){
            highestSpeed = currentHuman.speed;
        }

        //Adds The Current Max Thirst To The Adv Calcualtion
        advThirst += currentHuman.maxThirst;

        //Adds The Current Max Speed To The Adv Calcualtion
        advSpeed += currentHuman.speed;
    }

    //Divides All The Thirsts By The Amount
    advThirst = advThirst / humans.size();

    //Divides All The Speeds By The Amount
    advSpeed = advSpeed / humans.size();

    //Creates The Message
    OscMessage myMessage = new OscMessage("/Sim");
    myMessage.add(purpleHumans);
    myMessage.add(redHumans);
    myMessage.add(highestThirst);
    myMessage.add(advThirst);
    myMessage.add(highestSpeed);
    myMessage.add(advSpeed);

    //Sends The Message
    oscP5.send(myMessage, myRemoteLocation);
}

public void SaveJson(){
    //JSON Array Of All Humans
    JSONArray humanArray = new JSONArray();

    //Loops Through All The Humans
    for (int i = 0; i < humans.size(); ++i) {
        //New JSON Object
        JSONObject human = new JSONObject();

        //Current Human
        Human currentHuman = humans.get(i);
        
        //Sets The ID
        human.setInt("id", currentHuman.id);

        //Sets The Start Pos
        JSONArray startPos = new JSONArray();
        startPos.setInt(0, currentHuman.startPos.x);
        startPos.setInt(1, currentHuman.startPos.y);
        human.setJSONArray("start position", startPos);

        //Sets The Current Pos
        JSONArray currentPos = new JSONArray();
        currentPos.setInt(0, currentHuman.currentPos.x);
        currentPos.setInt(1, currentHuman.currentPos.y);
        human.setJSONArray("current position", currentPos);

        //Checks The Tribe Colour
        if(currentHuman.tribeColour == red){
            human.setString("tribe", "red");
        }
        else{
            human.setString("tribe", "purple");
        }

        //Date Of Birth
        human.setInt("dob", currentHuman.dateOfBirth);

        //Water Value
        human.setInt("thirst", currentHuman.currentThirst);

        //Max Water Value
        human.setInt("max thirst", currentHuman.maxThirst);

        //Last Pregnancy
        human.setInt("last mate", currentHuman.lastPregnancy);

        //Number Of Children
        human.setInt("children", currentHuman.childrenCount);

        //Eye Sight Distance
        human.setInt("eyesight", currentHuman.eyeSight);

        //Speed
        human.setInt("speed", currentHuman.speed);

        //Adds This Human To The Array
        humanArray.setJSONObject(i, human);
    }

    json.setInt("tick", tickCount);
    json.setInt("day", tickCount / 4);
    json.setJSONArray("humans", humanArray);

    saveJSONObject(json, "SimulationData/tick" + tickCount + ".json");
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

    //Number Of Children
    int childrenCount = 0;

    //Eye Sight Distance
    int eyeSight;

    //Target Move Position
    Coords target;

    //Speed
    int speed;

    public Human (int _id, Coords _startPos, int tColour, int dob, int dadMaxThirst, int mumMaxThirst, int dadEyeSight, int mumEyeSight, int dadSpeed, int mumSpeed) {
        id = _id;
        startPos = _startPos;
        currentPos = _startPos;
        tribeColour = tColour;
        dateOfBirth = dob;

        //Randomly Picks One Of The Parents Traits
        maxThirst = PApplet.parseInt(random(2)) == 1? dadMaxThirst : mumMaxThirst;
        eyeSight = PApplet.parseInt(random(2)) == 1? dadEyeSight : mumEyeSight;
        speed = PApplet.parseInt(random(2)) == 1? dadSpeed : mumSpeed;

        //Has A Chance To Mutate Their Traits
        if (PApplet.parseInt(random(101)) <= mutationChance) {
            maxThirst += PApplet.parseInt(random(-1, 2));
            eyeSight += PApplet.parseInt(random(-3, 4));
            speed += PApplet.parseInt(random(-1, 3));
        }

        //Sets The Current Thirst To Max First
        currentThirst = maxThirst;
    }

    //Moves The Human
    public void Move(){
        //If There Is A Water Pixel Target
        if(target != null){
            //Vector From Current Position To Target Position
            Coords targetVector = new Coords(target.x - currentPos.x, target.y - currentPos.y);

            //New Temp Coords
            Coords tempCoords = new Coords(0, 0);

            //Checks If There Is A X Axis Move If Not Does Y Axis
            //Needs Refining As It Is Biased To X Axis Move First And Isn't Quickest Route Just The Move Vector
            if (targetVector.x != 0) {
                if(speed <= target.x){
                    tempCoords.x = currentPos.x + speed;
                    tempCoords.y = currentPos.y;
                }
                else{
                    tempCoords.x = currentPos.x + (target.x - speed);
                    tempCoords.y = currentPos.y;
                }
            }
            else{
                if(speed <= target.y){
                    tempCoords.x = currentPos.x;
                    tempCoords.y = currentPos.y + speed;
                }
                else{
                    tempCoords.x = currentPos.x;
                    tempCoords.y = currentPos.y + (target.y - speed);
                }
            }

            //Checks If Its A Valid Postion
            if(CheckValidPos(tempCoords.x, tempCoords.y) == true){
                currentPos = new Coords(tempCoords.x, tempCoords.y);
            }
        }
        //If There Isn't A Target
        else{
            boolean newLoc = false;
            //Used To Stop The Movement If It Tries To Move To Many Times (Stops Crashes)
            int loopCount = 0;

            //Generates A New Random Location For A Human To Move To
            while (newLoc == false && loopCount <= 4) {
                int orientation = PApplet.parseInt(random(4));
                int distance = speed;

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

                loopCount++;
            }
        }
    }

    //Happens Once A Tick
    public void Tick(){
        currentThirst--;
    }

    public void GiveBirth(int currentDay){
        lastPregnancy = currentDay;
        childrenCount++;
    }

    public void Drink(){
        currentThirst = maxThirst;
    }
}
  public void settings() {  size(512, 512); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TNWO_Sim" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
