

:- ensure_loaded('board.pl').
:- ensure_loaded('move.pl').

opponent(x, o).
opponent(o, x).

es_current_player(state(_, Player), Player).

cell(Board, R, C, Value) :-
    nth0(R, Board, Row),
    nth0(C, Row, Value).


es_legal_moves(state(Board, Player), Moves) :-
    findall(move(R1,C1,R2,C2),
        ( cell(Board, R1, C1, Player),
          direction(DR, DC),
          R2 is R1 + DR,
          C2 is C1 + DC,
          movePiece(Board, pos(R1,C1), pos(R2,C2), Player, _)
        ),
        Moves).


es_apply_move(state(Board, Player), move(R1,C1,R2,C2),
              state(NewBoard, Next)) :-
    movePiece(Board, pos(R1,C1), pos(R2,C2), Player, NewBoard),
    opponent(Player, Next).

has_legal_move(state(Board, Player)) :-
    cell(Board, R1, C1, Player),
    direction(DR, DC),
    R2 is R1 + DR,
    C2 is C1 + DC,
    movePiece(Board, pos(R1,C1), pos(R2,C2), Player, _),
    !.

piece_on_row(Board, Player, R) :-
    nth0(R, Board, Row),
    memberchk(Player, Row).

es_game_over(state(Board, Player), Winner) :-
    length(Board, N),
    LastRow is N - 1,
    ( piece_on_row(Board, x, LastRow)
    -> Winner = x
    ;  piece_on_row(Board, o, 0)
    -> Winner = o
    ;  \+ has_legal_move(state(Board, Player))
    -> opponent(Player, Winner)
    ).

es_show_state(state(Board, Player)) :-
    nl,
    printBoard(Board),
    format('~nTurn of: ~w~n', [Player]).


es_advancement(x, R, _, R).
es_advancement(o, R, N, A) :-
    A is N - 1 - R.

player_progress(Board, Player, Score) :-
    length(Board, N),
    findall(A,
        ( nth0(R, Board, Row),
          member(Player, Row),
          es_advancement(Player, R, N, A)
        ),
        Advances),
    ( Advances = [] -> Score = 0 ; max_list(Advances, Score) ).

player_mobility(State, Player, Count) :-
    State = state(Board, _),
    es_legal_moves(state(Board, Player), Moves),
    length(Moves, Count).

count_blocked([], 0).
count_blocked(['#' | Rest], Count) :-
    !,
    count_blocked(Rest, Count1),
    Count is Count1 + 1.
count_blocked([_ | Rest], Count) :-
    count_blocked(Rest, Count).

blocked_goal_cells(Board, Player, Count) :-
    length(Board, N),
    es_goal_row(Player, N, GoalRow),
    nth0(GoalRow, Board, Row),
    count_blocked(Row, Count).


ai_evaluate(state(Board, _), AI, Value) :-
    opponent(AI, Opp),
    player_progress(Board, AI, MyProgress),
    player_progress(Board, Opp, OppProgress),
    player_mobility(state(Board, AI), AI, MyMobility),
    player_mobility(state(Board, Opp), Opp, OppMobility),
    blocked_goal_cells(Board, AI, MyBlocked),
    blocked_goal_cells(Board, Opp, OppBlocked),
    Value is 10 * (MyProgress - OppProgress)
             + 2 * (MyMobility - OppMobility)
             + 3 * (OppBlocked - MyBlocked).

ai_terminal_value(Winner, AI, Depth, Value) :-
    ( Winner == AI -> Sign = 1 ; Sign = -1 ),
    ( number(Depth) -> Bonus = Depth ; Bonus = 0 ),
    Value is Sign * (100000 + Bonus).

es_goal_row(x, N, GoalRow) :- GoalRow is N - 1.
es_goal_row(o, _, 0).
