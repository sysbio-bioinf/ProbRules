:- op(50, xfx, ::).
:- op(70, fx, not).

:- discontiguous (::)/2.
:- multifile rule/5.
:- multifile fixed/3.

%!  evaluation(+Timepoint:int) is det.
%
%   The entry point to this application.
%   Computes and prints the state of the probabilistic interactions at
%   each timepoint from 0 to Timepoint.
evaluation(S0) :-
    succ(S0, S),
    initialize_variables(Assoc),
    init_visualize(Assoc),
    visualize(0, Assoc),
    evaluation(1, S, Assoc).

evaluation(S, S, _) :- !.
evaluation(A, S, Assoc) :-
    newvalues(A, Assoc, New_Assoc),
    visualize(A, New_Assoc),
    succ(A, A1),
    evaluation(A1, S, New_Assoc).

%!  initialize_variables(-Assoc) is det.
%
%   Initialize Assoc with the probabilistic terms in the knowledge
%   base. Atoms are keys, probabilities are values.
initialize_variables(Assoc) :-
    empty_assoc(Assoc0),
    setof(X-P, P::X, Interactions),
    update_facts_assoc(Interactions, Assoc0, Assoc).

%!  init_visualize(+Assoc) is det.
%
%   Print a single tab-separated line with the probabilistic
%   interaction identifiers that serve as keys in Assoc (sorted asc).
init_visualize(Assoc) :-
    assoc_to_keys(Assoc, Xs),
    findall((A, B), member(interaction(A, B), Xs), Interactions),
    forall(member(Interaction, Interactions),
	   format('\t(~w)', [Interaction])),
    format('~n', []).

%!  visualize(+Iteration, +Assoc:association_list) is det.
%
%   Print a tab-separated line of interaction probabilities
%   (sorted asc). An iteration number is prepended to the line.
visualize(Iteration, Assoc) :-
    assoc_to_list(Assoc, Xs),
    format('~w\t', [Iteration]),
    forall(member(interaction(_,_)-X, Xs), format('~w\t', [X])),
    format('~n', []).

%!  newvalues(T, Assoc, New_Assoc) is det.
%   
%   Generate values for the next time point.
%   For each interaction (i.e. key) in Assoc do:
%   - check which rules are applicable and compute their target scores.
%   - take the average and associate it as the new value.
newvalues(T, Assoc, New_Assoc) :-
    assoc_to_keys(Assoc, Probabilistic_Atoms),
    findall(interaction(A,B),
	    member(interaction(A,B), Probabilistic_Atoms),
	    Interactions),
    newvalues_helper(T, Interactions, Assoc, New_Interactions),
    update_facts_assoc(New_Interactions, Assoc, New_Assoc).

%!  average(+Xs:number_list, -Y:number) is det.
%
%   Y is the average of the values in Xs.
average(Xs, Y) :-
    sum_list(Xs, T),
    length(Xs, L),
    Y is T / L.

%!  newvalues_helper(+Timepoint:int,
%!                   +Interactions,
%!                   +Assoc:association_list,
%!                   +Interaction_Probabilities) is det.
%
%   For each interaction in Interactions its probability for timepoint
%   Timepoint is computed and stored in Interaction_Probabilities.
%
%   The probability of an interaction is computed as follows:
%   - If a fixed probability for Interaction at timepoint Timepoint is
%     known, this becomes its probability.
%   - Otherwise, collect all rules potentially affecting Interaction
%     and compute the probability using interaction_probability/4.
newvalues_helper(_, [], _, []) :- !. % Ideally SWI Prolog would be
				     % able to identify that the empty
				     % list is mutually exclusive with
				     % the other clause for these
				     % arguments, however this is
				     % currently not the case, hence
				     % the cut to avoid a useless
				     % choice point.
