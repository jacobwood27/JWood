@def title="Erdos Problem"

This is a "stream of consciousness" post that attempts to solve the problem that bubbled up on Hacker News described here: [https://mapehe.github.io/math-problem/index.html](https://mapehe.github.io/math-problem/index.html)


The goal is to prove whether or not it is possible to tile an 8x8 checkerboard that is missing two corners with 1x2 and 2x1 pieces.
@@im-60
\fig{/posts/003_erdos_problem/8x8_overview.svg}
@@


The introduction to the problem makes it clear that the solution is rather elegant. A good start might be to consider the simplest (smallest) board, and identify the pattern that occurs as we increase in size. 

A 2x2 board with corners removed does not have room for either a 2x1 or a 1x2 block.
@@im-30
\fig{/posts/003_erdos_problem/2x2.svg}
@@

A 3x3 board contains an odd number of available squares, and is thus impossible to tile with 1x2 or 2x1 blocks. This will hold for all odd sized boards.
@@im-30
\fig{/posts/003_erdos_problem/3x3.svg}
@@

A 4x4 board cannot be tiled either. If we assume the top left block is oriented vertically, then the placement of blocks 2 through 6 are directly forced and block 7 cannot be placed. If we had assumed the top left block was placed horizontally we would have arrived at the same result due to the symmetry of the problem.
@@im-30
\fig{/posts/003_erdos_problem/4x4.svg}
@@

A 6x6 board is too big to attempt (by hand) all the possible tilings of. After playing around a bit I found this pattern which should look familiar; the remaining squares are the same as the remaining 4x4 board that we just showed could not be tiled.
@@im-30
\fig{/posts/003_erdos_problem/6x6.svg}
@@

Is it possible to show that the 6x6 board is only capable of tiling if the 4x4 board tiles? If so, that seems to be a promising thread to pull on.

Another potential clue - my attempted 6x6 tiling solutions always leave two squares of the same color uncovered.
@@im-30
\fig{/posts/003_erdos_problem/6x6_v2.svg}
@@

This starts to lead us down a promising path. The squares are not just the same color, they are *always* blue. The puzzle contains $(6 \times 6)/2 = 18$ blue squares, but only $(6 \times 6)/2 - 2 = 16$ black squares. Each piece covers two adjacent squares, which are always of differing colors (one blue and one black). After placing 16 pieces we will have covered 16 black squares and 16 blue squares, always leaving two blue squares remaining!

This solution will hold for the 8x8 case, where there are 32 blue squares and 30 black squares. The board is not tileable.

@@im-30
\fig{/posts/003_erdos_problem/8x8.svg}
@@