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
check(A,L,S,[],neg(X)) :-
	check(A,L,S,[],X),!,fail.
check(_,_,_,[],neg(_)) :- !.
% And
check(A,L,S,[],and(F,G)) :-
	check(A,L,S,[],F),
	check(A,L,S,[],G),!.
% Or
check(A,L,S,[],or(F,_)) :-
	check(A,L,S,[],F),!.
check(A,L,S,[],or(_,G)) :-
	check(A,L,S,[],G),!.
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
% AF
check(_,_,S,U,af(_)) :-
	in_list(S,U),!,fail.
check(A,L,S,_,af(X)) :-
	check(A,L,S,[],X),!.
check(A,_,S,_,af(_)) :-
	find_state(S,A,[]),!,fail.
check(A,L,S,U,af(X)) :-
	find_state(S,A,P),
	for_all(A,L,P,[S|U],af(X)),!.
% EF
check(_,_,S,U,ef(_)) :-
	in_list(S,U),!,fail.
check(A,L,S,_,ef(X)) :-
	check(A,L,S,[],X),!.
check(A,L,S,U,ef(X)) :-
	find_state(S,A,P),
	exists(A,L,P,[S|U],ef(X)).

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
