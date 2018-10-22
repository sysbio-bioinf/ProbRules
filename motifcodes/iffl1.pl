:- consult('../ProbRules.pl').
1.0 :: on.
0.0 :: off.
0.5 :: global_attack.
0.05:: local_attack.
0.5 :: global_decay.
0.0 :: interaction(i,p).
0.0 :: interaction(x,xs).
0.0 :: interaction(y,ys).
0.0 :: interaction(z,zs).
fixed(i,p,_) :- on.
rule((x,xs),[(i,p)],global_attack,on,'xs').
rule((y,ys),[(x,xs)],local_attack,on,'ys').
rule((z,zs),[(x,xs),not (y,ys)],global_attack,on,'zs').
:- evaluation(100).
:- halt.
