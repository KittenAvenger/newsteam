-module(countrycode).

-export([start/1, retrieve_country_list/0]).

start (List) ->


[{find(N), Players} || {N, Players} <- List].

find (CountryCode) ->
	case CountryName = database:get_countrycode(CountryCode) of
		notfound -> find_country_name(CountryCode);
		_ -> CountryName
	end.
	
		 
	
retrieve_country_list() ->

ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"https://raw.githubusercontent.com/Holek/steam-friends-countries/master/data/steam_countries.json", []},[], []),
{struct, JsonData} = mochijson:decode(JSON),
database:store_countrylist(JsonData).

find_country_name(CountryCode) ->

{_, Data1} = proplists:get_value(atom_to_list(CountryCode), database:get_countrylist()),
Data2 = proplists:get_value("name",Data1),
database:store_countrycode(CountryCode, Data2), 
Data2.
