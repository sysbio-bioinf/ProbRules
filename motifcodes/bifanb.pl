:- consult('../ProbRules.pl').
1.0 :: on.
0.0 :: off.
0.1 :: global_attack.
0.001::local_attack.
0.1 :: global_decay.
0.0 :: interaction(i,p).
0.0 :: interaction(x,xs).
0.0 :: interaction(y,ys).
0.0 :: interaction(x,z).
0.0 :: interaction(x,w).
0.0 :: interaction(y,z).
0.0 :: interaction(y,w).
0.0 :: interaction(z,zs).
0.0 :: interaction(w,ws).
fixed(i,p,T) :- T>4, T<155, on.
fixed(i,p,_) :- off.
rule((x,xs),[(i,p)],global_attack,on,'xs').
rule((y,ys),[(i,p)],global_attack,on,'ys').
rule((x,z),[(x,xs)],global_attack,on,'xz').
rule((x,w),[(x,xs)],local_attack,on,'xw').
rule((y,z),[(y,ys)],local_attack,on,'yz').
rule((y,w),[(y,ys)],global_attack,on,'yw').
rule((z,zs),[(x,z),not (y,z)],global_attack,on,'zs').
rule((w,ws),[(y,w),    (x,w)],global_attack,on,'ws').
:- evaluation(250).
:- halt.
