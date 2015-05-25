-module(map).
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

% Input test data

put()->

connect(),

Mine = riakc_obj:new(<<"test">>, <<"tet">>,
                        term_to_binary(["111", "222"])),
 Yours = riakc_obj:new(<<"test">>, <<"tett">>,
                         term_to_binary(["333", "111"])),
 riakc_pb_socket:put(server, Yours, [{w, 1}]),
 riakc_pb_socket:put(server, Mine, [{w, 1}]).


% Map reduce test data

m()->

connect(),

Count = fun(G, undefined, none) ->
             [dict:from_list([{I, 1}
              || I <- binary_to_term(riak_object:get_value(G))])]
           end,
 Merge = fun(Gcounts, none) ->
             [lists:foldl(fun(G, Acc) ->
                            dict:merge(fun(_, X, Y) -> X+Y end,
                                       G, Acc)
                          end,
                          dict:new(),
                          Gcounts)]
           end,
 {ok, [{1, [R]}]} = riakc_pb_socket:mapred(
                         server,
                         [{<<"test">>, <<"tet">>},
                          {<<"test">>, <<"tett">>}],
                         [{map, {qfun, Count}, none, false},
                          {reduce, {qfun, Merge}, none, true}]),
 L = dict:to_list(R),
L.


% Map reduce owned games and store it

ma()-> 

connect(),


Count = fun(G, undefined, none) ->
             [dict:from_list([{I, 1}
              || I <- binary_to_term(riak_object:get_value(G))])]
           end,
 Merge = fun(Gcounts, none) ->
             [lists:foldl(fun(G, Acc) ->
                            dict:merge(fun(_, X, Y) -> X+Y end,
                                       G, Acc)
                          end,
                          dict:new(),
                          Gcounts)]
           end, 
List=get_keys_list(),

{ok, [{1, [R]}]} = riakc_pb_socket:mapred(
                         server,
                         List,
                         [{map, {qfun, Count}, none, false},
                          {reduce, {qfun, Merge}, none, true}]),
 
L = dict:to_list(R),

%% top ten values

X=lists:sublist(lists:reverse(lists:keysort(2,L)),10),


Y=tuple_to_list(erlang:date()),
Z=term_to_binary(Y),
Period = riakc_obj:new(<<"total">>, Z, term_to_binary(X)),
riakc_pb_socket:put(server, Period).

% Helper function for getting today's data

get_data(Z)-> 
{ok,O}=riakc_pb_socket:get(server,<<"total">>,Z),
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
{ok,Lis}=riakc_pb_socket:list_keys(server, <<"ownedgames">>),
generate_list(Lis).

% Generate a specific key list

generate_list([])->[];
generate_list([H|T])->
[{<<"ownedgames">>,H}|generate_list(T)].

% Delete all objects in a bucket

delete_bucket([])->done;
delete_bucket([H|T])->
connect(),
riakc_pb_socket:delete(server, <<"ownedgames">>, H),
delete_bucket(T).

