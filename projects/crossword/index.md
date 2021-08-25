@def title = "Crossword"

My friends have made a bunch of incredible crosswords over the years. I have had this idea for a crossword theme for a long time and have finally put it together. This page details how the crossword was made!

Before reading any spoilers head on over to [https://david.vaskos.com/crossword/7](https://david.vaskos.com/crossword/7) to do the crossword online (or print out a .pdf version available [here](/projects/crossword/crossword.pdf)). It is mostly free of inside jokes.

## Board Design
\fig{/projects/crossword/crossword_board.png}

### Inspiration
The theme of the puzzle is roughly "Life" and the intent was to draw together [John Conway's *Game of Life*](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) with [Douglas Adams' *Answer to the Ultimate Question of Life, The Universe, and Everything*](https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#Answer_to_the_Ultimate_Question_of_Life,_the_Universe,_and_Everything_(42)). 

The theme of the puzzle, to give it all away, is that when the black spaces on the board are simulated in *The Game of Life* the meaning of life should emerge.

### Ideal Board
The ideal game board in my mind would have these qualities:
  - When entered into the *Game of Life* and simulated for X generations the number 42 should appear
  - Look initially like a typical 21x21 Sunday crossword
  - Support a few long answers
  - NYT Crossword Legal
    - Rotationally symmetric
    - No answers shorter than 3 letters

We unfortunately couldn't get all the way there, but we got close and managed to meet the important ones!

### Board Exploration
To complete the board design we need to find a way to search through the design space, which is huge (there are 2^(21\*21) = 5.7\*10^132 possible boards), for a specific pattern that results in the number 42 drawn in black squares. 

*The Game of Life* is meant to simulate a complex system, where local forward propagation is easy but it is inherently difficult to solve the problem in reverse or make deductions from global structure. Fortunately it is not necessary to brute-force sweep the design space for suitable starting grids, instead we can turn to some tools that the vibrant [*Game of Life* community](https://www.conwaylife.com/forums/) has put together. 

[Logic Life Search](https://gitlab.com/OscarCunningham/logic-life-search) (lls) is a Python program that searches for patterns in cellular automata. It takes in a starting pattern definition and a final pattern definition and translates the automata propagation into a Boolean satisfiability problem (SAT). We can then use a freely available SAT solver (like [lingeling](http://fmv.jku.at/lingeling/) or [cadical](https://github.com/arminbiere/cadical)) to search for solutions to the SAT problem.

We can also make use of [Golly](http://golly.sourceforge.net/) to visualize solutions and get a feel for the board layouts.

The initial input to lls should be a wide open 21x21 board, which looks like:
```plaintext
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 * * * * * * * * * * * * * * * * * * * * * 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

And the desired end state is a large text 42, which looks like:
```plaintext
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0
0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

The call to lls was wrapped in a Python script and allowed to run in parallel over a few days. Results were easily found for 1, 2, and 3 generations in the past. Results for 4 generations in the past (and further) were not uncovered in the maximum specified 100 hours of solve time. 

Here is an example of boards that work in 1, 2, and 3 generations:
@@im-100
\fig{/projects/crossword/123.gif}
@@


More generations of evolution seemed more exciting to me, so I restricted the options to the 20 unique 3 generation boards that the solver produced:
@@im-100
\fig{/projects/crossword/20_opts.gif}
@@

Of these, I selected the bottom right solution as the most "crossword-looking". I then added in additional squares to make the board-filling problem tractable, making sure to only add them in places that wash out in three generations of propagation. The purple squares in the image below were added to create the final board ready for filling.
@@im-100
\fig{/projects/crossword/added_squares.png}
@@


## Board Fill

The part of the board that was most difficult to fill in was the lower-center and middle-right. As a result, a few clues answers stand out as needing updates. 

## Clue Writing
