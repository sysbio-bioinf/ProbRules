:- consult('../ProbRules.pl').
1.0 :: on.
0.0 :: off.
0.1 :: global_attack.
0.09:: local_attack1.
0.03:: local_attack2.
0.01:: local_attack3.
0.1 :: global_decay.
0.0 :: interaction(i,p).
0.0 :: interaction(x,xs).
0.0 :: interaction(x,y).
0.0 :: interaction(x,z).
0.0 :: interaction(x,w).
0.0 :: interaction(y,ys).
0.0 :: interaction(z,zs).
0.0 :: interaction(w,ws).
fixed(i,p,T) :- T>49, T<350, on.
fixed(i,p,_) :- off.
rule((x,xs),[(i,p)],global_attack,on,'xs').
rule((x,y),[(i,p),(x,xs)],local_attack1,on,'xy').
rule((x,z),[(i,p),(x,xs)],local_attack2,on,'xz').
rule((x,w),[(i,p),(x,xs)],local_attack3,on,'xw').
rule((y,ys),[(x,y)],global_attack,on,'ys').
rule((z,zs),[(x,z)],global_attack,on,'zs').
rule((w,ws),[(x,w)],global_attack,on,'ws').
:- evaluation(700).
:- halt.
