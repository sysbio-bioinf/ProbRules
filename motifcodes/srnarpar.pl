:- consult('../ProbRules.pl').

1.0 :: on.
0.0 :: off.
0.1 :: global_decay.

0.1 :: sr_rate.
0.3 :: nar_rate.
0.03:: par_rate.

0.0 :: interaction(s,r).
0.0 :: interaction(n,ar).
0.0 :: interaction(p,ar).

rule((s,r),[],sr_rate,on,'sr activation').

rule((n,ar),[],nar_rate,on,'nar activation').
rule((n,ar),[not (n,ar)],nar_rate,on,'nar autoregulation').

rule((p,ar),[],par_rate,on,'positive autoregulation activation').
rule((p,ar),[(p,ar)],par_rate,on,'positive autoregulation').

:- evaluation(100).
:- halt.
