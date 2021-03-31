import oscP5.*;
import netP5.*;

//OSC Info To Send Data To Art Sketch
OscP5 oscP5;
NetAddress myRemoteLocation;

//Used To Save Simulation Data To A JSON File
JSONArray tickArray = new JSONArray();

//Time Between Ticks In Seconds
float tickTime = 0.1f;

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
color mixRP = color(199,21,133); //Red Violet (Mix Of The 2 Tribes)

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
                humans.add(new Human(allHumans += 1, new Coords(x, y), purple, 0, 13, 13, 15, 15, 3, 3)); //Adds The New Human To The Object List
            }

            //If The Pixel Is Red Spawn A Red Tribesman
            if (currentPixel == red){
                humans.add(new Human(allHumans += 1, new Coords(x, y), red, 0, 13, 13, 15, 15, 3, 3)); //Adds The New Human To The List
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
    //And Saves The Data To A JSON File
    SendOSCMessage();

    tickCount++; // Updates The Tick Counter

    //Pause The Simulation For The Tick Time
    delay(int(tickTime * 1000)); //Converts From Seconds To Millis For The Func
}

//Searches The Humans Eyesight For The Nearest Water
Coords Look(Human currentHuman){
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
void DrinkWater(Human currentHuman){
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
void Mate(Human dad, Human mum){
    //Checks There Is Space To Spawn The Child (Stops 39,000 Reds Spawing In Like 100px)
    if(CheckValidPos(dad.currentPos.x, dad.currentPos.y + 1) == true){

        color childTribeColour;

        if(dad.tribeColour != mum.tribeColour){
            childTribeColour = mixRP;
        }
        else{
            childTribeColour = dad.tribeColour;
        }

        //The Child Object
        Human child = new Human(allHumans += 1, new Coords(dad.currentPos.x, dad.currentPos.y + 1), childTribeColour, tickCount / 4, 
                                dad.maxThirst, mum.maxThirst, dad.eyeSight, mum.eyeSight, dad.speed, mum.speed);

        dad.GiveBirth(tickCount);
        mum.GiveBirth(tickCount);

        //Adds The Child To The List Of Humans
        humans.add(child);
    }
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
    //Number Of Mixed Humans
    int mixedHumans = 0;

    //Highest Thirst Value
    int highestThirst = 0;
    //Adverage Thirst Value
    int advThirst = 0;

    //Higest Speed Value
    int highestSpeed = 0;
    //Adverage Speed Value
    int advSpeed = 0;

    //Oldest Human
    int highestAge = 0;
    //Adverage Age
    int advAge = 0;

    //Gets The Info From Each Human
    for (int i = 0; i < humans.size(); ++i) {
        Human currentHuman = humans.get(i);

        //Gets The Humans Colour
        if (currentHuman.tribeColour == purple) {
            purpleHumans++;
        }
        if(currentHuman.tribeColour == red){
            redHumans++;
        }
        if (currentHuman.tribeColour == mixRP) {
            mixedHumans++;
        }

        //Checks If It's The Highest Thirst
        if(currentHuman.maxThirst > highestThirst){
            highestThirst = currentHuman.maxThirst;
        }

        //Checks If It's The Highest Speed
        if(currentHuman.speed > highestSpeed){
            highestSpeed = currentHuman.speed;
        }

        //Checks If It's The Oldest
        if ((tickCount / 4) - currentHuman.dateOfBirth > highestAge) {
            highestAge = (tickCount / 4) - currentHuman.dateOfBirth;
        }

        //Adds The Current Max Thirst To The Adv Calculation
        advThirst += currentHuman.maxThirst;

        //Adds The Current Max Speed To The Adv Calculation
        advSpeed += currentHuman.speed;

        //Adds The Current Age To The Adv Calculation
        advAge += (tickCount / 4) - currentHuman.dateOfBirth;
    }

    //Divides All The Thirsts By The Amount
    advThirst = advThirst / humans.size();

    //Divides All The Speeds By The Amount
    advSpeed = advSpeed / humans.size();

    //Divides ALl The Ages By The Amount
    advAge = advAge / humans.size();

    //Creates The Message
    OscMessage myMessage = new OscMessage("/Sim");
    myMessage.add(purpleHumans);
    myMessage.add(redHumans);
    myMessage.add(mixedHumans);
    myMessage.add(highestThirst);
    myMessage.add(advThirst);
    myMessage.add(highestSpeed);
    myMessage.add(advSpeed);
    myMessage.add(highestAge);
    myMessage.add(advAge);

    //Sends The Message
    oscP5.send(myMessage, myRemoteLocation);

    //Creates A New JSON Object For This Tick
    JSONObject tickInfo = new JSONObject();

    //Adds All The Info It Sends Over OSC
    tickInfo.setInt("tick", tickCount);
    tickInfo.setInt("purple humans", purpleHumans);
    tickInfo.setInt("red humans", redHumans);
    tickInfo.setInt("mixed humans", mixedHumans);
    tickInfo.setInt("highest thirst", highestThirst);
    tickInfo.setInt("adv thirst", advThirst);
    tickInfo.setInt("highest speed", highestSpeed);
    tickInfo.setInt("adv speed", advSpeed);
    tickInfo.setInt("oldest", highestAge);
    tickInfo.setInt("adv age", advAge);

    //Adds The JSONObject To The Tick Array
    tickArray.setJSONObject(tickCount, tickInfo);

    //Saves It To Disk
    saveJSONArray(tickArray, "SimulationData.json");
}