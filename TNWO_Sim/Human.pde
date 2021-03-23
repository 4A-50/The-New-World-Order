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

    public Human (int _id, Coords _startPos, color tColour, int dob, int dadMaxThirst, int mumMaxThirst) {
        id = _id;
        startPos = _startPos;
        currentPos = _startPos;
        tribeColour = tColour;
        dateOfBirth = dob;

        //Randomly Picks One Of The Parents Max Thirsts
        maxThirst = int(random(2)) == 1? dadMaxThirst : mumMaxThirst;

        //Has A Chance To Mutate Max Thirst
        if (int(random(101)) <= mutationChance) {
            maxThirst += int(random(-1, 2));
        }

        //Sets The Current Thirst To Max First
        currentThirst = maxThirst;
    }

    //Moves The Human
    public void Move(){
        boolean newLoc = false;
        //Used To Stop The Movement If It Tries To Move To Many Times (Stops Crashes)
        int loopCount = 0;

        //Generates A New Random Location For A Human To Move To
        while (newLoc == false && loopCount <= 16) {
            int orientation = int(random(4));
            int distance = int(random(4));

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

    //Happens Once A Tick
    public void Tick(){
        currentThirst--;
    }

    public void GiveBirth(int currentDay){
        lastPregnancy = currentDay;
    }

    public void Drink(){
        currentThirst = maxThirst;
    }
}