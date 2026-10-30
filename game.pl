:- ensure_loaded('board.pl').
:- ensure_loaded('move.pl').
:- ensure_loaded('minimax.pl').

askPlayerMove(StartRow, StartCol, EndRow, EndCol) :-
    write('== Moving piece'), nl, write('= From:'), nl,
    write('Start row: '), read(R1),
    write('Start column: '), read(C1),
    write('= To:'), nl,
    write('End row: '), read(R2),
    write('End column: '), read(C2),
    StartRow is R1 - 1,
    StartCol is C1 - 1,
    EndRow is R2 - 1,
    EndCol is C2 - 1.

playGame(Board, StartPlayer) :-
    ( es_game_over(state(Board, StartPlayer), Winner)
    ->
        printBoard(Board),
        nl, write('--- Player '), write(Winner), write(' wins! ---'), nl
    ;
        printBoard(Board),
        write('--- PLAYER '), write(StartPlayer), write(' ---'), nl,
        askPlayerMove(StartRow, StartCol, EndRow, EndCol),

        ( es_apply_move(state(Board, StartPlayer),
                        move(StartRow, StartCol, EndRow, EndCol),
                        state(NewBoard, NextPlayer))
        ->
            playGame(NewBoard, NextPlayer)
        ;
            nl, write('--- Invalid move! Try again.'), nl, nl,
            playGame(Board, StartPlayer)
        )
    ).

start(N, M, [XPiece1, XPiece2], [OPiece1, OPiece2], StartPlayer) :-
    initBoard(N, M, [XPiece1, XPiece2], [OPiece1, OPiece2], Board),
    playGame(Board, StartPlayer).




startAI(N, M, [XPiece1, XPiece2], [OPiece1, OPiece2], HumanSide,
        Algorithm, Depth) :-
    initBoard(N, M, [XPiece1, XPiece2], [OPiece1, OPiece2], Board),
    playGameAI(Board, HumanSide, Algorithm, Depth).

/* Atajo: alfa-beta con profundidad 3. */
startAI(N, M, XPieces, OPieces, HumanSide) :-
    startAI(N, M, XPieces, OPieces, HumanSide, 2, 3).

playGameAI(Board, HumanSide, Algorithm, Depth) :-
    playGameAIState(state(Board, x), HumanSide, Algorithm, Depth).

playGameAIState(State, HumanSide, Algorithm, Depth) :-
    ( es_game_over(State, Winner)
    ->
        es_show_state(State),
        format('--- Player ~w wins! ---~n', [Winner])
    ;
        es_show_state(State),
        es_current_player(State, Player),
        ( Player == HumanSide
        -> humanTurnAI(State, NextState)
        ;  aiTurn(State, Algorithm, Depth, NextState)
        ),
        playGameAIState(NextState, HumanSide, Algorithm, Depth)
    ).

humanTurnAI(State, NextState) :-
    askPlayerMove(StartRow, StartCol, EndRow, EndCol),
    Move = move(StartRow, StartCol, EndRow, EndCol),
    es_legal_moves(State, Moves),
    ( member(Move, Moves)
    ->
        es_apply_move(State, Move, NextState)
    ;
        nl, write('--- Invalid move! Try again.'), nl, nl,
        humanTurnAI(State, NextState)
    ).

aiTurn(State, Algorithm, Depth, NextState) :-
    write('--- Computer is thinking...'), nl,
    chooseAIMove(State, Algorithm, Depth, Move, Value),
    Move = move(StartRow, StartCol, EndRow, EndCol),
    format('--- Computer moves from (~w,~w) to (~w,~w). Score: ~w~n',
           [StartRow, StartCol, EndRow, EndCol, Value]),
    ai_node_count(Nodes),
    format('--- Nodes evaluated: ~w~n', [Nodes]),
    es_apply_move(State, Move, NextState).

chooseAIMove(State, 1, Depth, Move, Value) :-
    ai_best_move(State, Depth, Move, Value).
chooseAIMove(State, 2, Depth, Move, Value) :-
    ai_best_move_ab(State, Depth, Move, Value).
