# The New World Order

The New World Order Is A Ecosystem Simulation Made In Processing. The Data From The Simultion Can Then Power A Generative Art Sketch.

## The Art Sketch
<img src="https://cdn.discordapp.com/attachments/808992941326467122/833712248068374558/60Mins_Sim.PNG" alt="60 Mins Artwork" width="300"/>

The Art Sketch Draws A New Line From The Last Position To A New One Based Of The Data It Recives Via The OSC Message From The Simulation. 

The Modifers For The Art Sketch Are:

```java
//----------Modifiers----------
//Run Type
RunTypes runType = RunTypes.Forever;

//Multiplier For The Lines
int multiplier = 10;

//The Time Before Lines Dissapear
int shrinkVal = 50;
//-----------------------------
```
The Other Modifers Are:
 - The Type Of Art It's Running (Forever, Fade Out, Fade In, Shrink). These Can Also Be Changed During Runtime By Pressing:
   - `1` For Forever
   - `2` For Fade Out
   - `3` For Shrink
   - `4` For Fade In
 
 - The `multiplier` Which Effects How Long The Lines Are. This Can Be Changed During Runtime By Pressing:
   - `↑` To Increase It
   - `↓` To Decrease It

 - The `shirnkVal` Which Is How Long Lines Last Fore Before Either Fading Out Or Getting Removed. This Can Be Changed During Runtime By Pressing:
   - `→` To Increase It
   - `←` To Decrease It

Screenshots Of The Artwork Can Be Caputred By Pressing `P`, These Are Then Saved To The Sketches Location.

## The Simulation
<img src="https://cdn.discordapp.com/attachments/808992941326467122/828966000870686760/SimGif_06.04.21.gif" alt="Simulation Gif" width="300"/>

It Features Simulants That Are Displayed As 2x2 Squares Which Inhabit An Inputted Map. The Map Is Broken Down Into Key Areas Like Sand, Grass, Rock And Water.

- `Sand` Simulants Can Traverse | RGB (255, 221, 138)
- `Grass` Simulants Can Traverse | RGB (152, 255, 138)
- `Rock` Simulants Can't Traverse | RGB (181, 183, 181)
- `Water` Simulants Can't Traverse But Can Drink From | RGB (91, 208, 242)

The Humans Can Go 3 Days Without Water Which Their Main Goal Is To Find, And Can Reproduce Once They Are 2 Days Old (12 Ticks). After Reproduction They Must Wait 1/2 A Day (2 Ticks) Before They Can Mate Again, This Is Increased At Tick 100 To A One Day Wait To Stop Population Booms.

Modifers For The Simulation Are:

```java
//----------Modifiers----------
//Time Between Ticks In Seconds
float tickTime = 0.1f;

//Mutation Chance
int mutationChance = 10;

//Gold Digger Chance
int goldDiggerChance = 15;

//Explore Chance
int exploreChance = 25;
//-----------------------------
```

- `tickTime` Is The Time Between Ticks
- `muationChance` Is How Likely The Offsping Will Mutate Their Inhreited Traits
- `goldDiggerChance` Is How Likely When Mating That The Mate Has To Have Better Traits
- `exploreChance` Is How Likely The Simulant Will Explore If They Have Enough Water

**NOTE: With The Chances The Higher The Number The More Likely It Will Happen (100 Is A Guaranteed Occurrence)**

## Discord

Join The 4A50 Studios Discord To Stay Up To Date With Updates And Much More!

[![4A50 Studios Discord](https://discordapp.com/api/guilds/657328074748198912/widget.png?style=banner2)](https://discord.gg/kGbFbAUPWF)
