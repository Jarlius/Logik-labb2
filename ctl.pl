% Load model, initial state and formula from file.
% To execute: consult(’your_file.pl’). verify(’input.txt’).
verify(Input) :-
see(Input), read(T), read(L), read(S), read(F), seen,
check(T, L, S, [], F).

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
check(T,L,S,[],neg(X)) :-
	check(T,L,S,[],X),!,fail.
check(_,_,_,[],neg(_)) :- !.
% And
check(T,L,S,[],and(F,G)) :-
	check(T,L,S,[],F),
	check(T,L,S,[],G),!.
% Or
check(T,L,S,[],or(F,_)) :-
	check(T,L,S,[],F),!.
check(T,L,S,[],or(_,G)) :-
	check(T,L,S,[],G),!.
% AX
check(T,L,S,[],ax(X)) :-
	find_state(S,T,P),
	for_all(T,L,P,[],X),!.
% EX
check(T,L,S,[],ex(X)) :-
	find_state(S,T,P),
	exists(T,L,P,[],X),!.
% AG
check(_,_,S,U,ag(_)) :- 
	in_list(S,U),!.
check(T,L,S,U,ag(X)) :-
	check(T,L,S,[],X),
	find_state(S,T,P),
	for_all(T,L,P,[S|U],ag(X)),!.
% EG
check(_,_,S,U,eg(_)) :-
	in_list(S,U),!.
check(T,L,S,_,eg(X)) :-
	find_state(S,T,[]),!,
	check(T,L,S,[],X).
check(T,L,S,U,eg(X)) :-
	check(T,L,S,[],X),
	find_state(S,T,P),
	exists(T,L,P,[S|U],eg(X)),!.
% AF
check(_,_,S,U,af(_)) :-
	in_list(S,U),!,fail.
check(T,L,S,_,af(X)) :-
	check(T,L,S,[],X),!.
check(T,_,S,_,af(_)) :-
	find_state(S,T,[]),!,fail.
check(T,L,S,U,af(X)) :-
	find_state(S,T,P),
	for_all(T,L,P,[S|U],af(X)),!.
% EF
check(_,_,S,U,ef(_)) :-
	in_list(S,U),!,fail.
check(T,L,S,_,ef(X)) :-
	check(T,L,S,[],X),!.
check(T,L,S,U,ef(X)) :-
	find_state(S,T,P),
	exists(T,L,P,[S|U],ef(X)).

% Helpers

% for_all(T,L,P,U,X)
% Verify that all states in P satisfies formula X.
for_all(_,_,[],_,_).
for_all(T,L,[Head|Tail],U,X) :- check(T,L,Head,U,X),for_all(T,L,Tail,U,X).

% exists(T,L,P,U,X)
% verify that at least one state of P satisfies formula X.
exists(_,_,[],_,_) :- fail.
exists(T,L,[Head|_],U,X) :- check(T,L,Head,U,X),!.
exists(T,L,[_|Tail],U,X) :- exists(T,L,Tail,U,X).

% find_state(S,L,R)
% Find state S in list L, if it exists, and unify P with S's Property.
find_state(_,[],_) :- fail.
find_state(S,[[S,P]|_],P) :- !.
find_state(S,[_|Tail],P) :- find_state(S,Tail,P).

% in_list(X,L)
% Verify that element X is present in list L.
in_list(_,[]) :- fail.
in_list(X,[X|_]) :- !.
in_list(X,[_|Tail]) :- in_list(X,Tail).
