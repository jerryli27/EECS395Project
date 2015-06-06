%%%
%%% Initializations for the cs courses database
%%%
% Here the knowledge seems to be not accepted by unity. If I change it in pc.prolog it could be accepted.
%/perception/cs_class:1.
%/perception/cs_class/Subclass/Coursename:-immediate_kind_of(Subclass,cs_class),immediate_kind_of(Coursename,Subclass).

class_requires(eecs111, no_req).
class_requires(eecs211, eecs111).
class_requires(eecs212, eecs111).
class_requires(eecs336, eecs211).

string_class_name(no_req, "never used").
string_class_name(eecs111, "eecs111").
string_class_name(eecs211, "eecs211").
string_class_name(eecs212, "eecs212").

class_taken(no_req).
class_taken(eecs111).

% when the user type "how do i take eecsxxx", run the following and respond accordingly
% will add tree traversal later

player_question(want_to_take(Class)) --> [take, Class].
strategy(how_do_i(want_to_take(Class)),
	 if(class_taken(Class),
	    say_string("Why? You have taken it."),
	    check_requirements(Class))) :-
    is_a(Class, cs_class).

strategy(check_requirements(Class),
	 if(class_taken(Required),
	    say_string("Just go for it."),
	    say_string(SuggestString))) :-
    class_requires(Class, Required),
    string_class_name(Required, ReqStr),
    append("You need to take", ReqStr, SuggestString).


% hope to achieve: when the user types "i have taken eecsxxx",
% take that information and do the assertion like above

strategy(respond_to_dialog_act(assertion(player, $pc, take(player, Course, _), present, perfect)),
	 begin(assert(class_taken(Course)),
	       say_string("Oh cool."))) :-
    is_a(Course, cs_class).