newvalues_helper(A, [Interaction | Xs], Assoc, [Interaction-P | Ys]) :-
    ( static(A, Assoc, Interaction, P), !
    ; findall(Conditions-(Attack_Rate, Target_Probability),
	      dynamics(Interaction, Conditions, Target_Probability, Attack_Rate),
	      Rules),
      interaction_probability(Interaction, Assoc, Rules, P)
    ),
    newvalues_helper(A, Xs, Assoc, Ys).

%!  static(+Timepoint:int,
%!         +Assoc:association_list,
%!         +Interaction,
%!         -P:probability) is semidet.
%
%   Returns the probability P of a given Interaction at timepoint
%   Timepoint in case a fixed/3 statement is applicable.
%   Fails if not.
static(Timepoint, Assoc, interaction(X, Y), P) :-
    clause(fixed(X, Y, Timepoint), Body),
    conj_to_list(Body, Body_Literals),
    process(Assoc, Body_Literals, Ps),
    product(Ps, P).

%!  conj_to_list(Xs:conjunction, Ys:list) is det.
%
%   Ys is the order-preserved list of terms that made up Xs.
conj_to_list(','(H, Conj), [H | T]) :-
    !,
    conj_to_list(Conj, T).
conj_to_list(H, [H]).

%!  process(+Assoc:association_list,
%!          +Xs:list,
%!          -Ys:probability_list) is semidet.
%
%   Ys are the probabilities associated with their respective
%   terms in Xs. 
%   Xs can contain probabilistic as well as nonprobabilistic terms
%   (assumed to be det). The deterministic terms are called using call/1.
%   The probability associated with a deterministic term is the
%   neutral element for multiplication 1.
process(_, [], []).
process(Assoc, [X|Xs], [P|Ps]) :-
    process_literal(Assoc, X, P),
    process(Assoc, Xs, Ps).

process_literal(Assoc, X, P) :-
    ( get_assoc(X, Assoc, P), !
    ; call(X), P = 1
    ).

dynamics(interaction(X, Y), Conditions, Target_Probability, Attack_Rate) :-
    rule((X, Y), Conditions, Target_Probability, Attack_Rate, _Description).

%!  evaluate_conditions(+Conditions:list,
%!                      +Assoc:association_list,
%!                      -P:probability) is semidet.
%
%   P is the probability that the probabilistic variables in
%   Conditions hold.
%
%   Conditions contains positive or negated independent probabilistic facts.
%   Assoc has interactions (interaction/2) as keys and probabilities
%   as values.
%   If Conditions = [] then P = 1.
%   If length(Conditions, L), L > 0 then a probability is derived from
%   a condition by taking its probability from
%   Assoc and taking the complement in case it is negated.
%   P then equals the product of all probabilities.
evaluate_conditions(Conditions, Assoc, P) :-
    maplist(condition_probability(Assoc), Conditions, Probabilities),
    product(Probabilities, P).

%!  condition_probability(+Assoc:association_list,
%!                        +Condition,
%!                        -P:probability) is semidet.
%
%   If Condition is positive, then P is the probability specified by
%   the interaction/2 associated with Condition
%   in Assoc.
%   If Condition is negated, then P is the complement of that probability.
condition_probability(Assoc, not (X, Y), P) :-
    get_assoc(interaction(X, Y), Assoc, P0),
    P is 1 - P0.
condition_probability(Assoc, (X, Y), P) :-
    get_assoc(interaction(X, Y), Assoc, P).

%!  update_facts_assoc(+Probabilistic_Facts:pairs,
%!                            +Assoc_In:association_list,
%!                            -Assoc_Out:association_list) is det.
%
%   Assoc_Out is Assoc_In extended with each pair (serving as
%   (Key,Value)) of Probabilistic_Facts.
update_facts_assoc([], Assoc, Assoc).
update_facts_assoc([Fact-P | Xs], Assoc0, Assoc) :-
    put_assoc(Fact, Assoc0, P, Assoc1),
    update_facts_assoc(Xs, Assoc1, Assoc).

%!  product(+Xs:numberlist, -P:number) is det.
%
%   True if P is the product of the elements in Xs.
product(Xs, P) :-
    product_helper(Xs, 1, P).

