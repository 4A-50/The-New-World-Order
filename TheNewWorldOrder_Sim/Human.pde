public class Human{
    //Objects ID
    int id;

    //Objects Start Position As A Coord Class
    Coords startPos;

    //The Objects Current Position
    public Coords currentPos;

    //The Colour Of Its Tribe
    public color  tribeColour;

    //Date Of Birth
    int dateOfBirth;

    //Water Value
    public int currentThirst;

    //Max Water
    public int maxThirst;

    public Human (int _id, Coords _startPos, color tColour, int dob, int dadMaxThirst, int mumMaxThirst) {
        id = _id;
        startPos = _startPos;
        currentPos = _startPos;
        tribeColour = tColour;
        dateOfBirth = dob;

        //Randomly Picks One Of The Parents Max Thirsts
        maxThirst = int(random(2)) == 1? dadMaxThirst : mumMaxThirst;
        currentThirst = maxThirst;
    }

    //Moves The Human
    public void Move(){
        boolean newLoc = false;

        //Generates A New Random Location For A Human To Move To
        while (newLoc == false) {
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
        }
    }

    //Happens Once A Tick
    public void Tick(){
        currentThirst--;
    }
}