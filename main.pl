:- use_module(tables).
:- use_module(check_predicates).

:- use_module(anexa).
:- use_module(helpers).
:- use_module(op_helpers).
:- use_module(operations).


% leaga Tbl la tabelul sub forma de lista de lista
eval(table(Name), Tbl) :- table_name(Name, Tbl).


% leaga Tbl la tabelul rezultat in urma aplicarii operatiei Join asupra unor 2 tabele
eval(join(Op, NewCols, Query1, Query2), Tbl) :-
	eval(Query1, Tbl1),
	eval(Query2, Tbl2),
	join_op(Op, NewCols, Tbl1, Tbl2, Tbl).


% leaga Tbl la tabelul rezultat in urma aplicarii operatiei Select asupra unui tabel
eval(select(Cols, Query), Tbl) :-
	eval(Query, Tblq),
	select_op(Tblq, Cols, Tbl).


% leaga Tbl la tabelul rezultat in urma aplicarii unui filtru asupra unui tabel
eval(tfilter(Vars, Pred, Query), Tbl) :-
	eval(Query, Tblq),
	filter_op(Tblq, Vars, Pred, Tbl).


% aplica filtru cu... toate acele predicate interesante
eval(complex_query1(Query), Tbl) :-
	Vars = [_, LastName, AA, PP, PC, PA, POO],
	Pred = 	((AA + PP) / 2 > 6,						% formam predicatul
			(AA + PP + PC + PA + POO) / 5 > 5,
			sub_string(LastName, _, 4, 0, "escu")),

	eval(tfilter(Vars, Pred, Query), Tbl).			% ne folosim de eval


% aplica filtrul de categorie si rating pe tabelul de filme
eval(complex_query2(Genre, MinRating, MaxRating), Tbl) :-
	table_name('movies', Movies),				% tabelul de filme
	head(Movies, MoviesHead),
	tail(Movies, MoviesTail),
	complex_query2_sorted_ratings(MoviesTail, SortedRatings),	% obtine rating-urile sortate dupa movie_id

	table_name('ratings', Ratings),
	head(Ratings, RatingsHead),					% obtine header-ul pentru concatenare

	select_op([RatingsHead|SortedRatings], ["rating"], RatingsClean),	% doar cu rating

	append(MoviesHead, ["rating"], NewCols),						% noile coloane pentru concatenare
	join_op(append, NewCols, Movies, RatingsClean, MovieRatings),	% acum fiecare film are asociat rating-ul

	Vars = [_, _, GENRES, RATING],					% pregatim pentru filter
	Pred = (sub_string(GENRES, _, _, _, Genre),		% cautam categoria
			RATING >= MinRating,
			RATING =< MaxRating),
	filter_op(MovieRatings, Vars, Pred, Tbl).		% aplicam filtrul


% printare
eval(tprint(Query), Tbl) :-
	eval(Query, Tbl),
	print_table_op(Tbl).