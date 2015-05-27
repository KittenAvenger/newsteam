-module(countrycode).

-export([start/1]).

start (List) ->

ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"https://raw.githubusercontent.com/Holek/steam-friends-countries/master/data/steam_countries.json", []},[], []),

[{find(N, JSON), Players} || {N, Players} <- List].

find (CountryCode, JSON) ->
{struct, JsonData} = mochijson:decode(JSON),
{_, Data1} = proplists:get_value(atom_to_list(CountryCode),JsonData),
Data2 = proplists:get_value("name",Data1),
Data2.


%countries:start(countrycode:start())
