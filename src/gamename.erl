-module(gamename).

-export([findgames/0]).






% Parses a JSON object containing a list of all games available in the current Steam Library and stores them in the database


parse(A)->
{struct, Data} = A,
C=proplists:get_value("appid", Data),
D=proplists:get_value("name", Data),
io:format("Games: ~p.", [Data]),
{C,D}.


findgames() ->
ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/ISteamApps/GetAppList/v0001/", []},[], []),

Struct=mochijson:decode(JSON),

{struct, JsonData} = Struct,

{struct, List} = proplists:get_value("applist",JsonData),
{struct, Data} = proplists:get_value("apps",List),
{array, GameNames} = proplists:get_value("app",Data),

A=[parse(N) || N <- GameNames],

[database:store_gameName(C) || C <- A].


