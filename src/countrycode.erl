-module(countrycode).

-export([start/0]).

start () ->

ssl:start(),
application:start(inets),

{ok,{_,_,JSON}}=httpc:request(get, {"https://raw.githubusercontent.com/Holek/steam-friends-countries/master/data/steam_countries.json", []},[], []),

{struct, JsonData} = mochijson:decode(JSON),
{_, Data1} = proplists:get_value("UA",JsonData),
Data2 = proplists:get_value("name",Data1),
Data2.

