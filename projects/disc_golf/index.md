@def title = "Disc Golf"

Disc golf is fun. Visualizing repeated activities with real data is fun. Pulling out your phone while playing disc golf to record every shot is not fun. 

This project attempts to solve that problem. [Here](https://jacobwood27.github.io/dg_dashboard/map/?round_id=2021-08-10-06-13-04_-_kit_carson) are the 
[results](https://jacobwood27.github.io/dg_dashboard/).


**Table of Contents**
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
 - Statistical analysis of previous play
 - Free 

We probably can't get to the perfect solution, but we can get close!

## Best Currently Available
[**UDisc**](https://udisc.com/)

UDisc is a fantastic application that is widely used for disc golf score keeping and tracking. It does almost everything described in the perfect solution, but comes up short in a few key places:
 - Interruptions - UDisc requires you to enter information on each hole (or after each shot)
    - Note: This can be done via Apple Watch if you have one, which minimizes the impact, but I do not have an Apple Watch
 - Disc thrown - UDisc does not support tracking specific discs
 - Course layout - The interface for specifying hole variations is difficult

## This Project
We should be able to create a near perfect solution if we can do three things:
1. Record the location and disc used for each throw with minimal interruption
2. Post-process the recorded data to provide an accurate depiction of the played round
3. Produce desired per-round and lifetime data visualizations

Fortunately, we can do these three things pretty well!

### Disc and Location Recording
The perfect interface here would be a quick tap on a disc that records the disc and the current location. 

#### NFC Tags
This is a perfect use case for passive [NFC](https://en.wikipedia.org/wiki/Near-field_communication) stickers, which can weigh less than 0.2 grams and can be applied to a disc without affecting the flight. 

\fig{/projects/disc_golf/discs_and_tags.png}

The NFC stickers are applied to the disc and can be covered with a vinyl sticker to protect them when they are inevitably thrown into the water.

\fig{/projects/disc_golf/stickers.png}

We need a way to read these NFC stickers, note the ID of the specific sticker, and record the ID and current location to a file. Fortunately, the iPhone has an NFC reader, GPS, and the Shortcuts app!

#### Shortcuts Integration

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

#### Location Recording
Ideally, the *Timestamp* shortcut would directly read and record the GPS location. This approach, however, forces the GPS fix to be lost and re-acquired at each read, which can take a few seconds. To remedy this we will instead keep a record of our position throughout the round using [Open GPX Tracker](http://www.merlos.org/iOS-Open-GPX-Tracker/). We can then correlate our timestamps with our position after the round. This is a far more robust solution.

#### Automation Trigger
The *Timestamp* shortcut is wrapped in an Automation that is triggered when a known NFC tag is detected. The automation will: 
1. Play a *tink* sound to let you know the disc has been read
2. Send the name of the triggering disc to *Timestamp* to be recorded
\fig{/projects/disc_golf/automation0.png}
\fig{/projects/disc_golf/automation1.png}

Unfortunately, the iPhone will only detect NFC when the screen is on. This means we need to do something to keep the screen alive during the entire round. The workaround solution for now is to run an application that keeps the screen going. I use a free minimal clock app that keeps the screen almost entirely black and then set the brightness to a minimum - this results in ~30% battery drain after 4 hours of playing. I start the app with the *Start DG Round* shortcut and then disable the entire screen with [Guided Access](https://support.apple.com/en-us/HT202612) so nothing gets pressed in my pocket.

#### Steps to Use 
 1. Use Open GPX Tracker to record your second-by-second location while you play
 2. Run *Start DG Round* when you are ready to begin a round
    - Leave the clock app open (and the screen disabled with Guided Access) to keep the screen alive
 3. Tap the disc you are about to throw to your phone before each shot and at each basket

It takes a bit of practice to tap in the right spot, but I get it on the first try most of the time after playing one or two rounds. I keep my phone upright in my back pocket and try to touch the bottom of the phone with the rim of the disc - that puts the sticker very close to the top of the phone where the NFC reader is located. It looks something like:

\fig{/projects/disc_golf/use_example.gif}


### Data Post-Processing
The data post processing was originally all done in [Julia](https://julialang.org/), which is my language of choice these days. You can find that code [here](https://github.com/jacobwood27/DiscgolfRecord). 

I ended up going down a large rabbit hole when trying to implement a browser interface to round and course editing. As a result, I learned and implemented the post-processing toolchain in [Go](https://golang.org/). This project was a great learning experience in Go, JavaScript, HTML, and general web infrastructure.


#### Input Data

After the round is complete we will have two files, a timestamp .csv file and a .gpx file recording our location throughout the round. 

The timestamp file should look like: 
```plaintext
2021-07-26T08:19:29-07:00,FLIPPER
2021-07-26T08:20:48-07:00,BUZZBUZZ
2021-07-26T08:21:53-07:00,JUDY
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

Those files are parsed and interpolated to produce a raw recording of the round that internally is represented rather simply:

| lat                | lon                | disc     |
|--------------------|--------------------|----------|
| 33.07931149057757  | -117.0586397398525 | FLIPPER  |
| 33.079317055310824 | -117.058647340845  | BUZZBUZZ |
| 33.07933495708912  | -117.0586549082484 | JUDY     |
| ...                |                    |          |

We now should have a full description of our round. We just need to place it in the context of a course.

#### Course Database
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
    - For each pin+teebox combination:
        - The par associated with playing specific teebox to specific pin

Additionally, future installments could contain geoJSON polygon information outlining fairways and OB (which can change based on the pin and tee locations). Maybe one day...

The course database is well suited for JSON due to its hierarchical nature. [Here](https://raw.githubusercontent.com/jacobwood27/dg_record_go/main/data/courses/kit_carson.json) is the implementation of the [course we commonly play at](https://udisc.com/courses/kit-carson-park-hIET):
```
{
{
	"id": "kit_carson",
	"name": "Kit Carson",
	"loc": [33.079323,-117.058426],
	"holes": [
		{
			"id": "1",
			"tees": [
				{
					"id": "reg",
					"loc": [33.079341451548174,-117.05858254892743]
				}
			],
			"pins": [
				{
					"id": "A",
					"loc": [33.07994748732632,-117.05780006680942]
				},
				{
					"id": "B",
					"loc": [33.08009547439126,-117.05760343347208]
				},
				{
					"id": "C",
					"loc": [33.07967526332277,-117.05775281076058]
				}
			],
			"pars": [
				{
					"tee": "reg",
					"pin": "A",
					"par": 3
				},
				{
					"tee": "reg",
					"pin": "B",
					"par": 3
				},
				{
					"tee": "reg",
					"pin": "C",
					"par": 3
				}
			]
		},
    .
    .
    .
```

The creation and editing of a course can all be done with a graphical interface provided by the [*make-course*](https://github.com/jacobwood27/dg_record_go/tree/main/cmd/make-course) and [*edit-course*](https://github.com/jacobwood27/dg_record_go/tree/main/cmd/edit-course) commands. Here is a screenshot of the editing interface:

\fig{/projects/disc_golf/edit_course.png}

#### Disc Database
We should also keep track of the parameters that define a disc. For ease of use we can maintain a database of "molds" that define all the common parameters for each type of disc, and a database of named user discs that record the values specific to the actual discs the user owns.

The molds database is populated with data from [alldiscs.com](https://alldiscs.com/). It is easily implemented as a .csv and looks like:

| id                     | brand           | mold      | type     | speed | glide | turn | fade |
|------------------------|-----------------|-----------|----------|-------|-------|------|------|
| LATITUDE\_64\_MISSILEN | Latitude 64     | Missilen  | Distance | 15    | 3     | -0.5 | 4.5  |
| LATITUDE\_64\_RAKETEN  | Latitude 64     | Raketen   | Distance | 15    | 4     | -2   | 3    |
| AXIOM_EXCITE           | Axiom Discs     | Excite    | Distance | 14.5  | 5.5   | -2   | 2    |
| AXIOM_TANTRUM          | Axiom Discs     | Tantrum   | Distance | 14.5  | 5     | -1.5 | 3    |
| MVP_DIMENSION          | MVP Disc Sports | Dimension | Distance | 14.5  | 5     | 0    | 3    |

The personal disc database is also implemented as a .csv file that references the *id* column of the molds database. The file referenced in the image column will be used as symbols denoting the use of that disc on the map visualization of the played round. 

| my_id             | disc_id            | plastic       | mass  | image                          |
|-------------------|--------------------|---------------|-------|--------------------------------|
| FLIPPER           | INNOVA\_SIDEWINDER | CHAMPION      | 175.2 | pink\_champion\_sidewinder.png |
| JUDY              | DYNAMIC\_JUDGE     | CLASSIC BLEND | 173.4 | pink\_judge.png                |
| BARELY\_KNOW\_HER | INNOVA\_DESTROYER  | STAR          | 175.3 | pink\_destroyer.png            |
| BUZZBUZZ          | DISCRAFT\_BUZZZ    | Z             | 178.6 | green\_buzzz.png               |

At this point we have defined all the relevant information to process our round. Let's get going!

#### Played Round Inference
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

 This algoithm is not perfect (maybe you hit a tree <20m from the teebox) but it provides a solid start to processing the round if you remember to tap before each shot.

We are not going to assume that the data collection or inference is perfect, however. To remedy this we will provide the user with a visualization of the round as it is interpreted.  The user will then be able to edit the data through a map GUI until the visualization accurately reflects the played round. 

#### make-round Command
The [*make-round*](https://github.com/jacobwood27/dg_record_go/tree/main/cmd/make-round) command wraps all the above functionality. It:
 - Reads the input files (disc timestamp and location recording)
 - Infers the details of the resulting round 
 - Provides the user with a GUI to add/delete/move stamps and rerun inference

Below is an example use of *make-round*. The rudimentary inference was not perfect, the disc was tapped too far away (>10m) from the 14th teebox when recording. After dragging the stamped location towards the teebox the inference is updated to correctly reflect the round as played. When the "Save" button is clicked the icons are updated in two ways: 
 - they are snapped to the locations of their inferred teeboxes/pins
 - the symbol designating the basket at the end of the hole changes from the tapped disc to a basket icon
\fig{/projects/disc_golf/make_round.gif}

The saved round is recorded in a tidy-ish .csv file with some round metadata in the header:
```plaintext
RoundID: 2021-07-26-08-19-29_-_kit_carson
CourseID: kit_carson
CourseName: Kit Carson
Notes: 

hole,tee,pin,par,lat,lon,disc
1,reg,A,3,33.079341,-117.058583,FLIPPER
1,reg,A,3,33.079980,-117.057914,JUDY
1,reg,A,3,33.079956,-117.057764,JUDY
1,reg,A,3,33.079947,-117.057800,BASKET
2,reg,A,3,33.079676,-117.057618,BUZZBUZZ
.
.
.
```
### Statistics Generation
#### make-stats Command
Finally, we need a way to put together the recorded rounds and generate some data visuals. The [*make-stats*](https://github.com/jacobwood27/dg_record_go/tree/main/cmd/make-stats) command reads in all the played rounds and generates csv files for further analysis at different levels of detail:
 - [all_throws.csv](https://github.com/jacobwood27/dg_stats/blob/main/stats/all_throws.csv)
 - [all_holes.csv](https://github.com/jacobwood27/dg_stats/blob/main/stats/all_holes.csv)
 - [all_rounds.csv](https://github.com/jacobwood27/dg_stats/blob/main/stats/all_rounds.csv)

#### Dashboard View
Additionally, *make-stats* breaks out a few interesting statistics into a [dash.json](https://github.com/jacobwood27/dg_stats/blob/main/stats/dash.json) file. That file is displayed on a [public dashboard](https://jacobwood27.github.io/dg_dashboard/) based on the [AdminLTE](https://adminlte.io/) bootstrap template. You can click the rows in the "Rounds" table to view them!

## Ingredients

### Hardware
 - [NFC tags](https://www.amazon.com/Cubenology-Original-Compatible-NFC-Enabled-Stickers/dp/B0899S7G37/) (\$4.19 for 12)
 - iPhone (not free)
    - 7 or newer (to read NFC)
    - iOS 12 or newer (to run Shortcuts)

### Software
 - [iOS Shortcuts](https://support.apple.com/guide/shortcuts/welcome/ios) (free) - to run recording automations
 - [Toolbox Pro](https://toolboxpro.app/) app on iOS (free) - to save global state when recording
 - [Open GPX Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker) app on iOS (free) - to record location
 - [Go](https://golang.org/) (free) - to do all post processing
    - [piecewiselinear v1.1.1](https://github.com/sgreben/piecewiselinear) (free) - to perform position/timestamp interpolation
    - [gpxgo v 1.1.2](https://github.com/tkrajina/gpxgo) (free) - to parse .gpx file
 - [mapbox](https://www.mapbox.com/) (free) - to render the maps in spatial visualizations
 - [AdminLTE](https://adminlte.io/) (free) - template used for dashboard

### Data
 - [alldiscs.com](https://alldiscs.com/) - disc database