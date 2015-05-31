-module(countrycode).
-export([start/1, retrieve_country_list/0]).

%	Returns a list with country names and amount of players

start (List) ->
[{find(N), Players} || {N, Players} <- List].

%	Search for country name from country code, if not in database search the countrylist, otherwise return the name

find (CountryCode) ->
	case CountryName = database:get_countrycode(CountryCode) of
		notfound -> find_country_name(CountryCode);
		_ -> CountryName
	end.
	
%	One time function used to download the countrycode list with country names, only run once

retrieve_country_list() ->

ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"https://raw.githubusercontent.com/Holek/steam-friends-countries/master/data/steam_countries.json", []},[], []),
{struct, JsonData} = mochijson:decode(JSON),
database:store_countrylist(JsonData).

%	Parse country name from country list in case one couldn't be found in the database

find_country_name(CountryCode) ->

{_, Data1} = proplists:get_value(atom_to_list(CountryCode), database:get_countrylist()),
Data2 = proplists:get_value("name",Data1),
database:store_countrycode(CountryCode, Data2), 
Data2.
