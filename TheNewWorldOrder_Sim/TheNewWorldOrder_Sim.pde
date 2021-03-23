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

//Spawn Images
PImage spawns;

//Humans
ArrayList<Human> humans = new ArrayList<Human>();

void setup(){
    size(512, 512);

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
            color currentPixel = outline.pixels[x + y * width];

            if (currentPixel == sand || currentPixel == grass){
                validPixels[x][y] = true;
            }
        }
    }

    //Loops Through Every Pixel And Checks If It Is A Spawn Point
    for (int x = 0; x < imgWidth; ++x) {
        for (int y = 0; y < imgHeight; ++y) {
            color currentPixel = spawns.pixels[x + y * width];

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
            int mateCheck = CheckForMates(currentHuman.currentPos.x, currentHuman.currentPos.y);

            if (mateCheck != -1 && currentHuman.dateOfBirth <= tickCount / 4 - 2) {
                Mate(currentHuman, humans.get(mateCheck));
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
    delay(int(tickTime * 1000)); //Converts From Seconds To Millis For The Func
}

void Mate(Human dad, Human mum){
    //humans.add(new Human(humans.size() + 1, dad.currentPos, dad.tribeColour, dad.maxThirst, mum.maxThirst));
    println("Time To Make A Baby With: " + dad.id + " & " + mum.id);
}

//Checks Through All Humans To See If Ones Within 3 Pixels To Mate With
int CheckForMates(int x, int y){
    int mateCount = -1;

    for (int i = 0; i < humans.size(); i++) {
        if (dist(x,y, humans.get(i).currentPos.x, humans.get(i).currentPos.y) <= 3) {
            mateCount = i;
            break;
        }
    }

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