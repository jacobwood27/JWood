@def title = "Photobooth"

My wife and I planned on having a small photobooth at our wedding in case people wanted to print and keep a small memento. A week before the wedding I had a few ideas pop up that I thought would be fun to incorporate into the photobooth. Unfortunately you end up kind of busy doing a bunch of other things the week of your wedding, so I didn't get to finish this photobooth in time. To round out the learning process I did complete it after the wedding - this project documents the build.

## Existing Solutions
### Tablet/Phone Apps
[SimpleBooth](https://www.simplebooth.com/) or [myphotoboothapp](https://myphotoboothapp.com/) seem to be effective apps, but lack the customization I thought would be entertaining. Requires hardware.

### Rental
Rental photobooths are available in our area, but they tend to be pricy and require an attendant for the night.

### Python Application
[Pibooth](https://pypi.org/project/pibooth/) looks to be a great application and would certainly get the job done. This would be the preferred solution if I wasn't looking for a learning exercise. Requires hardware.

## Software
I wanted to implement a few novel things in this photobooth:
- Completely touchless operation
- Different interaction modalities
- Landing screen minigame
- Automatic cloud upload of full-res media

### Architecture
In order to interact touchlessly with the application we'll rely on some human pose detection and image processing. The Python ecosystem offers plenty of existing libraries to do all of the heavy lifting, so we'll write the entire application in Python.

[PySimpleGUI](https://pysimplegui.readthedocs.io/en/latest/) offers an impressive set of features and seemed to cross off everything I was looking for in a GUI. It was my first time using this package and it will likely see future use.

The general outline I assumed for this application was a collection of "layouts", each with distinct elements, for each planned user interaction. The layouts are all children of the main window environment and get shown/hidden as necessary.
\fig{/projects/photobooth/layout_diagram.png}

[OpenCV](https://opencv.org/) will be used for image capture and manipulation.

Google's [Mediapipe](https://google.github.io/mediapipe/) performs impressively lightweight face, hand, and pose recognition and is used extensively throughout.

### Landing Page
The landing page houses most of the fun stuff. This is where the user will select their chosen modality and this is where they will be able to play the minigame. The layout should looke like:
\fig{/projects/photobooth/landing_diagram.png}

This is easy enough to create in PySimpleGUI layout language:
```Python
LANDING_LAYOUT = [  
        [sg.Text('Welcome to Our (touch free) Photobooth!', font='AmaticSC 100')],
        [sg.Image('cam_placeholder.png', key='landing_im')], 
        [sg.Text('please select an option above with your camera hands',justification='center', size=(100,1), font='AmaticSC 60')],
        [sg.Column([[sg.Text('Current Score: 0', font='AmaticSC 20',justification='right', pad=0, key='current_score'),]], pad=0,justification = 'right', element_justification = 'right')],
        [sg.Column([[sg.Text('High Score: 0', font='AmaticSC 20',justification='right', pad=0, key='high_score'),]], pad=0,justification = 'right', element_justification = 'right')],
        [sg.Column([[sg.Image('score_placeholder.png', key='high_score_face'),]], pad=0,justification = 'right', element_justification = 'right')]
    ]
```

While the landing page is in operation we feed the image placeholder new encoded .png images when they are ready from the camera. The minimal functional loop looks something like:
```Python
cap = cv2.VideoCapture('/dev/video0')
gui = sg.Window('Erin & Jacob Photobooth', layout, element_justification='c', resizable = True, margins=(0,0), return_keyboard_events=True, location=(2000,0))
while True:
    event, values = gui.read(25)
    ret,frame = cap.read()
    frame = cv2.flip(frame, 1)
    gui['landing_im'].update(data=cv2.imencode('.png', frame))[1].tobytes())
```

The first thing we'll add are the overlay rectangles on the image frame that show the available selections:
```Python
# Define rectangles
S_coords = [(0.1,0.08), (0.4,0.08), (0.7,0.08)]
S_labels = ["PHOTOSTRIP", "FLIPBOOK", "VIDEO"]
S_box = (0.2,0.15)

# Apply to each frame
for c,t in zip(S_coords,S_labels):
    cv2.rectangle(frame, 
            (int(c[0]*cap_x), int(c[1]*cap_y)), 
            (int((c[0]+S_box[0])*cap_x), int((c[1]+S_box[1])*cap_y)), 
            (0,0,0), 
            -1)
    
    TEXT_FACE = cv2.FONT_HERSHEY_DUPLEX
    TEXT_SCALE = 0.6
    TEXT_THICKNESS = 1
    text_size, _ = cv2.getTextSize(t, TEXT_FACE, TEXT_SCALE, TEXT_THICKNESS)
    text_origin = (int((c[0]+S_box[0]/2)*cap_x) - text_size[0] // 2, int((c[1]+S_box[1]/2)*cap_y) + text_size[1] // 2)
    cv2.putText(frame, 
            t, 
            text_origin, 
            TEXT_FACE, 
            TEXT_SCALE, 
            (255,255,255), 
            TEXT_THICKNESS)
```

Then we'll add the ability to track all the hands in the frame and give those hands the ability to select a rectangle by moving within its bounds.
```Python
selection_counter = [0 for _ in S_coords] 
needed_count = 10 #required frames for selection

with mp.solutions.hands.Hands(
        min_detection_confidence=0.6,
        min_tracking_confidence=0.5,
        max_num_hands = 10) as hands:
        
    this_frame_select = [False for _ in S_coords]

    res_hands = hands.process(image)
    if res_hands.multi_hand_landmarks:
        for hand_landmarks in res_hands.multi_hand_landmarks:

            #Find center of hands and annotate frame
            cx = np.mean([a.x for a in hand_landmarks.landmark])
            cy = np.mean([a.y for a in hand_landmarks.landmark])
            cv2.circle(frame, (round(cx*frame.shape[1]), round(cy*frame.shape[0])), 10, (255,0,255), -1)

            #Check each box to see if hand is within bounds
            for i,c in enumerate(S_coords):
                if (cx > c[0]) and (cx < c[0]+S_box[0]) and (cy > c[1]) and (cy < c[1]+S_box[1]):
                    this_frame_select[i] = True
                    selection_counter[i] += 1

                    # Check to see if we have fully selected this option
                    if selection_counter[i] >= needed_count:
                        return i
            
            # If we aren't selecting this box this time, decrement the counter (but not below 0)
            for i,tf in enumerate(this_frame_select):
                if not tf and S[i]>0:
                    selection_counter[i] -= 1            

            # If in the process of selecting, draw a green rectangle that changes size to show nearness to selection
            for c,s in zip(S_coords,selection_counter):
                if s > 0:
                    cv2.rectangle(frame, 
                            (round((c[0]+0.5*s/needed_count*S_box[0])*cap_x), round((c[1]+0.5*s/needed_count*S_box[1])*cap_y)), 
                            (round((c[0]+0.5*s/needed_count*S_box[0]+S_box[0]-s/needed_count*S_box[0])*cap_x), round((c[1]+0.5*s/needed_count*S_box[1]+S_box[1]-s/needed_count*S_box[1])*cap_y)),
                            (0,255,0), 
                            2)
```

So far this is what we have on the landing page:
<!-- TODO: add gif of selection here -->

Let's add the minigame. The 
@@im-100
\fig{/projects/photobooth/minigame_diagram.svg}
@@

## Ingredients
- [PySimpleGUI](https://pysimplegui.readthedocs.io/en/latest/) - a Python GUI For Humans
- [OpenCV](https://opencv.org/)
- [Mediapipe](https://google.github.io/mediapipe/)
- [Excalidraw](https://excalidraw.com/) - diagram creation
