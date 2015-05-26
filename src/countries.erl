-module(countries).

-export([start/0, elem/2]).
%-compile(export_all).






start () ->

ssl:start(),
application:start(inets),
elem([get_countries(N) || N <- test_map:find_players()], []).	



get_countries(SteamID) ->

	case SteamID of
		not_found -> empty;
		_ ->


{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=80C9F831FD044A94E0A0FE0792624CD4&steamids=" ++ SteamID, []},[], []),

{struct, JsonData} = mochijson:decode(JSON),
{_, Data1} = proplists:get_value("response",JsonData),
{array, List} = proplists:get_value("players",Data1),
case is_atom(Final = parse(List)) of
	true -> Final;
	false -> list_to_atom(Final)
end
end.


parse(Countries)->
[{struct, Data}] = Countries,
proplists:get_value("loccountrycode", Data, empty).	

elem([], NewList) -> lists:sublist(lists:reverse(lists:keysort(2,NewList)),10);
elem([H|T],NewList)->

T2=NewList++get_elem(H,T,[]),
NewTail=delete_elem(H,T),
elem(NewTail,T2).

get_elem(A,[],L)->[{A,get_sum([A]++L,0)}];
get_elem(A,[H|T],NewList)->
io:format("~p~n", [H]),
case H of
	empty -> get_elem(A,T,NewList);
	%not_found ->get_elem(A,T,NewList);
	A ->get_elem(A,T,NewList ++ [A]);
	_ ->get_elem(A,T,NewList)
end.

get_sum([],Acc)->Acc;
get_sum([H|T],Sum)->
case H of
	_->get_sum(T, Sum + 1)
end.
delete_elem(_,[])->[];
delete_elem(A,[H|T])->
case H of
	A->delete_elem(A,T);
	_->[H|delete_elem(A,T)]

end.