:- ensure_loaded('board.pl').

/* conditions of moving a piece */

direction(-1, 0).   % up
direction(1, 0).    % down
direction(0, -1).   % left
direction(0, 1).    % right
direction(-1, -1).  % up-left
direction(1, -1).   % down-left
direction(-1, 1).   % up-right
direction(1, 1).    % down-right


checkPosition(Board, Row, Col, Sign) :-
    nth0(Row, Board, OldList, _),
    nth0(Col, OldList, Val, _),
    Val = Sign, !.

checkBoarders(Board, Row, Col) :-
    Board = [FirstLine | _],
    length(FirstLine, M),
    length(Board, N),
    LastRow is N-1,
    LastCol is M-1,

    Row >= 0, Row =< LastRow,
    Col >= 0, Col =< LastCol.

checkMove(Board, pos(StartRow, StartCol), pos(EndRow, EndCol), PlayerSign) :-
    checkPosition(Board, StartRow, StartCol, PlayerSign),
    DifRow is EndRow - StartRow,
    DifCol is EndCol - StartCol,
    direction(DifRow, DifCol),

    checkBoarders(Board, EndRow, EndCol),
    checkPosition(Board, EndRow, EndCol, '.'), !.


/* moving piece */

movePiece(Board, pos(StartRow, StartCol), pos(EndRow, EndCol), PlayerSign, NewBoard) :-
    checkMove(Board, pos(StartRow, StartCol), pos(EndRow, EndCol), PlayerSign),
    setVal(Board, StartRow, StartCol, '#', SemiBoard),
    setVal(SemiBoard, EndRow, EndCol, PlayerSign, NewBoard).
