@def title="Shuffle"

Folk wisdom claims 7 shuffles is sufficient to thoroughly mix up a deck of cards. This claim originates from a [paper](https://escholarship.org/content/qt0k4654kx/qt0k4654kx.pdf?t=p3z6d7) published in 1986 by David Aldous and Persi Diaconis and summarized [in the New York Times](https://www.nytimes.com/1990/01/09/science/in-shuffling-cards-7-is-winning-number.html) in 1990. 

Does my mediocre shuffling reflect this common wisdom? This post is an attempt to investigate that question.

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
The most straightforward approach seemed to be recording the cards falling during the shuffling sequence in slow motion (phone camera can capture at 240fps). A sample of the resulting video looks like:

@@im-100
\fig{/posts/005_shuffle/card_shuffle1.png}
@@

@@vid-100
~~~
<video controls>
  <source src="/posts/005_shuffle/front_shuffle.webm" type="video/webm">
</video>
~~~
@@

Even at 240fps we miss some of the faster cards in transit. We can address this by instead capturing the shuffle pile as it changes.

### Shuffling - Angled Down



## Building a Model

## Investigating Performance