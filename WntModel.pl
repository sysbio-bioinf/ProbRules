%%% ------------
%%% Wnt Rule Set
%%% ------------

:- consult('ProbRules.pl').

% Target probabilities for the rules:
1.0 :: on.
0.0 :: off.

% Global attack and decay rates:
0.15:: syn_rate.
0.6 :: global_attack.
0.3 :: global_decay.

% Parameters for perturbations:
%	(required only for the simulation of perturbations,
%	i.e. knockdown, inhibition, or constitutive
%	activation)
0.0 :: knockdown.
0.0 :: inhibition.
1.0 :: constact.


% -----------------------------------------------------------


%% Definition of interactions
%	with their initial probabilities (used for decay)


%%% Wnt/beta-catenin branch %%%

0.0 :: interaction(ligand,wnt).
0.0 :: interaction(wnt,fz). 
0.0 :: interaction(wnt,lrp).

0.0 :: interaction(lrp,lrpp).
0.0 :: interaction(ga,gtp).
0.0 :: interaction(ga,dsh).
0.0 :: interaction(gbg,gbg).
0.0 :: interaction(dsh,dshp).
0.0 :: interaction(bcat,e123).
0.0 :: interaction(bcat,bcatub).
0.0 :: interaction(dshp,axin).
0.0 :: interaction(axin,pp1).
0.0 :: interaction(dsh,gbp).
0.0 :: interaction(gbp,gsk3).

1.0 :: interaction(new,bcat).
0.5 :: interaction(bcat,bcat).
0.0 :: interaction(bcat,bcatfree).
0.0 :: interaction(bcat,lef).
0.0 :: interaction(lef,dna).
 
% RULE 1: In absence of Wnt, Fz does not interact with LRP.
0.0 :: interaction(fz,lrp).

% RULE 2: In absence of Wnt, Fz interacts with GaGDP and Gbg.
1.0 :: interaction(fz,ga).
1.0 :: interaction(fz,gbg).
1.0 :: interaction(ga,gdp).
1.0 :: interaction(ga,gbg).

% RULE 3: In absence of Wnt, LRP does not interact with axin.
0.0 :: interaction(lrp,axin).

% RULE 4: In absence of Wnt, LRP does not interact with CKIg
%	or GSK3.
0.0 :: interaction(lrp,ck1g).
0.0 :: interaction(lrp,gsk3).

% RULE 5: In absence of Wnt, dsh does not interact with Fz.
0.0 :: interaction(fz,dsh).

% RULE 6: In the absence of Wnt, formation of the destruction complex
%	can be initialised in the cytosol.
1.0 :: interaction(gsk3,axin).
1.0 :: interaction(axin,ck1a).
0.5 :: interaction(axin,apc).
0.5 :: interaction(apc,gsk3).
0.5 :: interaction(axin,bcat).
0.5 :: interaction(apc,bcat).
0.5 :: interaction(gsk3,bcat).
0.5 :: interaction(ck1a,bcat).

0.0 :: interaction(apc,apcp).    
0.0 :: interaction(axin,axinp).  
0.0 :: interaction(bcat,bcatp).
0.0 :: interaction(bcat,bcatpp). 


%%% Wnt/JNK branch %%%

0.0 :: interaction(ligandj,wntj).
0.0 :: interaction(wntj,fzj).
0.0 :: interaction(wntj,ror2).
0.0 :: interaction(pkcd,dshj).
0.0 :: interaction(dshj,dshjpp).
0.0 :: interaction(dshj,rac).

0.0 :: interaction(gaj,gtp).
0.0 :: interaction(gaj,dshj).
0.0 :: interaction(gbgj,gbgj).
0.0 :: interaction(gbgj,plcbj).
0.0 :: interaction(plcbj,dag).
0.0 :: interaction(dag,pkcd).
0.0 :: interaction(pkcd,pkcdp).

