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
check(_,L,S,[],X) :-
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
	for_all(A,L,P,[],X),!.
% EX
check(A,L,S,[],ex(X)) :-
	find_state(S,A,P),
	exists(A,L,P,[],X),!.
% AG
check(_,_,S,U,ag(_)) :- 
	in_list(S,U),!.
check(A,L,S,U,ag(X)) :-
	check(A,L,S,[],X),
	find_state(S,A,P),
	for_all(A,L,P,[S|U],ag(X)),!.
% EG
check(_,_,S,U,eg(_)) :-
	in_list(S,U),!.
check(A,L,S,_,eg(X)) :-
	find_state(S,A,[]),!,
	check(A,L,S,[],X).
check(A,L,S,U,eg(X)) :-
	check(A,L,S,[],X),
	find_state(S,A,P),
	exists(A,L,P,[S|U],eg(X)),!.
% EF
% AF

% Helpers

% for_all(A,L,P,U,X)
% Verify that all states in P satisfies formula X.
for_all(_,_,[],_,_).
for_all(A,L,[H|T],U,X) :- check(A,L,H,U,X),for_all(A,L,T,U,X).

% exists(A,L,P,U,X)
% verify that at least one state of P satisfies formula X.
exists(_,_,[],_,_) :- fail.
exists(A,L,[H|_],U,X) :- check(A,L,H,U,X),!.
exists(A,L,[_|T],U,X) :- exists(A,L,T,U,X).

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
