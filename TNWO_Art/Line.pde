class Line{
    //Start Pos Of The Line
    PVector startPos;
    //End Pos Of The Line
    PVector endPos;

    //Lines Colour
    color colour;

    //Tick It Was Drawn
    int dob;

    public Line(PVector _startPos, PVector _endPos, color _colour, int _dob){
        startPos = _startPos;
        endPos = _endPos;
        colour = _colour;
        dob = _dob;
    }
}