0.0 :: interaction(rac,bcat).
0.0 :: interaction(rac,jnk1).
0.0 :: interaction(rac,jnk2).
0.0 :: interaction(jnk1,jnk1p).
0.0 :: interaction(jnk2,jnk2p).
0.0 :: interaction(jnk2,bcat).
0.0 :: interaction(jnk1,gsk3).
0.0 :: interaction(jnk1,bcat).

% RULE j1: In absence of Wnt, dsh does not interact with Fz.
0.0 :: interaction(fzj,dshj).

% RULE j2: In absence of Wnt, Fz does not interact with Ror2.
0.0 :: interaction(fzj,ror2).

% RULE j3: In absence of Wnt, Fz interacts with GaGDP and
%	Gbg.
1.0 :: interaction(fzj,gaj).
1.0 :: interaction(fzj,gbgj).
1.0 :: interaction(gaj,gbgj).
1.0 :: interaction(gaj,gdp).

% RULE j4: In absence of Wnt, part of the Rac-GTPases is
%	already present in the active, GTP-bound form.
0.5 :: interaction(rac,gtp).
0.5 :: interaction(rac,gdp).


% ------------------------------------------

% INPUT signal

%%% Wnt/beta-catenin branch %%%

fixed(ligand,wnt,T) :- T> 75, T< 150, on.

%%% Wnt/JNK branch %%%

fixed(ligandj,wntj,T) :- T> 75, T< 150, on.

% -------------------------------------------


% This rules replace the default decay for input interactions.
0.02 :: slow_attack.
rule((ligand,wnt),[(ligand,wnt)],slow_attack,off,'input decay canonical').
rule((ligandj,wntj),[(ligandj,wntj)],slow_attack,off,'input decay jnk').


%% --------
%% RULE SET
%% --------
% Rules are defined as:
%	rule ((target interaction), [source interaction(s)],
%	attack rate, target probability, label).


%%% Rules Wnt/beta-catenin %%%

% RULE 7a: If GSK3 interacts with axin and axin interacts
%	with APC, APC interacts with GSK3.
rule((apc,gsk3),[(gsk3,axin),(axin,apc)],
	global_attack,on,'7a').

% RULE 7b: If GSK3 interacts with axin & APC and axin
%	interacts with APC, APC is phosphorylated (by
%	GSK3) to form APCp [=APC*].
rule((apc,apcp),[(gsk3,axin),(axin,apc),(apc,gsk3)],
	global_attack,on,'7b').
 
% RULE 7c: Phosphorylated APCp interacts with axin and
%	b-catenin. (interaction probabilities up to 1)
rule((apc,bcat),[(apc,apcp),(bcat,bcat)],global_attack,on,'7c_1').
rule((axin,apc),[(apc,apcp)],global_attack,on,'7c_2').

% RULE 7d: If GSK3 interacts with axin,
%	 axin is transferred into axinp [=axin*].
rule((axin,axinp),[(gsk3,axin)],global_attack,on,'7d').

% RULE 7e: If APCp interacts with b-catenin, then b-catenin can interact
%	with	phosphorylated axin. 
% 		Remark: These steps describe the formation of the "mature"
%		destruction complex.)
rule((axin,bcat),[(apc,bcat),(apc,apcp),(axin,axinp),(bcat,bcat)],
	global_attack,on,'7d_1').
rule((axin,bcat),[not (axin,axinp), (axin,pp1)],global_attack,off,'7d_2').  


% RULE 8a: If CK1a interacts with axin and axin interacts
%	with b-catenin, then CK1a interacts with b-catenin.
rule((ck1a,bcat),[(axin,ck1a),(axin,bcat),(axin,axinp),(bcat,bcat)],
	global_attack,on,'8a').
       
% RULE 8b: If CK1a interacts with b-catenin,
%	then b-catenin is modified to form b-catp [=b-cat*]
% 	(that is CK1a phosphorylates b-catenin).
%		Remark: Formation of b-catp has no influence on other 
%		interactions in the destruction complex.
rule((bcat,bcatp),[(ck1a,bcat),(bcat,bcat)],global_attack,on,'8b').

