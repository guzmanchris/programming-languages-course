/* ------------------------------------- The different stores in the database ------------------------------------- */
store(best_smoothies, [alan,john,mary],
[ smoothie(berry, [orange, blueberry, strawberry], 2),
smoothie(tropical, [orange, banana, mango, guava], 3),
smoothie(blue, [banana, blueberry], 3) ]).
store(all_smoothies, [keith,mary],
[ smoothie(pinacolada, [orange, pineapple, coconut], 2),
smoothie(green, [orange, banana, kiwi], 5),
smoothie(purple, [orange, blueberry, strawberry], 2),
smoothie(smooth, [orange, banana, mango],1) ]).
store(smoothies_galore, [heath,john,michelle],
[ smoothie(combo1, [strawberry, orange, banana], 2),
smoothie(combo2, [banana, orange], 5),
smoothie(combo3, [orange, peach, banana], 2),
smoothie(combo4, [guava, mango, papaya, orange],1),
smoothie(combo5, [grapefruit, banana, pear],1) ]).

/* ---------------------------------------------- Required predicates --------------------------------------------- */

more_than_four(X) :- store(X,_,Smoothies), list_length(Smoothies, L), L>=4.

exists(X) :- store(_, _, Smoothies), member(smoothie(X,_,_),Smoothies).

/* The ratio "R" should be expressed as a decimal of a fraction with the unsimplified ratio. Eg: 0.5 or 2/4 is
   accepted for store "all_smoothies" but, 1/2 is not. */
ratio(X,R) :- store(X,Employees,Smoothies), list_length(Employees, E), list_length(Smoothies, S), (R==E/S; R is E/S).

average(X,A) :- store(X,_,Smoothies), price_sum(Smoothies,S), list_length(Smoothies,L), A is S/L.

/* -------------------------------------------- Helper predicates ------------------------------------------------- */

list_length([],0).
list_length([_|Rest],L ) :- list_length(Rest,N) , L is N+1 .

price_sum([], 0).
price_sum([smoothie(_,_,Price)|Rest],S) :- price_sum(Rest, N), S is N+Price.