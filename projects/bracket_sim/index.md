@def title = "Bracket Simulation"

\note{Objective}{Tackle a semi-tractable domain with predictive algorithms and implement a publically available application.}

There are 13 games in the NFL playoffs, which means there are 2^13 = 8192 unique ways it can play out. My group of friends plays a small bracket prediction competition each year. The goal is to predict a bracket (select 1 of the 8192 unique possible outcomes) and get more games right than everyone else (with some extra weight for the later games).

There must exist a single bracket that has the highest probability of winning the competition. The best bracket has to balance picking likely winners against picking brackets that are differentiated from the competition to derive an edge. To do this, we'll leverage everything we know about our friends' behavior and the brackets they are likely to pick.

You can find the finished product [here](http://nflbracket.xyz/).

