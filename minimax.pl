

:- ensure_loaded('engine.pl').
:- use_module(library(lists)).
:- dynamic ai_nodes/1.



ai_count_node :-
    ( retract(ai_nodes(N)) -> N1 is N + 1 ; N1 = 1 ),
    assertz(ai_nodes(N1)).

ai_reset_nodes :-
    retractall(ai_nodes(_)),
    assertz(ai_nodes(0)).

ai_node_count(N) :-
    ( ai_nodes(N) -> true ; N = 0 ).

depth_exhausted(0).
dec_depth(Depth, D1) :-
    Depth == inf,
    !,
    D1 = inf.
dec_depth(Depth, D1) :-
    number(Depth),
    Depth > 0,
    D1 is Depth - 1.


ai_minimax_value(State, AI, Depth, Value) :-
    ai_count_node,
    ( es_game_over(State, Winner)
    -> ai_terminal_value(Winner, AI, Depth, Value)
    ; depth_exhausted(Depth)
    -> ai_evaluate(State, AI, Value)
    ; es_current_player(State, Player),
      dec_depth(Depth, D1),
      es_legal_moves(State, Moves),
      ( Moves == []
      -> opponent(Player, Winner),
         ai_terminal_value(Winner, AI, Depth, Value)
      ;  ai_minimax_children(Moves, State, AI, D1, Values),
         ( Player == AI -> max_list(Values, Value)
         ; min_list(Values, Value)
         )
      )
    ).

ai_minimax_children([], _, _, _, []).
ai_minimax_children([Move|Moves], State, AI, Depth, [V|Vs]) :-
    es_apply_move(State, Move, Child),
    ai_minimax_value(Child, AI, Depth, V),
    ai_minimax_children(Moves, State, AI, Depth, Vs).


ai_best_move(State, Depth, Move, Value) :-
    es_current_player(State, AI),
    es_legal_moves(State, Moves),
    Moves \= [],
    ai_reset_nodes,
    dec_depth(Depth, ChildDepth),
    choose_minimax_move(Moves, State, AI, ChildDepth, Move, Value).

choose_minimax_move([Move|Moves], State, AI, Depth, BestMove, BestValue) :-
    es_apply_move(State, Move, Child),
    ai_minimax_value(Child, AI, Depth, V),
    choose_minimax_rest(Moves, State, AI, Depth, Move, V,
                        BestMove, BestValue).

choose_minimax_rest([], _, _, _, Move, Value, Move, Value).
choose_minimax_rest([Move|Moves], State, AI, Depth,
                    CurrentMove, CurrentValue, BestMove, BestValue) :-
    es_apply_move(State, Move, Child),
    ai_minimax_value(Child, AI, Depth, V),
    ( V > CurrentValue
    -> NextMove = Move, NextValue = V
    ;  NextMove = CurrentMove, NextValue = CurrentValue
    ),
    choose_minimax_rest(Moves, State, AI, Depth,
                        NextMove, NextValue, BestMove, BestValue).


ai_alphabeta_value(State, AI, Depth, Alpha, Beta, Value) :-
    ai_count_node,
    ( es_game_over(State, Winner)
    -> ai_terminal_value(Winner, AI, Depth, Value)
    ; depth_exhausted(Depth)
    -> ai_evaluate(State, AI, Value)
    ; es_current_player(State, Player),
      dec_depth(Depth, D1),
      es_legal_moves(State, Moves),
      ( Moves == []
      -> opponent(Player, Winner),
         ai_terminal_value(Winner, AI, Depth, Value)
      ; Player == AI
      -> alphabeta_max(Moves, State, AI, D1, Alpha, Beta, -1000000, Value)
      ;  alphabeta_min(Moves, State, AI, D1, Alpha, Beta, 1000000, Value)
      )
    ).

alphabeta_max([], _, _, _, _, _, Value, Value).
alphabeta_max([Move|Moves], State, AI, Depth, Alpha, Beta, Current, Value) :-
    es_apply_move(State, Move, Child),
    ai_alphabeta_value(Child, AI, Depth, Alpha, Beta, V),
    Next is max(Current, V),
    NewAlpha is max(Alpha, Next),
    ( NewAlpha >= Beta
    -> Value = Next
    ;  alphabeta_max(Moves, State, AI, Depth, NewAlpha, Beta, Next, Value)
    ).

alphabeta_min([], _, _, _, _, _, Value, Value).
alphabeta_min([Move|Moves], State, AI, Depth, Alpha, Beta, Current, Value) :-
    es_apply_move(State, Move, Child),
    ai_alphabeta_value(Child, AI, Depth, Alpha, Beta, V),
    Next is min(Current, V),
    NewBeta is min(Beta, Next),
    ( Alpha >= NewBeta
    -> Value = Next
    ;  alphabeta_min(Moves, State, AI, Depth, Alpha, NewBeta, Next, Value)
    ).

ai_best_move_ab(State, Depth, Move, Value) :-
    es_current_player(State, AI),
    es_legal_moves(State, Moves),
    Moves \= [],
    ai_reset_nodes,
    dec_depth(Depth, ChildDepth),
    Moves = [First|Rest],
    es_apply_move(State, First, Child),
    ai_alphabeta_value(Child, AI, ChildDepth, -1000000, 1000000, FirstValue),
    choose_ab_rest(Rest, State, AI, ChildDepth, First, FirstValue,
                   -1000000, 1000000, Move, Value).

choose_ab_rest([], _, _, _, Move, Value, _, _, Move, Value).
choose_ab_rest([Candidate|Rest], State, AI, Depth, CurrentMove, CurrentValue,
               Alpha, Beta, BestMove, BestValue) :-
    es_apply_move(State, Candidate, Child),
    ai_alphabeta_value(Child, AI, Depth, Alpha, Beta, V),
    ( V > CurrentValue
    -> NextMove = Candidate, NextValue = V
    ;  NextMove = CurrentMove, NextValue = CurrentValue
    ),
    NewAlpha is max(Alpha, NextValue),
    choose_ab_rest(Rest, State, AI, Depth, NextMove, NextValue,
                   NewAlpha, Beta, BestMove, BestValue).