% RULE 8c: In the presence of the mature destruction complex, GSK3 can 
%	interact with b-catp and modify it into b-catpp [=b-cat**]
%	(that is GSK phosphorylates b-catp a total of three times).
rule((gsk3,bcat),[(axin,axinp),(axin,bcat),(axin,apc),(apc,bcat),
	(apc,gsk3),(bcat,bcat)],global_attack,on,'8c_1').
rule((bcat,bcatpp),[(gsk3,bcat),(bcat,bcatp),(bcat,bcat)],
	global_attack,on,'8c_2').

% RULE 8d: If b-catpp is formed, b-catpp can interact with
%	E1/2/3.
rule((bcat,e123),[(bcat,bcatpp),(gsk3,bcat),(bcat,bcat)],
	global_attack,on,'8d').

% RULE 8e: If b-catpp interacts with E1/2/3,
%	b-catpp is modified into b-catUb.
rule((bcat,bcatub),[(bcat,e123),(bcat,bcatpp)],global_attack,on,'8e').

% RULE 8f: b-CatUb is degraded,
%	therefore b-catenin cannot accumulate.
rule((bcat,bcatfree),[(bcat,bcatub),(bcat,e123)],global_attack,off,'8f').
rule((bcat,bcat),[(bcat,bcatub),(bcat,e123)],global_attack,off,'8f').
        

% RULE 9: If b-catenin is accumulating and interacts with
%	JNK2, b-catenin can be translocated in the nucleus
%	and interact with Lef.
rule((bcat,lef),[(bcat,bcatfree),(jnk2,bcat)],
	global_attack,on,'9').
     
% RULE 10: If b-catenin in the nucleus interacts with Lef,
%	Lef interacts with the DNA.
rule((lef,dna),[(bcat,lef)],global_attack,on,'10').

% RULE 11: In presence of Wnt, Wnt, Fz and LRP form a
%	trimeric complex.
rule((wnt,fz),[(ligand,wnt)],global_attack,on,'11_1').
rule((wnt,lrp),[(ligand,wnt)],global_attack,on,'11_2').
rule((fz,lrp),[(ligand,wnt)],global_attack,on,'11_3').

% RULE 12: If Wnt interacts with LRP, LRP interacts with CK1g
%	and GSK3.
rule((lrp,ck1g),[(wnt,lrp)],global_attack,on,'12_1').
rule((lrp,gsk3),[(wnt,lrp)],global_attack,on,'12_2').
       
% RULE 13: If LRP interacts with CK1g/GSK3, LRP
%	is modified and activated to form LRPp [=LRP*].
rule((lrp,lrpp),[(lrp,ck1g),(lrp,gsk3)],
	global_attack,on,'13').

% RULE 14a: If the trimeric complex of Wnt, Fz, and LRP is
%	 formed, GaGDP is transfered into GaGTP. Gbg still
%	 interacts with Ga at this step (see RULE 2).
rule((ga,gdp),[(wnt,fz),(wnt,lrp),(fz,lrp),(fz,ga),(fz,gbg)],
	global_attack,off,'14a_1').
rule((ga,gtp),[(wnt,fz),(wnt,lrp),(fz,lrp),(fz,ga),(fz,gbg)],
	global_attack,on,'14a_2').

% RULE 14b: If Ga is transfered into GaGTP,
%	G dissociates into GaGTP and Gbg. 
%	Both leave the Fz receptor.
rule((ga,gbg),[(ga,gtp)],global_attack,off,'14b_1').
rule((fz,gbg),[(ga,gtp)],global_attack,off,'14b_2').
rule((fz,ga),[(ga,gtp)],global_attack,off,'14b_3').
rule((gbg,gbg),[(ga,gtp)],global_attack,on,'14b_4').

