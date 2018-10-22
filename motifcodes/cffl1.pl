:- consult('../ProbRules.pl').
1.0 :: on.
0.0 :: off.
0.05:: global_attack.
0.005::local_attack.
0.05:: global_decay.
0.0 :: interaction(i,p).
0.0 :: interaction(x,xs).
0.0 :: interaction(y,ys).
0.0 :: interaction(z,zs).
fixed(i,p,T) :- T>4, T<55, on.
fixed(i,p,T) :- T>199, T<600, on.
fixed(i,p,_) :- off.
rule((x,xs),[(i,p)],global_attack,on,'xs').
rule((y,ys),[(x,xs)],local_attack,on,'ys').
rule((z,zs),[(x,xs),(y,ys)],global_attack,on,'zs').
:- evaluation(800).
:- halt.
