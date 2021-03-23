import oscP5.*;
import netP5.*;

//OSC Info To Send Data To Art Sketch
OscP5 oscP5;
NetAddress myRemoteLocation;

//Time Between Ticks In Seconds
float tickTime = 1f;

//The Current Tick Count
int tickCount = 0;

//Ground Colours
color sand = color(255, 221, 138); //Sand
color grass = color(152, 255, 138); //Grass
color water = color(91, 208, 242); //Water
color cliff = color(181, 183, 181); //Cliff

//Tribe Colours
color purple = color(136, 3, 252); //Purple
color red = color(255, 0, 0); //Red

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

void setup(){
    size(512, 512);

    background(255, 255, 255);
    noStroke();

    //Starts oscP5, Listening For Incoming Messages At Port 12000
    oscP5 = new OscP5(this,12000);
    //IP Address Of Reciver And Port
    myRemoteLocation = new NetAddress("127.0.0.1",12000);

    //Loads The Background Image File In Then Loads All Of It's Pixels
    outline = loadImage("outline.png");
    outline.loadPixels();

    //Loads The Spawn Image File In Then Loads All Of It's Pixels
    spawns = loadImage("spawns.png");
    spawns.loadPixels();

    //Loops Through Every Pixel And Checks If It Is A Valid Pixel From It's Colour
    for (int y = 0; y < imgWidth; y++) {
        for (int x = 0; x < imgHeight; x++) {
            color currentPixel = outline.pixels[x + y * width];

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
            color currentPixel = spawns.pixels[x + y * width];

            //If The Pixel Is Purple Spawn A Purple Tribesman
            if (currentPixel == purple){
                humans.add(new Human(allHumans += 1, new Coords(x, y), purple, 0, 13, 13)); //Adds The New Human To The Object List
            }

            //If The Pixel Is Red Spawn A Red Tribesman
            if (currentPixel == red){
                humans.add(new Human(allHumans += 1, new Coords(x, y), red, 0, 13, 13)); //Adds The New Human To The List
            }
        }
    }
}

void draw(){
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
            if(currentHuman.dateOfBirth <= tickCount / 4 - minMateTime && currentHuman.lastPregnancy <= tickCount - minMateTime){
                //Gets The Nearest Mate That Isn't It's Self
                int mateCheck = CheckForMates(currentHuman.currentPos.x, currentHuman.currentPos.y, currentHuman.id);

                //If There Is A Possible Mate Then Mate
                if (mateCheck != -1) {
                    Mate(currentHuman, humans.get(mateCheck));
                }
            }

            //Checks It's Neighbouring Pixels For Water
            DrinkWater(currentHuman);

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

    tickCount++; // Updates The Tick Counter

    //Pause The Simulation For The Tick Time
    delay(int(tickTime * 1000)); //Converts From Seconds To Millis For The Func
}

//Searches The Neighbouring Pixels For A Water One To Drink From
void DrinkWater(Human currentHuman){
    for (int y = currentHuman.currentPos.y - 1; y <= currentHuman.currentPos.y + 2; y++) {
        for (int x = currentHuman.currentPos.x - 1; x <= currentHuman.currentPos.x + 2; x++) {
            if(waterPixels[x][y] == true){
                currentHuman.Drink();
                break;
            }
        }
    }
}

//Creates A New Child Based Of The Mum & Dad
void Mate(Human dad, Human mum){
    //The Child Object
    Human child = new Human(allHumans += 1, dad.currentPos, dad.tribeColour, tickCount / 4, dad.maxThirst, mum.maxThirst);

    dad.GiveBirth(tickCount);
    mum.GiveBirth(tickCount);

    //Adds The Child To The List Of Humans
    humans.add(child);
}

//Checks Through All Humans To See If Ones Within 3 Pixels To Mate With
int CheckForMates(int x, int y, int currentHumanID){
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
void SendOSCMessage(){
    //The Number Of Purple Humans
    int purpleHumans = 0;

    //Number Of Red Humans
    int redHumans = 0;

    //Gets The Colour Of Each Human
    for (int i = 0; i < humans.size(); ++i) {
        if (humans.get(i).tribeColour == purple) {
            purpleHumans++;
        }
        else{
            redHumans++;
        }
    }

    OscMessage myMessage = new OscMessage("/test");
    myMessage.add(purpleHumans);
    myMessage.add(redHumans);

    //Sends The Message
    oscP5.send(myMessage, myRemoteLocation);
}