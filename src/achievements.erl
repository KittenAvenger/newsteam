-module(achievements).

-export([start/0]).




start() ->

ssl:start(),
application:start(inets),
TopList = database:get_maphours(erlang:date()),
{GameID, _} = lists:nth(1, TopList),
getglobalachievement(GameID).



getglobalachievement(GameID) ->

ParsedID = integer_to_list(GameID),
{ok,{_,_,JSON}}=httpc:request(get, {"http://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=" ++ ParsedID ++ "&format=json", []},[], []),
{struct, JsonData} = mochijson:decode(JSON),

{_, Data1} = proplists:get_value("achievementpercentages",JsonData),
Data2 = proplists:get_value("achievements", Data1),
{array, List} = Data2,
AchievementList = [ parse(N) || N <- List ],

case AchievementList of
	[] -> [];
	_  -> {TopTenList, _} = lists:split(10, AchievementList), database:store_achievements(GameID, TopTenList)
end.



parse(Achievement)->
{struct, Data} = Achievement,
Name = proplists:get_value("name", Data),
Percentage = proplists:get_value("percent", Data),
{Name, Percentage}. 


