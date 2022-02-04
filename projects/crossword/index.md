@def title = "Crossword"

\note{Objective}{Produce an interesting crossword puzzle that manifests the theme I have been mulling over.}


My friends have made a bunch of incredible crosswords over the years. I have had this idea for a crossword theme for a long time and finally put it together.

Before reading any spoilers head on over to [https://david.vaskos.com/crossword/7](https://david.vaskos.com/crossword/7) (thanks David!) to do the crossword online or print out a .pdf version available [here](/projects/crossword/crossword.pdf). It is mostly free of inside jokes.

## Board Design
@@im-100
\fig{/projects/crossword/p2_blank.svg}
@@

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

Of these, I selected the bottom right solution as the most "crossword-looking" starting point for the puzzle layout. 

<!-- Of these, I selected the bottom right solution as the most "crossword-looking". I then added in additional squares to make the board-filling problem tractable, making sure to only add them in places that wash out in three generations of propagation. The purple squares in the image below were added to create the final board ready for filling. In reality they were added iteratively with the board filling to accommodate certain clues.
@@im-100
\fig{/projects/crossword/added_squares.png}
@@ -->


## Board Fill

To begin the filling process I identified the theme answers I wanted to incorporate:
 - JOHNCONWAY
 - DEEPTHOUGHT
 - THISPUZZLE
 - SEVENPOINTFIVEMILLION
 - LIFE
 - THE UNIVERSE
 - EVERYTHING
 - THREE

The board filling was done with help from [QXW](https://www.quinapalus.com/qxw.html). QXW allows a user to import gigantic lists of words and then attempts to solve the remaining puzzle while you type in your desired answers. QXW will suggest answers that fit with the current layout. The most helpful feature is the red square that appears in a box to show you when you are running low on possible letters that make sense there (or when you will have to get creative with an answer).

As the puzzle was filled out I iterated on the location of the black squares surrounding the resulting 42.

The first attempt may have ultimately resulted in a better puzzle. I compromised the clean look of the simulated puzzle to produce a solution that looked more crossword like.
@@im-100
\fig{/projects/crossword/puz1.svg}
@@

But ultimately could not live with the fact that the 42 did not come out standing alone.
@@im-100
\fig{/projects/crossword/123_old.gif}
@@

So I went back to the original layout and took care to only add additional black squares in patterns that would wash out in three generations. The final completed puzzle has a few sore spots but ultimately I am pretty happy with how it turned out.

@@im-100
\fig{/projects/crossword/puz2.svg}
@@
@@im-100
\fig{/projects/crossword/123_p2.gif}
@@

## Clue Writing

Numbering and clue writing was done manually in [LibreOffice Calc](https://www.libreoffice.org/discover/calc/) because I could not get QXW to number the single letter answers but thought they would be interesting to write clues for. 

Here are a few of my favorite clues:
 - 22, 23 Across and 14,22 Down: 23-Across + 14-Down + 22-Down, to Caesar - C+CDIV+MXI=MDXV (100+404+1011=1515)
    - This one took forever to get right
 - 41 Across: Children and Teens - EVENTUALADULTS
 - 52 Across: The greenness of a bowl of a greens - SALADHUE
 - 94 Across: Cause of financial strain for millennials - AVOCADOES
 - 98 Across: Half the cost of a large purchase - ARM
 - 145 Across: Long term dwelling not pictured on Google Earth (Abbr.) - ISS
 - 15 Down: Theodore, after changing his name - EXTED
 - 87 Down: Hollywood actor/actress producers? - LAIMPLANTS (a little forced)
 - 97 Down: Someone who produces presents that are difficult to unwrap - OVERTAPER


## Ingredients
Thank you to the following software projects that made the creation of this puzzle possible:
 - [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
 - [Golly](http://golly.sourceforge.net/) - For interacting with Game of Life boards
 - [Logic Life Search](https://github.com/OscarCunningham/logic-life-search) - for posing the SAT problem for Conway's Game of Life 
 - [lingeling](http://fmv.jku.at/lingeling/) - for solving the SAT problem (and plingeling for a parallel solver)
 - [QXW](https://www.quinapalus.com/qxw.html) - for filling in the puzzle
 - [Peter Broda's WordList](https://peterbroda.me/crosswords/wordlist/) - for QXW to use in word suggestion
 - [david.vaskos.com](https://david.vaskos.com/crossword/7) - for hosting the puzzle and providing an excellent interface

