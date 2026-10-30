# Escape and Siege – Artificial Intelligence

A Prolog implementation of **Escape and Siege**, a two-player strategy game developed as part of an Artificial Intelligence course at Instituto Superior de Engenharia de Lisboa (ISEL).

The project includes the game logic, board management, legal move validation and two AI search algorithms: **Minimax** and **Minimax with Alpha-Beta pruning**.

## Features

- **Game board:** Configurable board dimensions.
- **Two-player mode:** Play against another human player.
- **AI opponent:** Play against the computer.
- **Minimax:** Decision-making algorithm based on game tree exploration.
- **Alpha-Beta pruning:** Optimized Minimax implementation that reduces the number of nodes evaluated.
- **Heuristic evaluation:** Considers player progress, mobility and blocked goal cells.
- **Node counter:** Tracks the number of evaluated nodes during AI decisions.

## Project Structure

```text
escape-and-siege-prolog/
│
├── board.pl       # Board creation, initialization and printing
├── move.pl        # Movement rules and move validation
├── engine.pl      # Game logic, legal moves and evaluation functions
├── minimax.pl     # Minimax and Alpha-Beta algorithms
├── game.pl        # Main game loop and player interaction
│
└── README.md
```

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/)

## How to Run

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/escape-and-siege-prolog.git
cd escape-and-siege-prolog
```

Start SWI-Prolog:

```bash
swipl
```

Load the game:

```prolog
?- [game].
```

### Human vs Human

Start a game by specifying the board dimensions, initial positions and starting player:

```prolog
?- start(6, 6, [1,4], [1,4], x).
```

### Human vs AI

Start a game against the computer:

```prolog
?- startAI(6, 6, [1,4], [1,4], x, 2, 3).
```

Parameters:

- Board dimensions: `6, 6` (rows and columns).
- Initial positions: `[1,4]` for each player's pieces.
- Human side: `x` or `o`.
- Algorithm: `1` for Minimax, `2` for Alpha-Beta.
- Search depth: `3` in this example.

There is also a shorter version using Alpha-Beta with a default depth of 3:

```prolog
?- startAI(6, 6, [1,4], [1,4], x).
```

## AI Algorithms

### Minimax

The Minimax algorithm explores possible future game states and selects the move with the best outcome, assuming both players play optimally.

### Alpha-Beta Pruning

Alpha-Beta uses the same decision-making principle as Minimax but avoids exploring branches that cannot influence the final decision.

This reduces the number of nodes evaluated while preserving the result of the search.

### Evaluation Function

When the search reaches its depth limit, the AI evaluates the current board using three main factors:

- **Progress:** How close each player's pieces are to their goal row.
- **Mobility:** Number of legal moves available to each player.
- **Blocked goal cells:** Number of blocked positions in each player's goal row.

Terminal states receive a much higher score to prioritize winning positions and avoid losing ones.

## Technologies

- **Language:** Prolog
- **Environment:** SWI-Prolog
- **AI techniques:** Minimax and Alpha-Beta pruning
- **Concepts:** Game trees, heuristic evaluation, adversarial search and recursive problem solving.

## Academic Context

Developed as part of an Artificial Intelligence assignment during the Erasmus exchange at Instituto Superior de Engenharia de Lisboa (ISEL), Lisbon, Portugal.

---

*University project developed for learning and applying classical Artificial Intelligence search algorithms.*