% RULE 15a: GaGTP is hydrolyzed to GaGDP.
rule((ga,gdp),[(ga,gtp)],global_attack,on,'15a_1').
rule((ga,gtp),[(ga,gtp)],global_attack,off,'15a_2').

% RULE 15b: Inactivated GaGDP interacts with Gbg and Fz.
rule((fz,ga),[(ga,gdp)],global_attack,on,'15b_1').
rule((fz,gbg),[(ga,gdp)],global_attack,on,'15b_2').

% RULE 16a: If active GaGTP is released,
%	GaGTP interacts with dsh.
rule((ga,dsh),[(ga,gtp)],global_attack,on,'16a').

% RULE 16b: If GaGTP interacts with dsh,
%	dshp [=dsh*] is formed (this likely involves CK1e).
rule((dsh,dshp),[(ga,dsh)],global_attack,on,'16b').
    
% RULES 17 & 18: In presence of Wnt,
%	the destruction complex is not formed.
        
% RULE 17a: If dshp is formed, dshp interacts with axin.
rule((dshp,axin),[(dsh,dshp)],global_attack,on,'17a').
       
% RULE 17b: If dshp is formed, dshp can interact with GBP.
rule((dsh,gbp),[(dsh,dshp)],global_attack,on,'17b').
       
% RULE 17c: If dshp interacts with axin and GBP,
%	GBP interacts with GSK3.
rule((gbp,gsk3),[(dsh,dshp),(dshp,axin),(dsh,gbp)],
	global_attack,on,'17c').
  
% RULE 17d: If GSK3 interacts with GBP, then GSK3 does
%	 not interact with axin, APC or b-catenin.
rule((gsk3,axin),[(gbp,gsk3)],global_attack,off,'17d_1').
rule((apc,gsk3),[(gbp,gsk3)],global_attack,off,'17d_2').
rule((gsk3,bcat),[(gbp,gsk3)],global_attack,off,'17d_3').

% RULE 17e: If the destruction is inhibited and b-catenin is not degraded,
%	 b-catenin can accumulate.
%	 Remark: RULE 17e now also assumes
%	 a positive influence of Rac on the amount of free
%	 b-catenin, that is necessary for the model to fit
%	 the experimental data obtained in this study.
rule((bcat,bcatfree),[(bcat,bcat),not (gsk3,bcat),
	not (axin,bcat),(rac,bcat)],global_attack,on,'17e').
	
% RULE 18a: If dshp is formed, dshp can interact with Fz.
rule((fz,dsh),[(dsh,dshp)],global_attack,on,'18a').

% RULE 18b: If phoshorylated axin interacts with phosphorylated dshp,
%	 axin can interact with phosphoryleted LRPp.
rule((lrp,axin),[(lrp,lrpp),(axin,axinp),(dshp,axin),not (axin,pp1)],
	global_attack,on,'18b_1').
rule((lrp,axin),[not (axin,axinp), (axin,pp1)],global_attack,off,'18b_2').

       
% RULE 18c: If dshp interacts with Fz and axin, and LRPp interacts with Fz
%	 ans axin, then axin interacts with protein phosphatase-1 (PP1).
rule((axin,pp1),[(dsh,dshp),(fz,dsh),(dshp,axin),
	(lrp,axin),(fz,lrp)],global_attack,on,'18c').

% RULE 18d: If phosphorylated axin interacts with protein phosphatase 1,
%	axin is dephosphorylated (i.e. it can not interact with b-catenin).
%		Remark: Consequence of RULE 18d is, that b-catenin accumulates;
%		RULES 9 and 10 will become effective!!!
rule((axin,axinp),[(axin,pp1),(lrp,axin)],global_attack,off,'18d').


% RULE 19: If one of the scaffold proteins axin or APC is
%	missing, no destruction complex can be formed.
rule((apc,bcat),[not (axin,bcat),not (axin,apc),
	not (gsk3,axin),not (axin,ck1a)],
	global_attack,off,'19_1').
