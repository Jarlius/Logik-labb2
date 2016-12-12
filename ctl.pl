% For SICStus, uncomment line below: (needed for member/2)
% :- use_module(library(lists)).

% Load model, initial state and formula from file.
% To execute: consult(’your_file.pl’). verify(’input.txt’).
verify(Input) :-
see(Input), read(T), read(L), read(S), read(F), seen,
check(T, L, S, [], F).

% check(T, L, S, U, F).
% Should evaluate to true iff the sequent below is valid.
% (T,L), S |-u F
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.

% Literals
check(_, L, S, [], X) :- 
	find_state(S,L,R),
	in_list(X,R).

%check(_, L, S, [], neg(X)) :- ...

% And
%check(T, L, S, [], and(F,G)) :- ...
% Or
% AX
% EX
% AG
% EG
% EF
% AF

% Helpers

% find_state(S,L,R)
% Find state S in list L, if it exists, and unify R with S's property
find_state(_,[],_) :- fail.
find_state(S,[[S,R]|_],R) :- !.
find_state(S,[_|T],R) :- find_state(S,T,R).

% in_list(X,L)
% Verify that element X is present in list L
in_list(_,[]) :- fail.
in_list(X,[X|_]) :- !.
in_list(X,[_|T]) :- in_list(X,T).
