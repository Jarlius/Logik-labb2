% For SICStus, uncomment line below: (needed for member/2)
% :- use_module(library(lists)).

% Load model, initial state and formula from file.
% To execute: consult(’your_file.pl’). verify(’input.txt’).
verify(Input) :-
see(Input), read(A), read(L), read(S), read(F), seen,
check(A, L, S, [], F).

% check(A, L, S, U, F).
% Should evaluate to true iff the sequent below is valid.
% (A,L), S |-u F
% A - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.

% Literals
check(_,L,S,_,X) :- 
	find_state(S,L,P),
	in_list(X,P),!.
% Neg
%check(_, L, S, [], neg(X)) :- ...
% And
%check(A, L, S, [], and(F,G)) :- ...
% Or
% AX
check(A,L,S,_,ax(X)) :-
	find_state(S,A,P),
	all_next(A,L,P,X),!.
% EX
check(A,L,S,_,ex(X)) :-
	find_state(S,A,P),
	exist_next(A,L,P,X),!.
% AG
% borde lägga till tom labellista här, som ska ge true samma som redan nådd
check(_,_,S,U,ag(_)) :- 
	in_list(S,U),!.
check(A,L,S,U,ag(X)) :-
	check(A,L,S,[],X),
	find_state(S,A,P),
	all_global(A,L,P,[S|U],X),!.
% EG
% EF
% AF

% Helpers

% all_global(A,L,P,U,X)
% Verify that all branches from list P satisfies X.
all_global(_,_,[],_,_).
all_global(A,L,[H|T],U,X) :- check(A,L,H,U,ag(X)),all_global(A,L,T,U,X).

% all_next(A,L,P,X)
% Verify that all states in P satisfies X.
all_next(_,_,[],_).
all_next(A,L,[H|T],X) :- check(A,L,H,[],X),all_next(A,L,T,X).

% exist_next(A,L,
% Verify that at least one state in P satisfies X.
exist_next(_,_,[],_) :- fail.
exist_next(A,L,[H|_],X) :- check(A,L,H,[],X),!.
exist_next(A,L,[_|T],X) :- exist_next(A,L,T,X).

% find_state(S,L,R)
% Find state S in list L, if it exists, and unify P with S's Property.
find_state(_,[],_) :- fail.
find_state(S,[[S,P]|_],P) :- !.
find_state(S,[_|T],P) :- find_state(S,T,P).

% in_list(X,L)
% Verify that element X is present in list L.
in_list(_,[]) :- fail.
in_list(X,[X|_]) :- !.
in_list(X,[_|T]) :- in_list(X,T).
