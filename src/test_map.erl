
-module(test_map).
-compile(export_all).


% Connect to Riak and register pid

connect()->

case whereis(server) of
undefined ->

{ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 10017), 
register(server, Pid),
{ok,Pid};
Pid -> {ok, Pid} 
end.

% Helper functions for mapreduce and also stores map reduced data

elem([],NewList)->L=lists:sublist(lists:reverse(lists:keysort(2,NewList)),10),
Y=tuple_to_list(erlang:date()),
Z=term_to_binary(Y),
connect(),
Period = riakc_obj:new(<<"total2">>, Z, term_to_binary(L)),
riakc_pb_socket:put(server, Period);

elem([H|T],NewList)->

T2=NewList++get_elem(H,T,[]),
NewTail=delete_elem(H,T),
elem(NewTail,T2).

% Helper function for getting today's data

get_data(Z)-> 
connect(),
{ok,O}=riakc_pb_socket:get(server,<<"total2">>,Z),
W=riakc_obj:get_value(O),
Obj=binary_to_term(W),
Obj.

% Get today's map reduced data

get_data_daily(Y,M,D)->
connect(),
W=tuple_to_list({Y,M,D}),
Z=term_to_binary(W), 
get_data(Z).

% Retrieve all the keys in the bucket

get_keys_list()->
connect(),
{ok,Lis}=riakc_pb_socket:list_keys(server, <<"hoursplayed">>),
generate_list(Lis).

find_players() ->
connect(),
{ok,List}=riakc_pb_socket:list_keys(server, <<"hoursplayed">>),
NewList = list_players(List, []),
[search(N, 730) || N <- NewList ].	


search({Player, GameList}, GameID) ->

case lists:keyfind(GameID, 1, GameList) of
	false -> not_found;
	  _   -> Player 
	end.


list_players([], List) -> List;
list_players([H|T], NewList) -> 
{ok, Object} = riakc_pb_socket:get(server, <<"hoursplayed">>, H),
W=riakc_obj:get_value(Object),
Obj=binary_to_term(W),
list_players(T, NewList ++ [{binary_to_term(H), Obj}]).

%binary_to_term(H),
% Generate a specific key list

generate_list([])->[];
generate_list([H|T])->
[{<<"hoursplayed">>, H}|generate_list(T)].


% Map reduce hours played

get_sum_riak()->
connect(),
{ok,List}=riakc_pb_socket:list_keys(server, <<"hoursplayed">>),
L=get_obj(List),
elem(L,[]).
 
% Map function 

get_obj([])->[];
get_obj([H|T])->
connect(),
{ok, Fetched1} = riakc_pb_socket:get(server, <<"hoursplayed">>, H),
lists:append(binary_to_term(riakc_obj:get_value(Fetched1)),get_obj(T)).

% Reduce function

get_elem({A,B},[],L)->[{A,get_sum([{A,B}]++L,0)}];
get_elem({A,B},[H|T],NewList)->
case H of
	{A,C}->get_elem({A,B},T,NewList ++ [{A,C}]);
	_->get_elem({A,B},T,NewList)
end.

get_sum([],Acc)->Acc;
get_sum([H|T],Acc)->
case H of
	{_,B}->get_sum(T,B+Acc)
end.
delete_elem(_,[])->[];
delete_elem({A,B},[H|T])->
case H of
	{A,_}->delete_elem({A,B},T);
	_->[H|delete_elem({A,B},T)]

end.



