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
check(_, L, S, [], X) :- 
	find_state(S,L,P),
	in_list(X,P),!.
% Neg
%check(_, L, S, [], neg(X)) :- ...
% And
%check(A, L, S, [], and(F,G)) :- ...
% Or
% AX
check(A,L,S,[],ax(X)) :-
	find_state(S,A,P),
	allnext(A,L,P,X),!.
% EX
check(A,L,S,[],ex(X)) :-
	find_state(S,A,P),
	exist_next(A,L,P,X),!.
% AG
% EG
% EF
% AF

% Helpers

% all_next(A,L,P,X)
% Verify that all states in P satisfies X.
allnext(_,_,[],_).
allnext(A,L,[H|T],X) :- check(A,L,H,[],X),allnext(A,L,T,X).

% exist_next(A,L,
% Verify that at least one state in P satisfies X.
exist_next(_,_,[],_) :- fail.
exist_next(A,L,[H|_],X) :- check(A,L,H,[],X),!.
exist_next(A,L,[_|T],X) :- exist_next(A,L,T,X).

% find_state(S,L,R)
% Find state S in list L, if it exists, and unify P with S's Property
find_state(_,[],_) :- fail.
find_state(S,[[S,P]|_],P) :- !.
find_state(S,[_|T],P) :- find_state(S,T,P).

% in_list(X,L)
% Verify that element X is present in list L
in_list(_,[]) :- fail.
in_list(X,[X|_]) :- !.
in_list(X,[_|T]) :- in_list(X,T).
