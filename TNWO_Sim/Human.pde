public class Human{
    //Objects ID
    int id;

    //Objects Start Position As A Coord Class
    Coords startPos;

    //The Objects Current Position
    Coords currentPos;

    //The Colour Of Its Tribe
    color  tribeColour;

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

    public Human (int _id, Coords _startPos, color tColour, int dob, int dadMaxThirst, int mumMaxThirst, int dadEyeSight, int mumEyeSight, int dadSpeed, int mumSpeed) {
        id = _id;
        startPos = _startPos;
        currentPos = _startPos;
        tribeColour = tColour;
        dateOfBirth = dob;

        //Randomly Picks One Of The Parents Traits
        maxThirst = int(random(2)) == 1? dadMaxThirst : mumMaxThirst;
        eyeSight = int(random(2)) == 1? dadEyeSight : mumEyeSight;
        speed = int(random(2)) == 1? dadSpeed : mumSpeed;

        //Has A Chance To Mutate Their Traits
        if (int(random(101)) <= mutationChance) {
            maxThirst += int(random(-1, 2));
            eyeSight += int(random(-3, 4));
            speed += int(random(-1, 3));
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
                int orientation = int(random(4));
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