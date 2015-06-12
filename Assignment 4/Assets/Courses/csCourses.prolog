%%%
%%% Initializations for the cs courses database
%%%
% Here the knowledge seems to be not accepted by unity. If I change it in pc.prolog it could be accepted.
%/perception/cs_class:1.
%/perception/cs_class/Subclass/Coursename:-immediate_kind_of(Subclass,cs_class),immediate_kind_of(Coursename,Subclass).

/perception/have_taken/no_req.

string_class_name(no_req, "no req").
string_class_name(eecs111,"eecs111").
string_class_name(eecs211,"eecs211").
string_class_name(eecs212,"eecs212").
string_class_name(eecs213,"eecs213").
string_class_name(eecs214,"eecs214").
string_class_name(eecs321,"eecs321").
string_class_name(eecs322,"eecs322").
string_class_name(eecs325,"eecs325").
string_class_name(eecs328,"eecs328").
string_class_name(eecs330,"eecs330").
string_class_name(eecs332,"eecs332").
string_class_name(eecs335,"eecs335").
string_class_name(eecs336,"eecs336").
string_class_name(eecs337,"eecs337").
string_class_name(eecs338,"eecs338").
string_class_name(eecs339,"eecs339").
string_class_name(eecs340,"eecs340").
string_class_name(eecs343,"eecs343").
string_class_name(eecs344,"eecs344").
string_class_name(eecs345,"eecs345").
string_class_name(eecs348,"eecs348").
string_class_name(eecs349,"eecs349").
string_class_name(eecs350,"eecs350").
string_class_name(eecs351,"eecs351").
string_class_name(eecs352,"eecs352").
string_class_name(eecs354,"eecs354").
string_class_name(eecs370,"eecs370").
string_class_name(eecs371,"eecs371").
string_class_name(eecs372,"eecs372").
string_class_name(eecs394,"eecs394").

string_class_names([], []).
string_class_names([Class|RestClass], [ClassStr|RestClassStr]) :-
    string_class_name(Class, ClassStr),
    string_class_names(RestClass, RestClassStr).


% 1. when the user types "i have taken eecsxxx",
% take that information and assert the fact into the data base
strategy(respond_to_dialog_act(assertion(player, $pc, take(player, Course, _), present, perfect)),
	 begin(assert(/perception/have_taken/Course),
	       say_string("Oh cool."))) :-
    is_a(Course, cs_class).


% 2. when the user type "how do i take eecsxxx", respond accordingly
% will traversal all the prereqs of the prereqs

player_question(want_to_take(Class)) --> [take, Class].
strategy(how_do_i(want_to_take(Class)),
	 if((/perception/have_taken/Class),
	    say_string("Why? You have taken it."),
	    check_requirements(Class))) :-
    is_a(Class, cs_class).


strategy(check_requirements(Class),
	 if(forall(related(Class,requires,Prereq),/perception/have_taken/Prereq),
	    say_string("Just go for it."),
	    output_requirements(CList))) :-
    findAllRequirements(Class,ClassList),
    remv_dup(ClassList, SimpleCList),
    remv_taken(SimpleCList, CList).

strategy(output_requirements(CList),
	 monolog(SuggestString)) :-
    if(length(CList, 1),
       (word_list(StringClass, CList),
	append(["You need to take: "], StringClass, SuggestString)),
       (length(CList,L),
	ins("and", CList, L, CListAnd),
	word_list(StringClass, CListAnd),
	append(["You need to take: "], StringClass, SuggestString))).


findAllRequirements(Class,List):-
    findAllRequirementsForLists([Class],List).

findAllRequirementsForLists([],[]).
findAllRequirementsForLists([FirstCourse|Rest],List):-
    findall(Prereq,related(FirstCourse, requires, Prereq),PrereqList),
    findAllRequirementsForLists(PrereqList,NextLevelList),
    findAllRequirementsForLists(Rest,NextList),
    append(PrereqList,NextList,TempList),
    append(TempList,NextLevelList,List).

remv_dup([], []).
remv_dup([H|T], [H|T1]) :- 
    remv(H, T, T2),
    remv_dup(T2, T1).

remv(_, [], []).
remv(X, [X|T], T1) :- remv(X, T, T1).
remv(X, [H|T], [H|T1]) :-
    X \= H,
    remv(X, T, T1).

remv_taken([], []).
remv_taken([C|Rest], R) :-
    /perception/have_taken/C,
    remv_taken(Rest, R).
remv_taken([C|Rest],[C|R_Rest]):-
    \+ /perception/have_taken/C,
    remv_taken(Rest,R_Rest).


% 3. when the user types "how do I satisfy xxx" (for example, core, ai_depth, etc)
% list course options and the number of class he must take, if he haven't fulfill it

player_question(want_to_satisfy(ReqSec)) --> [satisfy, ReqSec].

strategy(how_do_i(want_to_satisfy(Req)),
	 if((Still_Need < 1), 
	    say_string("You have already satisfied this section."),
	    output_class_options(YetTakenList, Still_Need))) :-
    kind_of(Req, cs_class),
    all(Class, is_a(Class, Req), ClassList),
    length(ClassList, Len),
    remv_taken(ClassList, YetTakenList),
    length(YetTakenList, YetTakenLen),
    need_class_num(Req, ReqNum),
    Still_Need is ReqNum - (Len - YetTakenLen).

strategy(output_class_options(CList, Num),
	 monolog(SuggestString)) :-
    % string_class_names(CList, StringCList),
    string_representation(Num, NumStr),
    word_list(Prefix, ["You need to take", NumStr, " additional classes out of: "]),
    if(length(CList, 1),
       (word_list(StringClass, CList),
	append([Prefix], StringClass, SuggestString)),
       (length(CList,L),
	ins("and", CList, L, CListAnd),
	word_list(StringClass, CListAnd),
	append([Prefix], StringClass, SuggestString))).


need_class_num(core, 5).
need_class_num(Req, 1) :-
    member(Req, [software_development, systems_breadth, ai_breadth, interfaces_breadth, theory_breadth]).
need_class_num(Req, 3) :-
    member(Req, [security_depth, systems_depth, ai_depth, interfaces_depth, theory_depth]).



% 4. answer correctly when asked "what is eecsxxx?"

strategy(answer_wh(player, Identity, _,
		   (be(Entity, Identity), is_a(Entity, entity))),
	 monolog(Description)):-
	 is_a(Entity,cs_class),
	 property_value(Entity, description, Description),
	 findall(Prereq,related(Entity, requires, Prereq),[no_req|_]),!.


strategy(answer_wh(player, Identity, _,
		   (be(Entity, Identity), is_a(Entity, entity))),
	 monolog(SuggestString)):-
	 is_a(Entity,cs_class),
	 property_value(Entity, description, Description),
	 findall(Prereq,related(Entity, requires, Prereq),PrereqList),
	 string_class_names(PrereqList, StringCList),
	 if(length(StringCList,0),
	    SuggestString is Description,
	    if(length(StringCList,1),
	       (word_list(Classes, StringCList),
		append([Description,"It requires:"], Classes, SuggestString)),
	       (length(StringCList,L),
	 	ins("and",StringCList,L,ListWithAnd),
		word_list(ClassesWithAnd, ListWithAnd),
	 	append([Description,"It requires:"], ClassesWithAnd, SuggestString)))).

ins(Val,[H|List],Pos,[H|Res]):- Pos > 1, !, 
                                Pos1 is Pos - 1, ins(Val,List,Pos1,Res). 
ins(Val, List, 1, [Val|List]).
