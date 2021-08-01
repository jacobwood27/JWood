@def title = "Disc Golf"

Disc golf is fun. Visualizing repeated activities with real data is fun. Pulling out your phone while playing disc golf to record every shot is not fun. 

This project attempts to solve that problem.

\toc

## Perfect Solution
My perfect answer to this problem has these qualities:
 - No interruption while playing
 - Records every shot and what disc was thrown
 - Records the course layout that was played
    - Holes
    - Teeboxes
    - Pin locations
 - Round results shown on a map
 - Round results shown on a scorecard that can be shared
 - Ability to overlay past rounds on the map
 - Statistical analysis of previous play
 - Free 

We probably can't get to the perfect solution, but we can get close!

## Currently Available Solution
[**UDisc**](https://udisc.com/)

UDisc is a fantastic application that is widely used for disc golf scorekeeping and tracking. It does almost everything described in the perfect solution, but comes up short in a few key places:
 - Interruptions - UDisc requires you to enter information on each hole (or after each shot)
    - Note: This can be done via Apple Watch if you have one, which minimizes the impact, but I do not have an Apple Watch
 - Disc thrown - UDisc does not support tracking specific discs
 - Course layout - The interface for specifying hole variations is difficult

## Solution
We should be able to create a near perfect solution if we can do two things:
1. Record the location and disc used for each throw with minimal interruption
2. Post-process the recorded data to provide desired per-round and lifetime visualizations

Fortunately, we can do these two things pretty well!

### Disc and Location Recording
The perfect interface here would be a quick tap on a disc that records the disc and the current location. This is a perfect use case for passive [NFC](https://en.wikipedia.org/wiki/Near-field_communication) stickers, which can weigh less than 0.2 grams and can be applied to a disc without affecting the flight. 

\fig{/projects/disc_golf/discs_and_tags.png}

The NFC stickers are applied to the disc and covered with a vinyl sticker to protect them when they are inevitably thrown into the water.

We need a way to read these NFC stickers, note the ID of the specific sticker, and record the ID and current location to a file. Fortunately, the iPhone has an NFC reader, GPS, and the Shortcuts app!

We will start each round by running a shortcut, *Start DG Round*, that:
1. Gets the current date
2. Makes a filename out of the current date
3. Saves the filename into a global variable (available from the free Toolbox Pro app) that other shortcuts will be able to read
\fig{/projects/disc_golf/start_dg_round.png}


We will make use of a *Timestamp* shortcut to:
1. Generate a timestamp 
2. Collect an input string (the disc's ID)
3. Append both to a newline in the .csv file specified by *Start DG Round* 
\fig{/projects/disc_golf/timestamp_shortcut.png}

Ideally, the *Timestamp* shortcut would directly read and record the GPS location. This approach, however, forces the GPS fix to be lost and re-acquired at each read, which can take a few seconds. To remedy this we will instead keep a record of our position throughout the round using [Open GPX Tracker](http://www.merlos.org/iOS-Open-GPX-Tracker/). We can then correlate our timestamps with our position after the round. This is a far more robust solution, but it does take quite a bit of battery life. Make sure to charge your phone before playing!

The *Timestamp* shortcut is wrapped in an Automation that is triggered when a known NFC tag is detected. The automation will: 
1. Play a *tink* sound to let you know the disc has been read
2. Send the name of the triggering disc to *Timestamp* to be recorded
\fig{/projects/disc_golf/buzzyboy_automation0.png}
\fig{/projects/disc_golf/buzzyboy_automation1.png}

Unfortunately, the iPhone will only detect NFC when the screen is on. This means we need to do something to keep the screen alive during the entire round. The workaround solution for now is to run an application that keeps the screen going. Open GPX Tracker is a good option since it will be running and recording position anyways. I start the app, hit "Start Tracking", and then disable the entire screen with [Guided Access](https://support.apple.com/en-us/HT202612) so nothing gets pressed in my pocket.

**To recap**: 
 - Run *Start DG Round* when you get to the course
 - Use Open GPX Tracker to track your location while you play
    - Leave the app open (and the screen disabled with Guided Access) to keep the screen alive
 - Tap the disc you are about to throw to your phone before each shot and at each basket

It takes a bit of practice to tap in the right spot, but I get it very quickly most of the time after playing one or two rounds. I keep my phone upright in my back pocket and try to touch the bottom of the phone with the rim of the disc - that puts the sticker very close to the top of the phone where the NFC reader is located. It looks something like:

\fig{/projects/disc_golf/use_example.gif}


### Data Post-Processing
The data post processing is all done in [Julia](https://julialang.org/), which is my language of choice these days.

After the round is complete we will have two files, a timestamp .csv file and a .gpx file recording our location throughout the round. 

The timestamp file should look like: 
```plaintext
2021-07-26T08:20:48-07:00,BUZZZY-BOY
2021-07-26T08:21:53-07:00,JUDGEY-JOY
2021-07-26T08:22:17-07:00,JUDGEY-JOY
.
.
.
```

And the gpx file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" version="1.1" creator="Open GPX Tracker for iOS">
	<trk>
		<trkseg>
			<trkpt lat="33.07901132857842" lon="-117.05936818536237">
				<ele>119.92342997459416</ele>
				<time>2021-07-26T15:11:49Z</time>
			</trkpt>
			<trkpt lat="33.079017415810696" lon="-117.05934814846991">
				<ele>119.92947497817526</ele>
				<time>2021-07-26T15:11:50Z</time>
			</trkpt>
            .
            .
            .
```

Those files are interpolated with the *interpolate_gpx()* function to produce a *round_raw.csv* file:
```bash
woojac@voyager:~/proj/021_disc_golf_record/rounds$ ./interpolate_gpx 20210726_kitcarson_1.csv 20210726_kitcarson_1.gpx 
woojac@voyager:~/proj/021_disc_golf_record/rounds$ cat round_raw.csv 
lat,lon,disc
33.07931149057757,-117.0586397398525,BUZZZY-BOY
33.079317055310824,-117.058647340845,JUDGEY-JOY
33.07933495708912,-117.0586549082484,JUDGEY-JOY
.
.
.
```

We now should have a full description of our round. We just need to place it in the context of a course.

In order to track consistent stats we would like to be able to determine the exact course that was played. This is best achieved by mapping the marked locations to a course database. The course database should contain the following information:
 - Course ID - unique identifier
 - Course name - commonly used name for display
 - Course location - lat,lon of the parking lot or first tee
 - For each hole:
    - Hole name - probably 1,2,3 (but could be NORTH1, SOUTH2, etc for courses with different nines)
    - For each pin:
        - Pin name - probably A,B,C or 1,2,3
        - Pin location - lat,lon of that possible pin location
    - For each teebox:
        - Teebox name - probably A,B,C or reg,pro
        - Teebox location - ideally lat,lon of front center of teebox
        - For each pin:
            - The par associated with playing this teebox to this pin

Additionally, future installments could contain polygon information outlining fairways and OB (which can change based on the pin and tee locations). Maybe one day...

The database is well suited for JSON due to its hierarchical nature. I have implemented the [course](https://udisc.com/courses/kit-carson-park-hIET) we commonly play at. It looks like:
```
{
  "id": "kit_carson",
  "name": "Kit Carson",
  "loc": [33.079323,-117.058426],
  "holes": {
    "1": {
      "tees": {
        "reg": [33.079323,-117.058426]
      },
      "pins": {
        "A": [33.079936,-117.05779],
        "B": [33.080083,-117.05760],
        "C": [33.079653,-117.05775]
      },
      "pars": {
        "reg": {
          "A": 3,
          "B": 3,
          "C": 3
        }
      }
    },
    .
    .
    .
```

We should also keep track of the parameters that define a disc. For ease of use we can maintain a database of "molds" that define all the common parameters for each type of disc, and a database of named user discs that record the values specific to the actual discs the user owns.

The molds database is populated with data from [alldiscs.com](https://alldiscs.com/). It is easily implemented as a .csv and looks like:

| id                     | brand           | mold      | type     | speed | glide | turn | fade |
|------------------------|-----------------|-----------|----------|-------|-------|------|------|
| LATITUDE\_64\_MISSILEN | Latitude 64     | Missilen  | Distance | 15    | 3     | -0.5 | 4.5  |
| LATITUDE\_64\_RAKETEN  | Latitude 64     | Raketen   | Distance | 15    | 4     | -2   | 3    |
| AXIOM_EXCITE           | Axiom Discs     | Excite    | Distance | 14.5  | 5.5   | -2   | 2    |
| AXIOM_TANTRUM          | Axiom Discs     | Tantrum   | Distance | 14.5  | 5     | -1.5 | 3    |
| MVP_DIMENSION          | MVP Disc Sports | Dimension | Distance | 14.5  | 5     | 0    | 3    |

The personal disc database is also implemented as a .csv file that references the *id* column of the molds database. An image column is included to denote the specific discs on the map. The user must provide their own images (recommended size of 256x256).

|my_id     |disc_id          |plastic      |weight|image                         |
|----------|-----------------|-------------|------|------------------------------|
|BIG-PINK  |INNOVA_SIDEWINDER|CHAMPION     |175.2 |pink\_champion\_sidewinder.png|
|JUDGEY-JOY|DYNAMIC_JUDGE    |CLASSIC BLEND|173.4 |pink_judge.png                |
|DESTROYAH |INNOVA_DESTROYER |STAR         |175.3 |pink_destroyer.png            |
|BUZZZY-BOY|DISCRAFT_BUZZZ   |Z            |178.6 |green_buzzz.png               |

At this point we have defined all the relevant information to process our round. Let's get going!

The main function the software should provide is inference. We want to take care of all the heavy lifting with the pre-defined databases so the per-round data collection can be as easy and seamless as possible. There are a few things we need to infer about the round:
 - Which course was played
 - Which holes were played, and in what order
 - Which tee was played on each hole
 - Which pin was played on each hole
 - Which shots belong to which hole

With that all determined we will be able to appropriately score the round and provide accurate visualizations.

Most of these are straightforward. The played course will just be the nearest course to the first marked location. The hole that was played will be the hole that owns the inferred teebox. The pin/tee that was played on each hole will be the nearest pin/tee to the marked location. The only difficult problem will be to determine which taps mark a completed hole and then a tee on the next hole. We need to be careful because we may be putting from another basket location or from near the teebox on the next hole. We also may not be playing the holes in order, so we can't assume that after hole 3 we should look at the teebox for hole 4. As of now, the best algorithm I could think of uses the following criteria to determine if a tap is marking the end of a hole:
 - The tap is within 10m of a basket on the currently played hole, indicating a pin location
 - The next tap is within 10m of a teebox, indicating we are on to the next hole
 - The tap after that is >20m from the teebox, indicating we have thrown a drive

We are not going to assume that the data collection or inference is perfect, however. To remedy this we will provide the user with a *guess and check* visualization of the round as it is interpreted.  The user will then be able to hand edit the *round_raw.csv* file until the visualization accurately reflects the played round. Perhaps a future implementation will feature a closed-loop GUI to assist with this process, but in the meantime the visualization will provide all the information needed to quickly verify the round was recorded as intended. 

[Here](guess_n_check_viz_broken) is a sample of the visualization before it is cleaned up. Note that we forgot to tap at the teebox of Hole 7, and, as a result, everything after that hole is attributed to a very poor Hole 6. After inserting a fix we have a visualization that accurately reflects the round that was played, which can be seen be seen [here](guess_n_check_viz_fixed).


Results dashboard is [here](https://jacobwood27.github.io/dg_dashboard/).