rule((gsk3,bcat),[not (axin,bcat),not (axin,apc),
	not (gsk3,axin),not (axin,ck1a)],
	global_attack,off,'19_2').
rule((ck1a,bcat),[not (axin,bcat),not (axin,apc),
	not (gsk3,axin),not (axin,ck1a)],
	global_attack,off,'19_3').
rule((axin,bcat),[not (apc,bcat),not (axin,apc),
	not (apc,gsk3)], global_attack,off,'19_4').
rule((gsk3,bcat),[not (apc,bcat),not (axin,apc),
	not (apc,gsk3)],global_attack,off,'19_5').  
rule((ck1a,bcat),[not (apc,bcat),not (axin,apc),
	not (apc,gsk3)],global_attack,off,'19_6').


% RULE 20: If b-catenin accumulates, the high b-catenin concentration 
%	will re-activate the destruction complex.
%		Remark: In this way the b-catenin concentration
%		can be kept in check.
rule((gsk3,bcat),[(bcat,bcatfree)],global_attack,on,'20_1').
rule((axin,bcat),[(bcat,bcatfree)],global_attack,on,'20_2').
rule((ck1a,bcat),[(bcat,bcatfree)],global_attack,on,'20_3').
rule((apc,bcat),[(bcat,bcatfree)],global_attack,on,'20_4').


% RULE 21: Independet of the presence or absence of Wnt,
%	b-catenin is newly snthesized. 
rule((bcat,bcat),[(new,bcat)],syn_rate,on,'21').

%%% Rules Wnt/JNK %%%
       
% RULE j5: In the presence of Wnt, Wnt interacts with
%	Fz and Ror2.
rule((wntj,fzj),[(ligandj,wntj)],global_attack,on,'j5_1').
rule((wntj,ror2),[(ligandj,wntj)],global_attack,on,'j5_2').
       
% RULE j6a: If Wnt interacts with Fz, GaGDP is transferred
%	into GaGTP. Gbg still interacts with Ga at this
%	step.
rule((gaj,gdp),[(wntj,fzj),(fzj,gaj),(fzj,gbgj)],
	global_attack,off,'j6a_1').
rule((gaj,gtp),[(wntj,fzj),(fzj,gaj),(fzj,gbgj)],
	global_attack,on,'j6a_2').
       
% RULE j6b: If GaGDP is transfered into GaGTP,
%	G dissociates into GaGTP and Gbg.
%	Both leave the receptor.
rule((gaj,gbgj),[(gaj,gtp)],global_attack,off,'j6b_1').
rule((fzj,gbgj),[(gaj,gtp)],global_attack,off,'j6b_2').
rule((fzj,gaj),[(gaj,gtp)],global_attack,off,'j6b_3').
rule((gbgj,gbgj),[(gaj,gtp)],global_attack,on,'j6b_4').


% RULE j7a: GaGTP is hydrolyzed to GaGDP.
rule((gaj,gdp),[(gaj,gtp)],global_attack,on,'j7a_1').
rule((gaj,gtp),[(gaj,gtp)],global_attack,off,'j7a_2').

% RULE j7b: Inactivated GaGDP interacts with Gbg and Fz.
rule((fzj,gaj),[(gaj,gdp)],global_attack,on,'j7b_1').
rule((fzj,gbgj),[(gaj,gdp)],global_attack,on,'j7b_2').


% RULE j8: If active GaGTP is released,
%	GaGTP interacts with dsh.
rule((gaj,dshj),[(gaj,gtp)],global_attack,on,'j8').

% RULE j9: If G dissociates into GaGTP and Gbg,
%	released Gbg can interact with PLCb.
rule((gbgj,plcbj),[(gaj,gtp),(gbgj,gbgj)],
	global_attack,on,'j9').
       
% RULE j10: If free Gbg interacts with and activates PLCb,
%	PLCb forms DAG.
rule((plcbj,dag),[(gbgj,plcbj)],global_attack,on,'j10').

