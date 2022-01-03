:- module(operations, [print_table_op/1, join_op/5, select_op/3, filter_op/4]).

:- use_module(op_helpers).
:- use_module(helpers).

% calculeaza lungimea celui mai lung rand din tabel si se foloseste de aceasta
% pentru a afisa fiecare linie a lui in mod aferent (formatat)
print_table_op(Tbl) :- 	
	head(Tbl, Header), 				% ia capul de tabel
	length(Header, RowElems), 		% ii afla numarul de elemente
	elemList(0, RowElems, Acc), 	% acumulator pentru foldl

	calcLens(Tbl, LenLists), 		% lungimile randurilor

	foldl(listMaxAggr, LenLists, Acc, MaxRowLen), 	% lista finala de lungimi

	make_format_str(MaxRowLen, Str), 				% formam string-ul de format
	print_table_rows(Tbl, Str).


join_op(Op, NewCols, Tbl1, Tbl2, [NewCols|TblEntries]) :-
	tail(Tbl1, T1),
	tail(Tbl2, T2),
	maplist(Op, T1, T2, TblEntries). 	% aplica operatia asupra elementelor


select_op(Tbl, Cols, R) :-
	myTranspose(Tbl, Tbl2),				% transpune tabelu pentru a fi folosit de include
	include(is_col(Cols), Tbl2, Tbl3),	% pastram doar listele ce incep cu un header dorit
	myTranspose(Tbl3, R).				% restauram ordinea tabelului dupa apelul 'include'


filter_op(Tbl, Vars, Pred, [H|FilteredEntries]) :-
	head(Tbl, H),
	tail(Tbl, T),

	filter_op_aux(T, Vars, Pred, FilteredEntries). 	% aplicam filtrul
