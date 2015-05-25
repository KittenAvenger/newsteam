-module(friendslist).

-export([retrieve/1]).




% Parses a JSON object containing a Steam player's friendslist and returns a list of steamids

retrieve (ID) ->

ssl:start(),
application:start(inets),



{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=80C9F831FD044A94E0A0FE0792624CD4&steamid="++ID++"&relationship=friend", []},[], []),

Struct=mochijson:decode(JSON),

{struct, JsonData} = Struct,
{struct, Friends} = proplists:get_value("friendslist",JsonData),
{array, List} = proplists:get_value("friends",Friends),
A=[parse(N) || N <- List],
database:store_friends(ID,A).


parse(S) ->
{struct, Hey} = S,
D=proplists:get_value("steamid",Hey),
C=string:strip(D, both, $"),
C.