% RULE j11a: DAG can interact with PKCd.
rule((dag,pkcd),[(plcbj,dag)],global_attack,on,'j11a').
% RULE j11b: If DAG interacts with PKCd,
%	 PKCd is activated to form PKCdp [=PKCd*].
rule((pkcd,pkcdp),[(plcbj,dag),(dag,pkcd)],
	global_attack,on,'j11b').
       
% RULE j12: If PKCd is activated by DAG to form PKCdp,
%	 PKCd can interact with dsh.
rule((pkcd,dshj),[(dag,pkcd),(pkcd,pkcdp)],
	global_attack,on,'j12_1').

% RULE j13: If Wnt interacts with Fz and Rror2,
%	 Ror2 interacts with Fz.
rule((fzj,ror2),[(wntj,fzj),(wntj,ror2)],
	global_attack,on,'j13').
       
% RULE j14: If Fz interacts with Ror2, Fz interacts with dsh.
rule((fzj,dshj),[(fzj,ror2)],global_attack,on,'j14').
       
% RULE j15: If dsh interacts with Fz and dsh interacts with
%	GaGTP and dsh interacts with PKCdp,
%	dsh is activated to form dshpp [=dsh**].
rule((dshj,dshjpp),[(fzj,dshj),(gaj,dshj),(pkcd,dshj)],
	global_attack,on,'j12_2').
       
% RULE j16: If dshpp is formed, dsh can interact with Rac.
rule((dshj,rac),[(dshj,dshjpp)],global_attack,on,'j12_3').

% RULE j17a: If dsh interacts with Rac, Rac is activated to
%	form RacGTP.
rule((rac,gtp),[(dshj,rac)],global_attack,on,'j17a_1').
rule((rac,gdp),[(dshj,rac)],global_attack,off,'j17a_2').
       
% RULE j17b: Only active, GTP-bound Rac can interact with
%	JNK1 and JNK2 and influence b-catenin.
%	Remark: RULE j17b includes a hypothetical
%	connection from Rac to b-catenin (possibly
%	via DOCK4, but not including JNK) that is
%	necessary for the model to fit the experimental
%	data obtained in this study.
rule((rac,jnk1),[(rac,gtp)],global_attack,on,'j17b_1').
rule((rac,jnk2),[(rac,gtp)],global_attack,on,'j17b_2').
rule((rac,bcat),[(rac,gtp)],global_attack,on,'j17b_3').

% RULE j18: If Rac interacts with JNK1 and JNK2, they are
%	activated to form JNK1p [=JNK1*] and JNK2p [=JNK2*].
rule((jnk1,jnk1p),[(rac,jnk1)],global_attack,on,'j18_1').
rule((jnk2,jnk2p),[(rac,jnk2)],global_attack,on,'j18_2'). 

% RULE j19a: If JNK1 and JNK2 are activated,
%	they can interact with b-catenin.
rule((jnk1,bcat),[(jnk1,jnk1p),(bcat,bcat),not (bcat,bcatub)],
	global_attack,on,'j19a_1').
rule((jnk2,bcat),[(jnk2,jnk2p),(bcat,bcatfree)],
	global_attack,on,'j19a_2').
       
% RULE j19b: If JNK2 interacts with free b-catenin,
%	free b-catenin can interact with Lef.
%	-> ProbRules-Code see RULE 9
       
% RULE j19c: If JNK1 is activated, JNK1 can activate GSK3.
rule((jnk1,gsk3),[(jnk1,jnk1p)],global_attack,on,'j19c').

% RULE j19d: If JNK1 interacts with b-catenin and GSK3 and
%	b-catenin is in the destruction complex,
%	b-catenin is phosphorylated by GSK3.
rule((gsk3,bcat),[(jnk1,bcat),(jnk1,gsk3),(apc,bcat),
	(axin,bcat)],global_attack,on,'j19d').

:- evaluation(300).
:- halt.

