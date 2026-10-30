/* creating empty table */

createRow(0, []) :- !.

createRow(M, [Head | Row1]) :-
    Head = '.',
    M1 is M-1,
    createRow(M1, Row1).

createTable(0, _, Table) :-
    Table = [], !.

createTable(_, 0, Table) :-
    Table = [], !.

createTable(N, M, [Row | Table1]) :-
    createRow(M, Row),
    N1 is N-1,
    createTable(N1, M, Table1).


/* setting value */

setVal(List, Idx, Val, NewList) :-
    nth0(Idx, List, _, Rest),
    nth0(Idx, NewList, Val, Rest).

setVal(Table, Row, Col, Val, NewTable) :-
    nth0(Row, Table, OldList, Rest),
    setVal(OldList, Col, Val, NewList),
    nth0(Row, NewTable, NewList, Rest).


/* printing board */

printRow([]) :- !.

printRow([Head | Tail]) :-
    write(Head), write(' '), printRow(Tail).

printRowWithIdx(Idx, Row) :-
    write(Idx), write(' '), printRow(Row), nl.

printNumbersRow(M) :-
    numlist(1, M, List),
    printRow(List), nl.


printBoard([]) :- !.

printBoard(Table) :-
    Table = [Row | _],
    length(Row, M),
    length(Table, N),
    numlist(1, N, IdxList),

    write('  '), printNumbersRow(M),
    maplist(printRowWithIdx, IdxList, Table).


/* table without headers ---- for testing */

printTable([]) :- !.

printTable([Row | Rest]) :-
    printRow(Row), nl,
    printTable(Rest).


/* initializing board */

initBoard(N, M, [XPiece1, XPiece2], [OPiece1, OPiece2], Board) :-
    N >= 2, M >= 2,
    LastRow is N-1,
    LastCol is M-1,

    XPiece1 \= XPiece2, OPiece1 \= OPiece2,
    XPiece1 >= 0, XPiece1 =< LastCol,
    XPiece2 >= 0, XPiece2 =< LastCol,
    OPiece1 >= 0, OPiece1 =< LastCol,
    OPiece2 >= 0, OPiece2 =< LastCol,

    createTable(N, M, EmptyBoard),
    setVal(EmptyBoard, 0, XPiece1, 'x', FirstBoard),
    setVal(FirstBoard, 0, XPiece2, 'x', SecondBoard),
    setVal(SecondBoard, LastRow, OPiece1, 'o', ThirdBoard),
    setVal(ThirdBoard, LastRow, OPiece2, 'o', Board).
