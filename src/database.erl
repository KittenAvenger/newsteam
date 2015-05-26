-module(database).

-compile(export_all).



% Connects to the Riak database and registers the pid

connect()->

case whereis(server) of
undefined ->

{ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 10017), 
register(server, Pid),
{ok,Pid};
Pid -> {ok, Pid} 
end.



 
% Stores a list of steamids

store_friends(ID, B) ->



BinaryID=term_to_binary(ID),
Object = riakc_obj:new(<<"friendslist">>, BinaryID, B),
riakc_pb_socket:put(server, Object).


% Helper function for storing lists of appids

store_app(FriendID) ->


FriendList=get_friendslist(FriendID),
[store_appID(N, appID:findApp(N)) || N <- FriendList].

% Stores a list of appids

store_appID(ID, B) ->

BinaryID=term_to_binary(ID),
Object = riakc_obj:new(<<"ownedgames">>, BinaryID, B),
riakc_pb_socket:put(server, Object).


% Stores game names

store_gameName({ID, Game}) ->

BinaryID=term_to_binary(ID),
BinaryGame=term_to_binary(Game),
Object = riakc_obj:new(<<"gamenames">>, BinaryID, BinaryGame),
riakc_pb_socket:put(server, Object).


% Stores a list of hours and appids

store_hours (SteamID, Games) ->

BinaryID=term_to_binary(SteamID),
Object = riakc_obj:new(<<"hoursplayed">>, BinaryID, Games),
riakc_pb_socket:put(server, Object).







% Query Riak for a list of steamids

get_friendslist(ID)->

BinaryID=term_to_binary(ID),
{ok, Data} = riakc_pb_socket:get(server, <<"friendslist">>, BinaryID),
FriendList=riakc_obj:get_value(Data),
List=binary_to_term(FriendList),
List.

% Query Riak for a list of appids

get_ownedgames(ID)->

BinaryID=term_to_binary(ID),
{ok, Data} = riakc_pb_socket:get(server, <<"ownedgames">>, BinaryID),
OwnedGamesList=riakc_obj:get_value(Data),
binary_to_term(OwnedGamesList).

% Query Riak for the game name of a particular appid

get_gamename(ID)->

database:connect(),
BinaryID=term_to_binary(ID),
{ok, Data} = riakc_pb_socket:get(server, <<"gamenames">>, BinaryID),
GameName=riakc_obj:get_value(Data),
binary_to_term(GameName).

% Query Riak for a list of played hours

get_hours(ID) ->

BinaryID=term_to_binary(ID),
{ok, Data} = riakc_pb_socket:get(server, <<"hoursplayed">>, BinaryID),
HoursPlayedList=riakc_obj:get_value(Data),
binary_to_term(HoursPlayedList).


% Query Riak for map reduced data for owned games

get_mapgames(Z)-> 
connect(),
{ok,O}=riakc_pb_socket:get(server,<<"total">> ,Z),
W=riakc_obj:get_value(O),
Obj=binary_to_term(W),
Obj.

% Store map reduced data for owned games in a new bucket in a different format, that makes it possible to use in PHP

store_mapgames(Date)->
connect(),
W=tuple_to_list(Date),
Z=term_to_binary(W),
Data=get_mapgames(Z),
GameList=lists:map(fun({X,A})-> {database:get_gamename(X),A} end, Data),
Converted= io_lib:format("~p",[GameList]),
BC=lists:flatten(Converted),
Converted1= io_lib:format("~p",[W]),
BC1=lists:flatten(Converted1),
BinaryID=list_to_binary(BC1),
DataBin=list_to_binary(BC),
Object = riakc_obj:new(<<"mapgames1">>, BinaryID, DataBin),
riakc_pb_socket:put(server, Object).


% Query Riak for map reduced data for hours played

get_maphours(Date)-> 
List=tuple_to_list(Date),
Z=term_to_binary(List),
connect(),
{ok,O}=riakc_pb_socket:get(server,<<"total2">> ,Z),
W=riakc_obj:get_value(O),
Obj=binary_to_term(W),
Obj.

% Store map reduced data for played hours in a new bucket in a different format, that makes it possible to use in PHP

store_maphours(Date)->
connect(),
W=tuple_to_list(Date),
%Z=term_to_binary(W),
Data=get_maphours(Date),
GameList=lists:map(fun({X,A})-> {get_gamename(X),A} end, Data),
Converted= io_lib:format("~p",[GameList]),
BC=lists:flatten(Converted),
Converted1= io_lib:format("~p",[W]),
BC1=lists:flatten(Converted1),
BinaryID=list_to_binary(BC1),
DataBin=list_to_binary(BC),
Object = riakc_obj:new(<<"maphours">>, BinaryID, DataBin),
riakc_pb_socket:put(server, Object).


% Test function 

test(Z)->
connect(),
A=list_to_binary(Z),
{ok,O}=riakc_pb_socket:get(server,<<"maphours">>,A),
W=riakc_obj:get_value(O),
Obj=binary_to_list(W),
Obj.


% One function to store mapreduced data directly, using today's data as a key

store_map () ->
connect(),
store_mapgames(erlang:date()),
store_maphours(erlang:date()).

store_achievements(GameID, Achivements) ->
connect(),
BinaryList=list_to_binary(lists:flatten(io_lib:format("~p",[Achivements]))),
BinaryID=list_to_binary(lists:flatten(io_lib:format("~p",[get_gamename(GameID)]))),
Object = riakc_obj:new(<<"achievements">>, BinaryID, BinaryList),
riakc_pb_socket:put(server, Object),
binary_to_list(BinaryID).

store_countries(Countries) ->
connect(),
BinaryList=list_to_binary(lists:flatten(io_lib:format("~p",[Countries]))),
BinaryID=list_to_binary(lists:flatten(io_lib:format("~p",[tuple_to_list(erlang:date())]))),
Object = riakc_obj:new(<<"countries">>, BinaryID, BinaryList),
riakc_pb_socket:put(server, Object),
binary_to_list(BinaryID).

get_countries(Date) ->
connect(),
{ok, Object} = riakc_pb_socket:get(server, <<"countries">>, list_to_binary(lists:flatten(io_lib:format("~p",[tuple_to_list(Date)])))),
binary_to_list(riakc_obj:get_value(Object)).

get_achievements(GameID) ->
connect(),
{ok, Object} = riakc_pb_socket:get(server, <<"achievements">>, list_to_binary(GameID)),
binary_to_list(riakc_obj:get_value(Object)).



