:- module(helpers, [head/2, tail/2, myMax/3, myMin/3, myTranspose/2]).

% clasicele head si tail
head([], _) :- fail.
head([H|_], H).

tail([], []).
tail([_|T], T).

% Uniune pentru min si max
myMax(X, Y, R) :- R is max(X, Y).
myMin(X, Y, R) :- R is min(X, Y).

% alternativa transpose
myTranspose([[]|_], []).
myTranspose(Matrix, [H|T]) :-
	maplist(head, Matrix, H),		% prima coloana din matrice
	maplist(tail, Matrix, Rest),	% separa restul matricei
	myTranspose(Rest, T),			% apel recursiv pe restul matricei
	!.								% nu e nevoie de vreo resatisfacere