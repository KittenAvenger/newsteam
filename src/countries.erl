-module(countries).

-export([start/0]).





start () ->

ssl:start(),
application:start(inets),
[get_countries(N) || N <- test_map:find_players()].	



get_countries(SteamID) ->

	case SteamID of
		not_found -> not_found;
		_ ->


{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=80C9F831FD044A94E0A0FE0792624CD4&steamids=" ++ SteamID, []},[], []),

{struct, JsonData} = mochijson:decode(JSON),
{_, Data1} = proplists:get_value("response",JsonData),
%{struct, Data2} = Data1,
{array, List} = proplists:get_value("players",Data1),
parse(List)
end.


parse(Countries)->
[{struct, Data}] = Countries,
proplists:get_value("loccountrycode", Data, hidden_profile).	