:- module(op_helpers, [listMaxAggr/3, elemList/3, calcRowLen/2, calcLens/2,
			print_table_rows/2, is_col/2, filter_op_aux/4, complex_query2_sorted_ratings/2]).

:- use_module(helpers).


% PENTRU PRINTARE

% leaga List la lista obtinuta prin aplicarea lui maplist cu max
listMaxAggr(X, Y, List) :- maplist(myMax, X, Y, List).

% leaga List la o lista de lungime Len, umpluta cu elemente egale cu Elem
elemList(Elem, Len, List) :- length(List, Len), maplist(=(Elem), List).

% leaga LenList la o lista de lungimi ale elementelor
% (reprezentate ca string) din List
calcRowLen(List, LenList) :- maplist(string_length, List, LenList).

% leaga LenLists la o lista de liste de lungimi ale randurilor lui Tbl
calcLens(Tbl, LenLists) :- maplist(calcRowLen, Tbl, LenLists).

% avand un tabel si un string de format, afiseaza fiecare linie a acestuia
print_table_rows([], _).
print_table_rows(Tbl, Str) :-
	head(Tbl, H),
	tail(Tbl, T),

	format(Str, H),
	print_table_rows(T, Str). % apel recursiv


% PENTRU SELECT

% Verifica daca primul element dintr-o lista (Row) apartine lui Cols
is_col(Cols, Row) :- head(Row, H), member(H, Cols).


% PENTRU FILTER

% Trece recursiv prin fiecare element din Entries si leaga R la lista
% ce contine elementele din Entries care satisfac scopul dat
filter_op_aux([], _, _, []).
filter_op_aux(Entries, Vars, Pred, R) :-
	head(Entries, H),					% lucram cu acest rand
	tail(Entries, T),

	not((Vars = H,						% legam randul la domeniul scopului
		Pred)),							% testam scopul
	filter_op_aux(T, Vars, Pred, R), 	% apel recursiv pentru restul tabelului
	!.									% oprim resatisfacerea
filter_op_aux(Entries, Vars, Pred, [H|R]) :-
	head(Entries, H),
	tail(Entries, T),

	filter_op_aux(T, Vars, Pred, R).	% apel recursiv pentru restul tabelului


% PENTRU COMPLEX QUERY

% leaga al doilea element la la tabelul Ratings ce are campurile
% "movie_id" si "rating" sortate dupa "movie_id"
complex_query2_sorted_ratings([], []).
complex_query2_sorted_ratings(Movies, [RatingEntry|R]) :-
	head(Movies, H),
	tail(Movies, T),

	head(H, MovieID),												% extrage campul "movie_id"
	Vars = [_, _, ID, _],
	Pred = (ID = MovieID),
	eval(tfilter(Vars, Pred, table('ratings')), [_,RatingEntry]),	% extrage randul aferent

	complex_query2_sorted_ratings(T, R),							% apel recursiv pe restul filmelor
	!.