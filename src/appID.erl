-module(appID).
-export([findApp/1]).







% Parses a JSON object containing the owned games by a player and 
% returns a lists of appids for that player or an empty list if no games were found


findApp(A) ->
ssl:start(),
application:start(inets),
{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=80C9F831FD044A94E0A0FE0792624CD4&steamid="++A++"&format=json", []},[], []),

Struct=mochijson:decode(JSON),
case Struct of
	{_,[H|_]}-> case H of
		{_,Y}-> case Y of

			{struct,List}-> case lists:keyfind("games", 1, List) of
				false->[];
				{_,{_,ListI}} -> parse_list(ListI,[])
							end
		end
	end
	end. 

parse_list([],List)->List;
parse_list([H|T],List)->
case H of
	{struct,[Hd|_]} -> case Hd of
		{_,S}->T2=List ++ [S],
		parse_list(T,T2)
	end
end.


