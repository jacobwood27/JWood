@def title="Stridle"

\note{Objective}{Complete an end to end project that utilizes a current machine learning state-of-the-art tool.}

[Wordle](https://en.wikipedia.org/wiki/Wordle) and its [clones](https://en.wikipedia.org/wiki/Wordle#Adaptations_and_clones) seem to have taken the world by storm. My friends were talking about adapting the premise to the running world (drawing inspiration from [Poeltl](https://poeltl.dunk.town/)) and thus Stridle was born. The finished product can be played [here](https://jacobwood27.github.io/037_stridle/).

## Collecting Data
I decided to include the top 10 of all time for all the Olympic running events listed on [worldathletics.org](https://worldathletics.org/records/all-time-toplists/sprints/100-metres/outdoor/women/senior). Each athlete is assigned a unique athlete ID, so we can start by crawling through all the events and genders and pulling out the ID of the top 10.
```Python 
events = [
    'sprints/100-metres',
    'sprints/200-metres',
    'sprints/400-metres',
    'middle-long/800-metres',
    'middle-long/1500-metres',
    'middle-long/5000-metres',
    'middle-long/10000-metres',
    'road-running/marathon',
    'middle-long/3000-metres-steeplechase',
]

genders = [
    'women',
    'men'
]

competitors = []
for event in events:
    for gender in genders:
        
        url = "https://www.worldathletics.org/records/all-time-toplists/" + event + "/outdoor/" + gender + "/senior?regionType=world&timing=electronic&windReading=regular&page=1&bestResultsOnly=true&firstDay=1899-12-31&lastDay=2022-03-09"
        page = requests.get(url)
        soup = bs.BeautifulSoup(page.content, 'lxml')
        parsed_head  = soup.find_all('thead')[0] 
        head = [''.join(th.stripped_strings) for th in parsed_head.find_all("th")]
        parsed_table = soup.find_all('tbody')[0] 
        data = [[td.a['href'] if td.find('a') else 
                    ''.join(td.stripped_strings)
                    for td in row.find_all('td')]
                for row in parsed_table.find_all('tr')]

        df = pd.DataFrame(data, columns=head)

        for index, row in df.iterrows():
            if int(row['Rank']) > 10:
                break
            competitors.append(row['Competitor'].partition("=")[2])
competitors = list(set(competitors))
```
Each athlete has a page with their own personal bests ([example](https://worldathletics.org/athletes/united-states/florence-griffith-joyner-14359548)). To populate the Personal Bests table we need to navigate to that page and then click on "Personal Bests" about halfway down the page before reading in the html. We can use the Python library Selenium to do this. Then we can parse the html using BeautifulSoup as we did above. We'll plop everything into a pandas dataframe as we go.

```Python
events = [  "100 Metres",
            "200 Metres",
            "400 Metres",
            "800 Metres",
            "1500 Metres",
            "5000 Metres",
            "10,000 Metres",
            "Marathon",
            "3000 Metres Steeplechase"]

df = pd.DataFrame(columns=['Name', 'ID', 'Country', 'BirthYear'] + events)
for comp in competitors[65:]:
    
    browser_options = webdriver.FirefoxOptions()
    browser_options.add_argument('--headless')
    browser = webdriver.Firefox(options=browser_options)

    url  = "https://www.worldathletics.org/athletes/athlete=" + comp

    browser.get(url)
    time.sleep(4)
    butt = browser.find_element(By.XPATH, "//div[text()='Personal Bests']")
    browser.execute_script("arguments[0].click();", butt)
    time.sleep(1)
    squadPage=browser.page_source

    soup = bs.BeautifulSoup(squadPage, 'lxml')
    browser.close()

    dat = soup.find_all("table")
    data = [[td.a['href'] if td.find('a') else 
                        ''.join(td.stripped_strings)
                        for td in row.find_all('td')]
                    for row in dat[0].find_all('tr')]
    
    fn = soup.find("span", {"class": "profileBasicInfo_firstName__1Yj4q"}).decode_contents()
    ln = soup.find("span", {"class": "profileBasicInfo_lastName__10Vkd"}).decode_contents()

    dic = {}
    dic["ID"] = comp
    dic["Name"] = fn + " " + ln
    dic["Country"] = soup.find_all("div", {"class": "profileBasicInfo_statValue__IXJTW"})[0].decode_contents()
    dic["BirthYear"] = soup.find_all("div", {"class": "profileBasicInfo_statValue__IXJTW"})[1].decode_contents()[-4:]
    for d in data:
        if len(d) > 0:
            if d[0] in events:
                event = d[0]
                timer = ''.join(filter( lambda x: x in '0123456789.:', d[1]))
                dic[event] = timer
    df = pd.concat([df, pd.DataFrame.from_records([dic])])
```
We should end up with a table that looks like:
@@full-width
|              Name |       ID |       Country | BirthYear | 100 Metres | 200 Metres | 400 Metres | 800 Metres | 1500 Metres | 5000 Metres | 10,000 Metres | Marathon | 3000 Metres Steeplechase |
|------------------:|---------:|--------------:|----------:|-----------:|-----------:|-----------:|-----------:|------------:|------------:|--------------:|---------:|-------------------------:|
|     Doina MELINTE | 14352777 |       Romania |      1956 |        NaN |        NaN |        NaN |    1:55.05 |      3:56.7 |         NaN |           NaN |      NaN |                      NaN |
|     Mohamed KATIR | 14642046 |         Spain |      1998 |        NaN |        NaN |        NaN |    1:51.84 |     3:28.76 |    12:50.79 |           NaN |      NaN |                      NaN |
|      Norah JERUTO | 14479154 |    Kazakhstan |      1995 |        NaN |        NaN |        NaN |        NaN |      4:30.0 |    14:51.73 |           NaN |      NaN |                  8:53.65 |
|     Olga MINEYEVA | 14352215 |  Soviet Union |      1952 |        NaN |        NaN |       50.3 |    1:54.81 |         NaN |         NaN |           NaN |      NaN |                      NaN |
|    Eliud KIPCHOGE | 14208194 |         Kenya |      1984 |        NaN |        NaN |        NaN |        NaN |     3:33.20 |    12:46.53 |      26:49.02 |  2:01:39 |                      NaN |
|               ... |      ... |           ... |       ... |        ... |        ... |        ... |        ... |         ... |         ... |           ... |      ... |                      ... |
|       Fred KERLEY | 14504382 | United States |      1995 |       9.78 |      19.76 |      43.64 |        NaN |         NaN |         NaN |           NaN |      NaN |                      NaN |
| Christian COLEMAN | 14541956 | United States |      1996 |       9.76 |      19.85 |        NaN |        NaN |         NaN |         NaN |           NaN |      NaN |                      NaN |
|      Quincy WATTS | 14254412 | United States |      1970 |      10.17 |      20.50 |      43.50 |        NaN |         NaN |         NaN |           NaN |      NaN |                      NaN |
|   Salwa Eid NASER | 14643442 |       Bahrain |      1998 |      11.24 |      22.51 |      48.14 |        NaN |         NaN |         NaN |           NaN |      NaN |                      NaN |
|    Kerron STEWART | 14285938 |       Jamaica |      1984 |      10.75 |      21.99 |      51.83 |        NaN |         NaN |         NaN |           NaN |      NaN |                      NaN |
@@


## Making the Videos
Videos of each athlete were tracked down one at a time and pulled from YouTube using [youtube-dl](https://youtube-dl.org/). They were cropped (or scaled, for some of the older videos) down to 400x400 and ~4 seconds of runtime using ffmpeg and Kdenlive. 

Originally, I tried to use [MediaPipe Pose](https://google.github.io/mediapipe/solutions/pose) to segment out the runner. It works very well in some cases, but when it doesn't work it is difficult to iterate with. The process involved using OpenCV to pull frames out of the input video, processing them with the pose detector, and saving out the frame, the silhouette only, and the frame with a silhoutte covering the athlete.
```Python
dir = "14208478"
cap = cv2.VideoCapture(dir + '/input.mp4')

frame_width = int(cap.get(3))
frame_height = int(cap.get(4))

BG_COLOR = (255, 255, 255) 

frames = 0
with mp_pose.Pose(
    min_detection_confidence=0.2,
    min_tracking_confidence=0.9,
    model_complexity=2,
    enable_segmentation=True) as pose:
  
  while cap.isOpened():
    success, image = cap.read()
    if not success:
      break

    image.flags.writeable = False
    results = pose.process(image)
    if not results.pose_landmarks:
      continue
        
    frames += 1

    black_image = np.zeros((frame_height,frame_width,3), np.uint8)

    condition = np.stack((results.segmentation_mask,) * 3, axis=-1) > 0.5
    labeled_array, num_features = label(condition)
    
    bg_image = np.zeros((frame_height,frame_width,3), dtype=np.uint8)
    bg_image[:] = BG_COLOR
    
    hidden_image = np.where(labeled_array == 1, black_image, bg_image)
    
    hint_image = np.where(labeled_array == 1, black_image, image)
    
    cv2.imwrite(dir + "/hidden/" + f'{frames:03}' +".png",hidden_image)
    cv2.imwrite(dir + "/hint/"   + f'{frames:03}' +".png",hint_image)
    cv2.imwrite(dir + "/reveal/" + f'{frames:03}' +".png",image)

cap.release()
```

After quite a bit of searching around I found [MiVOS](https://hkchengrex.github.io/MiVOS/) listed as the state-of-the-art for an Interactive Video Object Segmentation on [paperswithcode](https://paperswithcode.com/sota/interactive-video-object-segmentation-on), which looked to do exactly what I wanted. It wasn't quite as quick and easy as the tutorials make it look, but overall it is a very effective tool after you get the hang of it.

MiVOS saves out masks and overlays for each frame of processed video:
@@im-100
\fig{/projects/stridle/overlay.png}
@@

Which can be cleaned up a bit and saved again as hidden, hint, and reveal frames:
```Python
vidcap = cv2.VideoCapture(inp_vid_file)
count = 0
while True:
    success,reveal_frame = vidcap.read()
    
    if not success:
        break
    
    reveal_frame = imutils.resize(reveal_frame, height=des_height)
    
    mask_frame = cv2.imread(mask_files[count])
    mask_frame = imutils.resize(mask_frame, height=des_height)
    mask_gray  = cv2.cvtColor(mask_frame, cv2.COLOR_BGR2GRAY)
    (T, mask_black) = cv2.threshold(mask_gray, 2, 255, cv2.THRESH_BINARY_INV)
    mask_fuzzy1 = cv2.GaussianBlur(mask_black, (5, 5), 0)
    mask_big = cv2.erode(mask_black, kernel, iterations=2)
    mask_fuzzy2 = cv2.GaussianBlur(mask_big, (5, 5), 0)
    
    hint_frame = reveal_frame.copy()
    hint_frame = cv2.bitwise_and(hint_frame, hint_frame, mask=mask_fuzzy2)

    cv2.imwrite(hidden_dir + "/" + f'{count:03}' +".png",mask_fuzzy1)
    cv2.imwrite(hint_dir   + "/" + f'{count:03}' +".png",hint_frame)
    cv2.imwrite(reveal_dir + "/" + f'{count:03}' +".png",reveal_frame)
    
    count += 1
```

Finally, these can be converted to web-friendly mp4s with ffmpeg:
```Python
cmd = "ffmpeg -y -i " + hidden_dir + "/%03d.png -c:v libx264 -vf format=yuv420p -movflags +faststart " + output_dir + "/hidden.mp4"
os.system(cmd)
cmd = "ffmpeg -y -i " + hint_dir   + "/%03d.png -c:v libx264 -vf format=yuv420p -movflags +faststart " + output_dir + "/hint.mp4"
os.system(cmd)
cmd = "ffmpeg -y -i " + reveal_dir + "/%03d.png -c:v libx264 -vf format=yuv420p -movflags +faststart " + output_dir + "/reveal.mp4"
os.system(cmd)
```

## Building Site
The [stridle.xyz](http://stridle.xyz/) website is likely a collection of HTML, CSS, and JavaScript worst practices as I am still just figuring out how things are supposed to play together. The parts that took me a while to figure out were the transitioning video and the selection menu.

### Hidden, Hint, and Reveal Video
I wanted the hint button to cause a seamless transition from the "hidden" video to the "hint" video at matching frames. Unfortunately this is a really hard thing apparently. Some JavaScript libraries are out there to help out, like [popcorn.js](https://github.com/menismu/popcorn-js), but I was trying to keep things as vanilla as possible. I eventually settled on playing all three videos stacked on top of each other but with an opacity filter that animates away to reveal the video beneath. This is probably not the ideal solution but the videos are small and it seems to run fine on the browsers I have tried.
```HTML
<div style="text-align:center; position:relative;">
    <video 
        src='vids/14347437/hidden.mp4' 
        type="video/mp4" 
        id="video_hidden" 
        playsinline loop muted autoplay
        style="position:absolute; top:0; left:50%; transform: translate(-50%, 0%); z-index:1">
    </video>
    <video 
        src='vids/14347437/hint.mp4' 
        type="video/mp4" 
        id="video_hint" 
        playsinline loop muted autoplay
        style="filter:opacity(0%);  position:absolute; top:0; left:50%; transform: translate(-50%, 0%); z-index:2">
    </video>
    <video 
        src='vids/14347437/reveal.mp4' 
        type="video/mp4" 
        id="video_reveal" 
        playsinline loop muted autoplay
        style="filter:opacity(0%);  position:absolute; top:0; left:50%; transform: translate(-50%, 0%); z-index:3">
    </video>
</div>
```
```HTML
<button 
    type="button" 
    onclick="document.getElementById('video_hint').classList.add('active-animation');">
    Hint
</button>
```
```CSS
.active-animation {
  animation-name: fadeIn ;
  animation-duration: 1s;
  animation-fill-mode: forwards;
  }

@keyframes fadeIn {
    0% {filter:opacity(0%);}
    100% {filter:opacity(100%);}
  }
```

### Searchable Selection List
I would recommend not trying to to roll your own select element. [Select2](https://select2.org/) has an easy drop-in that looks great!


## Ingredients
 - [Kdenlive](https://kdenlive.org/en/) - free and open source video editor
 - [ffmpeg](https://ffmpeg.org/) - cross-platform solution to record, convert and stream audio and video
 - [MiVOS-STCN](https://github.com/hkchengrex/MiVOS/tree/MiVOS-STCN) - interactive video object segmentation
 - [MediaPipe Pose](https://google.github.io/mediapipe/solutions/pose) - ML solution for high-fidelity body pose tracking
 - [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/) - Python library for pulling data out of HTML and XML files
 - [Selenium](https://www.selenium.dev/) - tool for automating interaction with web applications
 - [youtube-dl](https://youtube-dl.org/) - command-line program to download videos from YouTube
 - [OpenCV](https://opencv.org/) - open-source library with a ton of computer vision algorithms