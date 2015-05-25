-module(hoursplayed).
-export([findHours/1, parse/1]).




% Parses a JSON object containing a Steam player's list of most recently played games for the last two weeks,
% returns a list of appids and hours played as a list of tuples or the string "no games" if the list was empty

findHours(ID)->


ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=80C9F831FD044A94E0A0FE0792624CD4&steamid="++ID++"&format=json", []},[], []),

Struct=mochijson:decode(JSON),
{struct, JsonData} = Struct,
{struct, GameList} = proplists:get_value("response",JsonData),

 


case GameList of
		[{"total_count",0}]->"no games";
	 []-> "no games";
	_ -> {array, List}=proplists:get_value("games",GameList),
	A=[parse(N) || N <- List], database:store_hours(ID, A)
end.


parse ([]) -> [];

parse(A)->
{struct, Data} = A,
C=proplists:get_value("appid", Data),
D=proplists:get_value("playtime_2weeks", Data),
{C,D}.





