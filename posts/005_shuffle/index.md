@def title="Shuffle"

Folk wisdom claims 7 shuffles is sufficient to thoroughly mix up a deck of cards. This claim originates from a [paper](https://escholarship.org/content/qt0k4654kx/qt0k4654kx.pdf?t=p3z6d7) published in 1986 by David Aldous and Persi Diaconis and summarized [in the New York Times](https://www.nytimes.com/1990/01/09/science/in-shuffling-cards-7-is-winning-number.html) in 1990. 

Does my mediocre shuffling reflect this common wisdom? This post is an attempt to investigate that question.

\toc

## Collecting Data
The first step to assessing my shuffling performance is to investigate a few real world shuffles. To start I recorded 5 the results of 5 shuffles by hand to get a sense of the variation in the distribution. Each run involved shuffling the deck with a riffle shuffle but not aligning the left and right hand piles:

@@im-100
\fig{/posts/005_shuffle/card_shuffle1.png}
@@


The resulting order was then recorded as a string of 1s (card from left hand) and 2s (card from right hand). The 5 initial shuffles were:

```plaintext
1112212122121212121212121212121212121212121212111221
1222212212212121221212121212121212222112112211221122
2221121212211212112121221211221212121122222112212122
2222122121221121212121122112211222121222211222112211
2221221221122221212112221122121212212211122122121221
```

Eyeballing here shows quite a bit of variation from shuffle to shuffle. I set out to record the results of 100 independent shuffles to start to quantify the distribution.

### Video Recording
Initial attempts at data collection all revolved around recording video of cards and processing it to back out the shuffled sequence.

#### Shuffling - Head On 
The most straightforward approach seemed to be recording the cards falling during the shuffling sequence in slow motion (phone camera can capture at 240fps). The video was recorded in a semi-reproducible environment to ease processing:

@@im-60
\fig{/posts/005_shuffle/front_view.png}
@@

A sample of the resulting video looks like:
@@vid-100
~~~
<video controls mute autoplay loop>
  <source src="/posts/005_shuffle/front_shuffle.webm" type="video/webm">
</video>
~~~
@@

Even at 240fps some of the faster cards aren't captured in transit, and the ones that are captured are blurry and tough to detect with any sort of definable edge or feature. We can address this by instead capturing the face of the shuffle pile as it changes (the time constant between dropping new cards is much larger than the one associated with the drop itself).

#### Shuffling - Angled Down
The new and improved data collection environment involved even more cardboard:
@@im-60
\fig{/posts/005_shuffle/top_view.png}
@@

Initially, the video collected during a shuffle looks promising. It is easy to identify transitions between shuffled cards and which hand is dropping the card:
@@vid-100
~~~
<video controls mute autoplay loop>
  <source src="/posts/005_shuffle/top_shuffle.webm" type="video/webm">
</video>
~~~
@@

However, when we look a little closer we don't notice any funny business:
@@vid-100
~~~
<video controls mute autoplay loop>
  <source src="/posts/005_shuffle/top_slow2.webm" type="video/webm">
</video>
~~~
@@
Which is a problem because there was indeed some funny business. The 3 of clubs was tucked between the 9 and 4 of spades. 
@@im-60
\fig{/posts/005_shuffle/missing3c.png}
@@
You can make out the edge of the card in the video, but we never see the face because the shuffle isn't perfect and I release both the 3 of clubs and the 4 of spades at the same time. 

This doesn't happen in every shuffle, but it does happen occasionally. We might argue that we can just throw out shuffles  where we don't process 52 different cards to avoid the missed card measurement error. However, that would introduce a systematic bias into the measurement - we would be removing all the worst shuffles from the dataset and our resulting impression of our shuffling performance would be better than it should be.

#### Post Shuffle Riffle

One way to address the systematic bias mentioned above is to decouple the event of the shuffle from the recording of it. That way, if we were to make an error that invalidates the recording, we have no reason to expect the error would alter the perceived distribution. One way to do this is to record the order of the cards after the shuffle. If we record the order before and after each shuffle we can back out the 1s and 2s that make up our riffle model.

If we take the cards and riffle them in front of the camera we can then look for cards in each frame and record the order. 
@@vid-100
~~~
<video controls mute autoplay loop>
  <source src="/posts/005_shuffle/post_riffle_slow.webm" type="video/webm">
</video>
~~~
@@

This strategy is also prone to missing a card, but we can address the problem this time. We can record two different riffles and compare the resulting orders, using the knowledge from the second recording to fill in gaps or resolve discrepancies. If we are unable to order the cards with sufficient confidence we can drop that shuffle from the dataset without introducing bias.

##### Transfer Learning Post Processing
Of course, we won't be processing the video by hand. I was hoping to use this project to do some in-the-wild machine learning so we will leverage that here. There are a [few projects](https://github.com/search?q=playing+card+detection) on Github doing playing card detection but they are generally looking for whole cards on specific backdrops. We will train a new model and make use of the controlled environment it is being deployed in.

###### Data Labelling
We'll start off by labelling a bit of the data we collected to train on. We'll use Python and OpenCV to flip through the video files and write frames:
```Python
import cv2
```
Most of the models we will be considering want small and square images as input. Fortunately, we riffled in a very consistent fashion so we can crop all the video frames in the same small square. We'll use 224x224 as our image size for now.
@@im-60
\fig{/posts/005_shuffle/sample_full_frame_rect.jpg}
@@
```Python
def prep_frame(f):
    return cv2.resize(f[0:800, 700:1500], (224,224))
```

We can then run through the video frame by frame and label each image. To make things easier we will consider two different classification problems for each frame independently - suit and rank. 

To start with the suits we need to:
 1. Read a new frame from a video
 2. Crop the frame as dictated above
 3. Show the frame and wait for a keypress
 4. Upon keypress:
  - If "c", "s", "h", "d", or "0" (for clubs, spades, hearts, diamonds, none) save to that directory with unique ID generated from frame counter
  - If "q" then quit the program
  - If other key then skip the frame and go to the next
 5. Repeat until the end of the video is reached 

```Python
cap = cv2.VideoCapture("INPUT.MOV")

i = 0

while True:
    
    i+=1

    ret, f = cap.read()
    if not ret:
        print("End of video")
        break

    f = prep_frame(f)
    
    cv2.imshow('frame', f)
    key = cv2.waitKey(0)
    
    if chr(key) in 'cshd0':
        cv2.imwrite("suit_data/" + chr(key) + "/" + str(i) + ".jpg", f)
    elif chr(key) in 'q':
        break

cap.release()
cv2.destroyAllWindows()
```
After running through all the video frames we should have generated a bit of training data for each suit.
@@im-60
\fig{/posts/005_shuffle/post_suit_class.png}
@@

And we can verify the classifications look decent:
```Python
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import ImageGrid
import numpy as np

fig = plt.figure(figsize=(10., 6.))
grid = ImageGrid(fig, 111, nrows_ncols=(3, 5), axes_pad=0.1, share_all=True)

grid[0].get_yaxis().set_ticks([])
grid[0].get_xaxis().set_ticks([])

grid[0].set_title("C")
grid[1].set_title("D")
grid[2].set_title("H")
grid[3].set_title("S")
grid[4].set_title("0")

ims = []
for _ in range(3):
    for s in "cdhs0":
        im_file = random.choice(os.listdir("post_riffle/suit_data/"+s))
        im = cv2.imread("post_riffle/suit_data/"+s+"/"+im_file)
        ims.append(im[...,::-1])

for ax, im in zip(grid, ims):
    ax.imshow(im)

plt.show()
```
@@im-100
\fig{/posts/005_shuffle/suit_verify.png}
@@

Rinse and repeat for the ranks of each card.

###### Model Training
Now that we have a subset of our data labelled we can train an algorithm to label the rest of the videos we will take. 

There are plenty of models out there that do a great job of parsing images and learning their requisite features. We would like to take a model that is good at understanding images and have it learn to classify our specific images. This is the definition of [transfer learning](https://en.wikipedia.org/wiki/Transfer_learning). 

We'll follow along with the TensorFlow example detailed [here](https://www.tensorflow.org/hub/tutorials/tf2_image_retraining) for the most part.

First bring in a few packages we will need:
```Python
import os

import matplotlib.pylab as plt
import numpy as np

import tensorflow as tf
import tensorflow_hub as hub
```

The we can browse through the [available models on TensorFlow Hub](https://tfhub.dev/s?module-type=image-classification) for a suitable classification model. Our problem is pretty easy, and we will have no trouble using a small [MobileNet model](https://tfhub.dev/google/imagenet/mobilenet_v2_100_224/feature_vector/5). This model takes in 224x224 images (which is what we saved our training data at, so no need to resize).

```Python
model_name = "mobilenet_v2_100_224"
model_handle = "https://tfhub.dev/google/imagenet/mobilenet_v2_100_224/feature_vector/5"
image_size = (224,224)
batch_size = 16
data_dir = "suit_data"
```

We'll use [Keras](https://keras.io/) as our framework. Keras provide a convenient API to split up our dataset:
```Python
def build_dataset(subset):
      return tf.keras.preprocessing.image_dataset_from_directory(
        data_dir,
        validation_split=.20,
        subset=subset,
        label_mode="categorical",
        seed=123,
        image_size=image_size,
        batch_size=1)
``` 

Which we can use to generate a training and a validation dataset:
```Python
train_ds    = build_dataset("training")
val_ds      = build_dataset("validation")
```

And record a few pieces of information before we change the datasets:
```Python
train_size  = train_ds.cardinality().numpy()
val_size    =   val_ds.cardinality().numpy()
class_names = tuple(train_ds.class_names)
```

We will want to pre-process our image inputs and introduce some artificial warping to flesh out the data set. 

First, the MobileNet model expects inputs from 0 to 1 and our current images contain pixel values from 0 to 255. We can fix that with a normalization layer that scales the data by 1/255. We'll want to do this to both the training and the validation data.

Next, we can move the images around a bit to resemble changes we might see in new data. These changes could consist of:
 - rotation
 - vertical translation
 - horizontal translation 
 - zoom
 - contrast 
We will only want to apply these mutations to the training data.

```Python
normalization_layer = tf.keras.layers.Rescaling(1. / 255)

preprocessing_train = tf.keras.Sequential([
    normalization_layer,
    tf.keras.layers.RandomRotation(0.1),
    tf.keras.layers.RandomTranslation(0, 0.2),
    tf.keras.layers.RandomTranslation(0.2, 0),
    tf.keras.layers.RandomZoom(0.2, 0.2),
    tf.keras.layers.RandomContrast(0.1),
])

preprocessing_val = tf.keras.Sequential([
    normalization_layer
])
```

Then we can take our data, stick it into batches, and apply the preprocessing described above to get it all ready to go. Note - we need to add a repeat() call to our training data to ensure we can make enough data during the training runs (this seems weird to me?). 
```Python
train_ds = train_ds.unbatch().batch(batch_size)
train_ds = train_ds.repeat()
train_ds = train_ds.map(lambda images, labels:(preprocessing_train(images), labels))

val_ds = val_ds.unbatch().batch(batch_size)
val_ds = val_ds.map(lambda images, labels:(preprocessing_val(images), labels))
```

With the data ready to go we can prepare the model we are going to train. We need to add a few things to the main MobileNet model specified earlier to link everything together.

First, we need to add an input layer that is compatible with our RGB image size (224x224x3). 

That can feed into the MobileNet model which gets downloaded from TensorFlow Hub. 

We probably also want to include some dropout to prevent overtraining. 20% is a standard value to start with.

Finally, we need a Dense layer that will act as the classifier for the 5 different classes we have: none, clubs, diamonds, hearts, and spades. We will include some [L2 regularization](https://developers.google.com/machine-learning/glossary/#L2_regularization) in this Dense layer to keep the kernel weights in check.

```Python
model = tf.keras.Sequential([
    tf.keras.layers.InputLayer(input_shape=image_size + (3,)),
    hub.KerasLayer(model_handle, trainable=True),
    tf.keras.layers.Dropout(rate=0.2),
    tf.keras.layers.Dense(len(class_names),
                          kernel_regularizer=tf.keras.regularizers.l2(0.0001))
])
```

Next we need to define how we want to train the model. This is done with model.compile() and some definitions. 
- Optimizer: [Stochastic Gradient Descent](https://keras.io/api/optimizers/sgd/) with a small learning rate should work just fine, but feel free to poke around
- Loss Function: [Categorical Crossentropy](https://keras.io/api/losses/probabilistic_losses/#categoricalcrossentropy-class) is recommended when there are two or more labels that are one-hot encoded
    - from_logits = True [must be used](https://datascience.stackexchange.com/questions/73093/what-does-from-logits-true-do-in-sparsecategoricalcrossentropy-loss-function) when the outputs are not normalized (as is the case when we have not soft-maxed the outputs)
    - label_smoothing takes our one-hot encoded outputs and smooths out the confidence a bit. Instead of encoding a club as [0,1,0,0,0] we encode it as, say, [0.01,0.96,0.01,0.01,0.01]. This can help regularization a bit.
- Metrics: We will just monitor accuracy here

```Python
model.compile(
    optimizer=tf.keras.optimizers.SGD(learning_rate=0.005), 
    loss=tf.keras.losses.CategoricalCrossentropy(from_logits=True, label_smoothing=0.1),
    metrics=['accuracy'])
```

Now we are ready to hit go on the training. We will train the model for 10 standard epochs and see how we're doing. This might take a few minutes.
```Python
steps_per_epoch = train_size // batch_size
validation_steps = val_size // batch_size
hist = model.fit(
    train_ds,
    epochs=10, 
    steps_per_epoch=steps_per_epoch,
    validation_data=val_ds,
    validation_steps=validation_steps).history
```
```Plaintext
Epoch 1/10
45/45 [==============================] - 44s 908ms/step - loss: 1.1458 - accuracy: 0.5792 - val_loss: 0.9850 - val_accuracy: 0.6420
Epoch 2/10
45/45 [==============================] - 39s 884ms/step - loss: 0.7227 - accuracy: 0.8610 - val_loss: 0.6280 - val_accuracy: 0.9205
Epoch 3/10
45/45 [==============================] - 40s 879ms/step - loss: 0.5971 - accuracy: 0.9368 - val_loss: 0.4976 - val_accuracy: 0.9886
Epoch 4/10
45/45 [==============================] - 40s 878ms/step - loss: 0.5762 - accuracy: 0.9579 - val_loss: 0.5069 - val_accuracy: 0.9943
Epoch 5/10
45/45 [==============================] - 39s 875ms/step - loss: 0.5431 - accuracy: 0.9691 - val_loss: 0.4847 - val_accuracy: 0.9943
Epoch 6/10
45/45 [==============================] - 39s 877ms/step - loss: 0.5381 - accuracy: 0.9705 - val_loss: 0.4756 - val_accuracy: 1.0000
Epoch 7/10
45/45 [==============================] - 40s 878ms/step - loss: 0.5272 - accuracy: 0.9803 - val_loss: 0.4778 - val_accuracy: 0.9886
Epoch 8/10
45/45 [==============================] - 40s 879ms/step - loss: 0.5193 - accuracy: 0.9803 - val_loss: 0.4799 - val_accuracy: 0.9886
Epoch 9/10
45/45 [==============================] - 39s 878ms/step - loss: 0.5227 - accuracy: 0.9789 - val_loss: 0.4841 - val_accuracy: 0.9830
Epoch 10/10
45/45 [==============================] - 39s 873ms/step - loss: 0.5221 - accuracy: 0.9733 - val_loss: 0.4808 - val_accuracy: 0.9943
```
Tough to beat that. We probably could have gotten away with only 5 epochs, but oh well.
@@im-100
\fig{/posts/005_shuffle/train_loss.png}
@@

Finally, we can save the trained model:
```Python
model.save("/home/woojac/proj/031_shuffle/suit_predictor02")
```














#### Post Shuffle Conveyor Belt
Because we had a lot of cardboard to spare I had to try getting the power tools involved. The gravity-fed rubber band and drill feeder worked, but was more trouble than it was worth.

@@vid-100
~~~
<video controls mute autoplay loop>
  <source src="/posts/005_shuffle/bottom_belt.webm" type="video/webm">
</video>
~~~
@@

## Building a Shuffling Model

## Investigating Performance



## Ingredients
 - pngquant
 - Gimp
 - ffmpeg
 - jpegoptim
 - iPhone 11
 - cardboard
 - Bicycle playing cards
 - Python 3.9.7
 - OpenCV 4.5.4
 - Matplotlib 3.3.4
 - Numpy 1.19.5
 - Tensorflow 2.7.0
 - Tensorflow_hub 0.12.0