product_helper([], Acc, P) :-
    P is Acc.
product_helper([X | Xs], Acc, P) :-
    product_helper(Xs, X * Acc, P).

%!  interaction_probability(+Interaction,
%!                          +Assoc:association_list,
%!                          +Xs,
%!                          -P:probability) is semidet.
%
%   P is the probability of Interaction by taking into account
%   the potential effects of the rules in Xs on its state in the
%   previous time point as stored in Assoc.
%
%   Format of Xs = [[(i,p)]-(global_attack,on),
%                   [(x,z), not (y,z)]-(global_attack, on)]
interaction_probability(Interaction, Assoc, Xs, P) :-
    findall(P,
	    (annotated_rules(Xs, World),
	     evaluate_world(Assoc, Interaction, World, P)),
	    Ps),
    sum_list(Ps, P).

%!  evaluate_world(+Assoc:association_list,
%!                 +Interaction,
%!                 +Xs,
%!                 -Probability) is semidet.
%
%   Xs is a set of rules associated with a particular Interaction
%   evaluated against a particular World. The World in question
%   is one world consisting of the variables used in the conditions of
%   that set of rules. Status indicates whether a particular Rule is
%   active in the World.
%
%   - If all the rules are evaluated as false in a particular world,
%     then the decay rule applies. The Weight of the world is used for
%     the Condition probability in the decay rule formula, except when 
%     Xs = [], since then the rules affecting the Interaction have no 
%     conditions (i.e. are always satisfied), in which case the Condition
%     probability is 1.
%   - If some rule is evaluated as true, then the probability of
%     each true rule is evaluated separately using the effective
%     rule formula, and then resulting probability are averaged out.
%
%   Note: format of Xs: for X in Xs: 
%   X = World-Condition-(Attack_Rate, Target_Probability)-Status
%   where
%   - World = one World (truth table generated) over the variables
%             used in the conditions of the rules affecting Interaction.
%   - Condition = the Condition that triggers a particular rule
%                 on Interaction.
%   - Attack_Rate = The attack rate of that some rule.
%   - Target_Probability = The target probability of that same rule.
%   - Status = Whether Condition actually holds in World.
evaluate_world(Assoc, Interaction, Xs, Probability) :-
    ( maplist(status(false), Xs) ->
	  get_assoc(global_decay, Assoc, Global_Decay),
	  get_assoc(Interaction, Assoc, Previous_P),
	  Initial_P :: Interaction,
	  ( memberchk(World-_-_-_, Xs) ->
	    evaluate_conditions(World, Assoc, Condition)
	  ;
	    Condition = 1
	  ),
	  default_decay_rule_formula(Condition, Global_Decay, Initial_P, Previous_P, Probability)
    ;
          include(status(true), Xs, Ys),
	  maplist(evaluate(Assoc, Interaction), Ys, Ps),
	  average(Ps, Probability)
    ).

%!  evaluate(+Assoc,
%!           +Interaction,
%!           +World_Rule,
%!           -P)  is semidet.
%
%   World_Rule = World-_-(Target_Probability_Atom,Attack_Rate_Atom)-_
%
%   P is the probability as specified by the formal effective rule
%   formula for Interaction where
%   - the condition probability is the probability of World.
%   - the Target Probability and Attack Rate is explicitly provided
%     through atoms that can be used as keys in Assoc.
%   - Interaction is used as a key in Assoc to retrieve its
%     probability at the previous time point.
evaluate(Assoc, Interaction, World-_-(Target_Probability_Atom, Attack_Rate_Atom)-_, P) :-
    evaluate_conditions(World, Assoc, Condition_P),
    get_assoc(Target_Probability_Atom, Assoc, Target_Probability),
    get_assoc(Attack_Rate_Atom, Assoc, Attack_Rate),
    get_assoc(Interaction, Assoc, Previous_P),
    effective_rule_formula(Condition_P, Target_Probability, Attack_Rate, Previous_P, P).

