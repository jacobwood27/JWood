@def title = "Bracket Simulation"

\note{Objective}{Tackle a semi-tractable domain with predictive algorithms and implement a publically available application.}

There are 13 games in the NFL playoffs, which means there are 2^13 = 8192 unique ways it can play out. My group of friends plays a small bracket prediction competition each year. The goal is to predict a bracket (select 1 of the 8192 unique possible outcomes) and get more games right than everyone else (with some extra weight for the later games).

\fig{/projects/bracket_sim/2022bracket-sea.webp}

There must exist a single bracket that has the highest probability of winning the competition. The best bracket has to balance picking likely winners against picking brackets that are differentiated from the competition to derive an edge. To do this, we'll leverage everything we know about our friends' behavior and the brackets they are likely to pick.

You can find the finished product [here](https://jacobwood27.github.io/052_bracketsim2/) and all the code is [here](https://github.com/jacobwood27/052_bracketsim2).

# Predicting the Actual Outcomes
The first step for us is predicting the actual outcomes of the NFL playoff games to the best of our abilities. Luckily, [FiveThirtyEight](https://fivethirtyeight.com/) has us covered. 

538 has put together an [ELO](https://en.wikipedia.org/wiki/Elo_rating_system) model that can be used to predict the likelihood of any team winning a hypothetical matchup against any other team. [The model](https://fivethirtyeight.com/methodology/how-our-nfl-predictions-work/) is capable of incorporating unique circumstances like location (and associated travel distance), whether or not a team is rested, whether or not the game is a playoff game, and the current injury status of a team's top QB.

To model out all the possible outcomes all we need to read in is thus:
 - Each team's seed
 - Each team's (QB adjusted) ELO rating
 - A location associated with each team
 - The Superbowl location

For the 2022-2023 playoffs:
```
TEAMS = Dict(
    1  => ( "KC", 1702,    (39.048914, -94.484039)),
    2  => ("BUF", 1708,    (42.773739, -78.786978)),
    3  => ("CIN", 1666,    (39.095442, -84.516039)),
    4  => ("JAC", 1540,    (30.323674, -81.637328)),
    5  => ("LAC", 1543,    (33.952815,-118.340306)),
    6  => ("BAL", 1608-92, (39.277969, -76.622767)),
    7  => ("MIA", 1509-160,(25.956799, -80.240191)),

    11 => ("PHI", 1650,    (39.900775, -75.167453)),
    12 => ( "SF", 1700-80, (37.713486,-122.386256)),
    13 => ("MIN", 1553,    (44.973805, -93.259297)),
    14 => ( "TB", 1504,    (27.975967, -82.503350)),
    15 => ("DAL", 1616,    (32.747778, -97.092778)),
    16 => ("NYG", 1503,    (40.813303, -74.074500)),
    17 => ("SEA", 1463,    (47.595153, -122.33162)),
)

SUPERBOWL_LOC = (33.525890, -112.261958)
```

### Structure
The NFL playoffs have an unfortunately complicated playoff structure due to bye weeks. We have to think a bit about how we want to lay things out.

I chose to store the game tree as a linear vector and all the logical operations occur on the index into the vector. This kept the storage requirements as small as possible at the expense of some off-by-1 error debugging. The game tree can be drawn like this:
@@im-100
\fig{/projects/bracket_sim/game_tree.svg}
@@

After we have the entire game tree stored we can easily index into it. For example, we can say: "if I am at game 6 I know games 1 and 3 have occurred, the home teams were SF and JAC, and the winners were SEA and JAC."

In the end we will have 8191 games in the gametree, and 8192 possible outcomes.

### Implementation
The complexity in building up the gametree comes from the way the NFL handles bye weeks and seeding. In each round, the highest seed must play the lowest seed, the 2nd highest plays the 2nd lowest, etc. To capture this we need a bit of logic in each round. 

```
function get_teams(game_i, T)
    
    if     game_i < 2^1
        return (12,17) # SF v SEA
    elseif game_i < 2^2
        return (4,5)   #JAC v LAC 
    elseif game_i < 2^3
        return (2,7)   #BUF v MIA
    elseif game_i < 2^4
        return (13,16) #MIN v NYG
    elseif game_i < 2^5
        return (3,6)   #CIN v BAL
    elseif game_i < 2^6
        return (14,15) # TB v DAL

    elseif game_i < 2^7
        opp = maximum([winner(game_i,rnd,T) for rnd in [2,3,5]])
        return (1,opp)  # KC v lowest seed from 2nd, 3rd, and 5th game
    elseif game_i < 2^8
        opp = maximum([winner(game_i,rnd,T) for rnd in [1,4,6]])
        return (11,opp) #PHI v lowest seed from 1st, 4th, and 6th game
    elseif game_i < 2^9
        tms = sort([winner(game_i,rnd,T) for rnd in [1,4,6]])
        return (tms[1],tms[2]) # highest seed from [1,4,6] vs 2nd highest
    elseif game_i < 2^10
        tms = sort([winner(game_i,rnd,T) for rnd in [2,3,5]])
        return (tms[1],tms[2]) # highest seed from [2,3,5] vs 2nd highest

    elseif game_i < 2^11
        tms = sort([winner(game_i,rnd,T) for rnd in [8,9]])
        return (tms[1],tms[2]) # highest seed from [8,9] vs 2nd highest
    elseif game_i < 2^12
        tms = sort([winner(game_i,rnd,T) for rnd in [7,10]])
        return (tms[1],tms[2]) # highest seed from [7,10] vs 2nd highest

    elseif game_i < 2^13
        return (winner(game_i,11,T), winner(game_i,12,T)) # AFC champ v NFC champ
    end
end
```

After putting together the gametree we can assign probabilities to each outcome using the ELO scores referenced above. We can determine the probability of each branch by taking the product of each individual game probability. This results in 8192 probabilities that sum up to 1. 

The most likely outcome (the favorites win every game) is not very likely at all, it is expected to occur only ~1% of the time. The least likely outcome (underdogs all the way) has a whopping 1:500 million chance of occuring.

\fig{/projects/bracket_sim/outcome_probs.svg}

# Predicting Friends
One option we have for predicting how our friends are going to fill out their bracket is to explicitly fill out a bracket as we expect them to. But the problem there is that the solution is not very robust. What if we get a key game wrong? We might want to fill out a second bracket, and a third. And a fourth. And then probably assign some weights to how likely we think each choice is. This approach seemed intractable to me. 

Instead, we can assume each friend utilizes a strategy for selecting their brackets. Or, if we are less confident, put some credences on how likely they are to use each option from a menu of strategies.

The strategies I came up with to implement attempted to mimic my own decision making. They are:
 - Random: every game is a coin toss
 - Chalk: pick all the favorites
 - Pick Underdog: pick the underdog a set number of times
 - Favorite Team: make sure one team goes all the way
 - Tossup: close games are as good as random, heavy favorites win
 - Extremify: probability of picking is based on probability of winning 


# Ingredients
 - [FiveThirtyEight](https://fivethirtyeight.com/)
