@def title = "Birdie Brigade"

\note{Objective}{Dabble in simple graphic design and end up with a Christmas gift.}

One of the great joys in my life is playing golf with my father. Golf can be a great time, especially when you are playing well. Unfortunately, we don't play as often as we have in the past and this generally leads to a disappointing scorecard. Instead of focusing on the totaled up score, which can be spoiled with a single poor hole, we now chase birdies. We count a course as "checked off" if at least one of our group members birdies a single hole. The goal is to check off all the public golf courses in San Diego. Naturally, this feat should be tracked by a piece of wall art. This project describes the design and build of the "Birdie Brigade" map gifted to my father as a Christmas present in 2019.

@@im-100
\fig{/projects/birdie_brigade/all_courses_small-fs8.png}
@@

## Courses
The courses selected were all 18 hole public golf courses listed on the [San Diego County Website](https://www.sandiego.org/explore/things-to-do/sports/golf/san-diego-golf-courses.aspx). The addresses were pulled directly from Google Maps.

| **Course Name**                               | **Address**                                      |
|-----------------------------------------------|--------------------------------------------------|
| Coronado Municipal Golf Course                | 2000 Visalia Row, Coronado, CA 92118             |
| Balboa Park Golf Course                       | 2600 Golf Course Dr, San Diego, CA 92102         |
| Carlton Oaks Golf Course                      | 9200 Inwood Dr, Santee, CA 92071                 |
| Steele Canyon Golf Club                       | 3199 Stonefield Dr, Jamul, CA 91935              |
| Sycuan Casino and Golf Resort                 | 3007 Dehesa Rd, El Cajon, CA 92019               |
| Barona Creek Golf Club                        | 1932 Wildcat Canyon Rd, Lakeside, CA 92040       |
| Borrego Springs Resort Golf Club & Spa        | 1112 Tilting T Dr, Borrego Springs, CA 92004     |
| Cottonwood - Rancho San Diego                 | 3121 Willow Glen Dr, El Cajon, CA 92019          |
| Mission Trails Golf Course                    | 7380 Golfcrest Pl, San Diego, CA 92119           |
| Rams Hill Golf Club                           | 1881 Rams Hill Rd, Borrego Springs, CA 92004     |
| Warner Springs Ranch                          | 31652 Hwy 79, Warner Springs, California 92086   |
| Torrey Pines Golf Course                      | 11480 N Torrey Pines Rd, La Jolla, CA 92037      |
| The Crossings at Carlsbad                     | 5800 The Crossings Dr, Carlsbad, CA 92008        |
| The Grand Golf Club at Fairmont Grand Del Mar | 5200 Grand Del Mar Way, San Diego, CA 92130      |
| Aviara Golf Club & Resort                     | 7447 Batiquitos Drive, Carlsbad. CA 92011        |
| Oceanside Golf Course                         | 825 Douglas Dr, Oceanside, CA 92058              |
| Maderas Golf Club                             | 17750 Old Coach Rd, Poway, CA 92064              |
| Rancho Bernardo Inn Golf Resort               | 17550 Bernardo Oaks Dr, San Diego, CA 92128      |
| Boulder Oaks Golf Club                        | 10333 Meadow Glen Way E, Escondido, CA 92026     |
| Carmel Mountain Ranch Golf Course             | 14050 Carmel Ridge Rd, San Diego, CA 92128       |
| Castle Creek Country Club                     | 8797 Circle R Dr, Escondido, CA 92026            |
| Eagle Crest Golf Course                       | 2492 Old Ranch Rd, Escondido, CA 92027           |
| Mt. Woodson Golf Course                       | 16422 N Woodson Dr, Ramona, CA 92065             |
| Pala Mesa Golf Resort                         | 2001 Old Hwy 395, Fallbrook, CA 92028            |
| San Vicente Golf                              | 24157 San Vicente Rd, Ramona, CA 92065           |
| The Vineyard Golf Course                      | 925 San Pasqual Rd, Escondido, CA 92025          |
| Twin Oaks Golf Course                         | 1425 N Twin Oaks Valley Rd, San Marcos, CA 92069 |
| Bonita Golf Club                              | 5540 Sweetwater Rd, Bonita, CA 91902             |
| Chula Vista Municipal Golf Course             | 4475 Bonita Rd, Bonita, CA 91902                 |
| Oaks North Golf Course                        | 12602 Oaks N Dr, San Diego, CA 92128             |

Here they are plotted on a [map](https://www.easymapmaker.com/map/7106b86e4a5ea165b3bdf0e471dc85fa):
~~~
<iframe width="100%" height="600" frameborder="0" scrolling="no" marginheight="0" marginwidth="0"
    src="https://www.easymapmaker.com/map/7106b86e4a5ea165b3bdf0e471dc85fa">
</iframe>
~~~
We wish things were a little more evenly spread, but some creative gerrymandering never hurt anyone.

## Making the Map
### Gerrymandering
Our goal is to split the county up into mutually exclusive and collectively exhaustive puzzle pieces, each one containing a single golf course. Ideally the pieces would not be too weirdly shaped or disproportionally sized (spoiler: not going to happen).

The county border is from the [US Census Cartographic Database](https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.2019.html) and the haphazard slicing is all done in [Gimp](https://www.gimp.org/).
@@im-100
\fig{/projects/birdie_brigade/gerrymandered.png}
@@

We then threshold out just the borders and trace the path as a vector image in Inkscape for some nice clean lines:
@@im-100
\fig{/projects/birdie_brigade/skeleton_big2-fs8.png}
@@

There are some big puzzle pieces in there. For fun, let's see how poorly we did. We can segment the image and then count the number of pixels for each color as a way to measure the relative land area of each piece:
@@im-100
\fig{/projects/birdie_brigade/piece_area_bar.png}
@@

That does not look great, but context is everything. We can use the [Gini Coefficient](https://en.wikipedia.org/wiki/Gini_coefficient), frequently used to express the wealth inequality within a population, to get a sense of how unequal our area split is.  
```
function gini(Y) #https://en.wikipedia.org/wiki/Gini_coefficient
    n = length(Y)
    2 * sum([i * y for (i,y) in enumerate(Y)]) / n / sum(Y) - (n + 1)/n
end

#Data from pixel count
Y =  [  652035, 85537, 68347, 132239, 148672, 
        144864, 58396, 87449, 146416, 109556, 
        175960, 95408, 22489, 48258, 34507, 
        57059, 129303, 61193, 164995, 336881, 
        350866, 63771, 50841, 852818, 609101, 
        507403, 296592, 543643, 726209, 2298115]
        
gini(sort!(Y))
```
```
0.5847794379088993
```

A suitable comparison is probably the distribution of county area within state lines. The [US Census website](https://www.census.gov/library/publications/2011/compendia/usa-counties-2011.html#LND) makes this data (as of 2011) easily available and encoded in column LND110210D of [this table](https://www2.census.gov/library/publications/2011/compendia/usa-counties/excel/LND01.xls) (1.5MB download). 

```
using CSV
using DataFrames

# keep the numeric code column as a string so we don't wipe leading zeros
df = CSV.read("projects/birdie_brigade/LND01.csv", DataFrame, types=Dict(2=>String))

# Get all the state names
states = Dict()
for row in eachrow(df)
    #states end with 000, but we don't want United States or DC
    if row.STCOU[3:5]=="000" && row.STCOU[1:2]!="00" && row.STCOU[1:2]!="11"
        states[row.STCOU[1:2]] = row.Areaname
    end
end

gini_df = DataFrame(state = String[], gini = Float64[])
for (k,v) in states
    Y = [row.LND110210D for row in eachrow(df) if row.STCOU[1:2]==k && row.STCOU[3:5]!="000"]
    push!(gini_df, [v, gini(sort(Y))])
end
sort!(gini_df,:gini)
```
```
50×2 DataFrame
 Row │ state           gini      
     │ String          Float64   
─────┼───────────────────────────
   1 │ ARKANSAS        0.0995015
   2 │ OHIO            0.101162
   3 │ IOWA            0.110149
   4 │ INDIANA         0.130984
   5 │ MISSISSIPPI     0.136827
   6 │ ALABAMA         0.143195
   7 │ MISSOURI        0.146193
   8 │ KANSAS          0.152884
   9 │ CONNECTICUT     0.153839
  10 │ VERMONT         0.156479
  11 │ DELAWARE        0.174417
  12 │ SOUTH CAROLINA  0.178281
  .  │       .             .
  40 │ MASSACHUSETTS   0.356184
  41 │ RHODE ISLAND    0.385959
  42 │ UTAH            0.400773
  43 │ IDAHO           0.413553
  44 │ NEVADA          0.427948
  45 │ VIRGINIA        0.439749
  46 │ OREGON          0.447592
  47 │ MAINE           0.46536
  48 │ CALIFORNIA      0.485764
  49 │ HAWAII          0.53521
  50 │ ALASKA          0.618291
```
Our gerrymandering, with a Gini of 0.584, would come in at 50th, just barely eking ahead of Alaska at 0.618. This is probably good news for US counties, but not great news for us. Fortunately, it does not matter at all.

### Course Labels
I wanted to place the course names inside each puzzle piece in a style similar to a [word cloud](https://en.wikipedia.org/wiki/Tag_cloud). As a novice Gimp user I was able to take some inspiration from the process shared by Roosevelt Graphics [here](https://rooseveltgraphicarts.wordpress.com/tutorials/buffalo-typography-tutorial/). I don't have Illustrator so this was all completed in Gimp. 

For each course I manipulated the words (and sometimes the individual letters, as in the case of Oceanside) separately. The Unified Transform tool was used extensively. The end result looks like:
@@im-100
\fig{/projects/birdie_brigade/all_courses_small-fs8.png}
@@

### Puzzle Piece Coloring
Currently, the puzzle pieces that fill in the map are just black. I haven't decided how to color them. Here are my 3 thoughts:

- Part of a larger image - the pieces themselves, when all placed, will form a picture
@@im-100
\fig{/projects/birdie_brigade/puzzle_pic-fs8.png}
@@

- Course specific picture - each individual piece has a picture of that course
@@im-100
\fig{/projects/birdie_brigade/courses_pics_frames-fs8.png}
@@

- Colored course label - the pieces are just colored versions of the backdrop
@@im-100
\fig{/projects/birdie_brigade/courses_colorchange-fs8.png}
@@

## Building
### Printing
The end goal I was hoping for was a backdrop displaying the course names, a raised border surrounding each puzzle piece, and pieces themselves to fit snugly in the frame.

To begin, I used the "Trace Bitmap" feature in Inkscape to trace the entire graphic and convert in to a vector representation.

The backdrop was easy. That is just the course names (minus the frame lines, in case I wasn't able to line the frame up perfectly I didn't want any lines poking out). The canvas was sized to 16x20, exported to a .png at 600 dpi, and sent to Costco Photo Center for printing.

3D printing was an option, but laser cut acrylic seemed to be the perfect match for the border and puzzle pieces. If I started with a blank sheet and then made cuts only around the border of each piece the end result would be a perfect frame and the pieces, guaranteed to fit snugly with only a laser's width of wiggle room, would come along for free. [Ponkoko.com](https://www.ponoko.com/) offers custom precision laser cutting on a variety of materials for impressive prices. They provide a template and instructions for preparation in Inkscape.
@@im-100
\fig{/projects/birdie_brigade/ponoko_cut-fs8.png}
@@

### Assembly
This is the scary part. The frame needed to be attached to the backdrop. I used a glue stick and some helping hands to line things up and it turned out pretty well! The end result was framed and wrapped up with a bag of the puzzle pieces. We have some work to do to fill in the map!

@@im-100
\fig{/projects/birdie_brigade/completed.jpg}
@@



## Ingredients
- [San Diego County Website](https://www.sandiego.org/explore/things-to-do/sports/golf/san-diego-golf-courses.aspx) - golf course identification
- [easymapmaker.com](https://www.easymapmaker.com/) - easy online map maker and kml generator
- [US Census Cartographic Database](https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.2019.html) - county border definition
- [Gimp](https://www.gimp.org/) - free and powerful image editor
- [Inkscape](https://inkscape.org/) - free vector graphics editor
- [Ponkoko.com](https://www.ponoko.com/) - custom laser cutting and engraving