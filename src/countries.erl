-module(countries).
-export([start/0, elem/2, count_countries/3]).

%	Start inet services

start () ->

ssl:start(),
application:start(inets),
elem([get_countries(N) || N <- test_map:find_players()], []).		%	Get the countries for all players for most popular game and do a map reduce	


%	Make a request for a player profile info, return empty for no profile or return country code as an atom, e.g. 'US'

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

%	Parse country countrycode for a player, return a string or the atom empty if not found

parse(Countries)->
[{struct, Data}] = Countries,
proplists:get_value("loccountrycode", Data, empty).

%	Unused functions for counting countries

count_countries(_, [], Sum) -> Sum;
count_countries(A, [H|T], Sum) ->
case H of
	empty -> count_countries(A,T, Sum);
	A ->count_countries(A,T, Sum + 1);
	_ ->count_countries(A,T,Sum)
end.

	
%	Perform a map reduce, return top ten countries in descending order

elem([], NewList) -> lists:sublist(lists:reverse(lists:keysort(2,NewList)),10);
elem([H|T],NewList)->
T2=NewList++get_elem(H,T,[]),
NewTail=delete_elem(H,T),
elem(NewTail,T2).

%	Map specific country and return a list with tuples, e.g [{'US', 120}]

get_elem(A,[],L)->[{A,get_sum([A]++L,0)}];
get_elem(A,[H|T],NewList)->
case H of
	empty -> get_elem(A,T,NewList);
	A ->get_elem(A,T,NewList ++ [A]);
	_ ->get_elem(A,T,NewList)
end.

%	Reduce the list and return sum of countries for a specific country

get_sum([],Acc)->Acc;
get_sum([H|T],Sum)->
case H of
	_->get_sum(T, Sum + 1)
end.

%	Delete countries that have already been mapped

delete_elem(_,[])->[];
delete_elem(A,[H|T])->
case H of
	A->delete_elem(A,T);
	_->[H|delete_elem(A,T)]

end.