%!  default_decay_rule_formula(+Condition:probability,
%!                             +Global_Decay:probability,
%!                             +Initial_P:probability,
%!                             +Previous_P:probability,
%!                             -P:probability) is det.
%
%   P is the probability as specified by the formal default decay rule formula.
default_decay_rule_formula(Condition, Global_Decay, Initial_P, Previous_P, P) :-
    P is Condition * ((1 - Global_Decay) * Previous_P + Global_Decay * Initial_P).

%!  effective_rule_formula(+Condition:probability,
%!                         +Target_Probability:probability,
%!                         +Attack_Rate:probability,
%!                         +Previous_P:probability,
%!                         -P:probability) is det.
%
%   P is the probability as specified by the formal effective rule formula.
effective_rule_formula(Condition, Target_Probability, Attack_Rate, Previous_P, P) :-
    P is Condition * ((Target_Probability * Attack_Rate) + (1 - Attack_Rate ) * Previous_P).

status(State, _-_-_-State).

%!  annotated_rules(+Rules, -World_Rules_Satisfied:hyphen_quadruple_list) is multi
%
%    World_Rules_Satisfied is a list of quadruples.
%    Each binding of World_Rules_Satisfied is a list of Rules
%    evaluated against a particular World. Upon backtracking a list for
%    each possible world is returned.
annotated_rules(Rules, World_Rules_Satisfied) :-
    condition_TA_Pairs_condition_set(Rules, Condition_Variables),
    random_variables_world(Condition_Variables, World),
    maplist(condition_satisfaction_in_world(World), Rules, World_Rules_Satisfied).

%!  condition_satisfaction_in_world(+World,
%!                                  +Condition_L:hyphen_pair,
%!                                  -World_Conditions_L_State:hyphen_quadruple)
%!                                  is det.
%
%   State is true if Conditions are satisfied by World.
%   That is, if each element in Conditions is a member of World.
%   State is false otherwise.
condition_satisfaction_in_world(World, Conditions-L, World-Conditions-L-State) :-
    ( forall(member(Condition, Conditions), member(Condition, World))
    -> State = true
    ;  State = false
    ).

%!  condition_TA_Pairs_condition_set(+Condition_TA_Pairs:pairs,
%!                                   -Condition_Set:set) is det.
%
%   Condition_Set is the set of interactions contained in the
%   keys (a key is a list of positive or negated interactions) of
%  Condition_TA_Pairs.
condition_TA_Pairs_condition_set(Condition_TA_Pairs, Condition_Set) :-
    pairs_keys(Condition_TA_Pairs, Condition_Lists),
    append(Condition_Lists, Conditions),
    peeled_negation(Conditions, Positive_Conditions),
    sort(Positive_Conditions, Condition_Set).

%!  peeled_negation(+Xs:list, -Ys:list) is det.
%
%   True if Ys is Xs with one layer of not/1 peeled off.
%   not/1 represents negation.
%   If an element in Xs is negated, then that single negation is removed in Ys
%   If an element in Xs is not negated, then that element is left unchanged
%   in Ys.
peeled_negation([], []).
peeled_negation([X | Xs], [Y | Ys]) :-
    ( X = not Condition
    -> Y = Condition
    ;  Y = X
    ),
    peeled_negation(Xs, Ys).

%!  random_variables_world(+In:list, -Out:list) is multi.
%
%   Out is a row in the truth table derived from the variables
%   in In. Upon backtracking each row from the truth table is
%   generated.
%
%   if length(In, L), L>0 then random_variables_world/2 succeeds 2**L
%   times.
%   if length(In, 0) then random_variables_world/2 succeeds exactly
%   once with Out = [].
random_variables_world([], []).
random_variables_world([X | Xs], [X | Ys]) :-
    random_variables_world(Xs, Ys).
random_variables_world([X | Xs], [not(X) | Ys]) :-
    random_variables_world(Xs, Ys).
