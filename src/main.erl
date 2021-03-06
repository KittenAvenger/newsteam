-module(main).

-compile(export_all).

% Run this function once to download game names list and country name list

once()->
gamename:gamenames(),
countrycode:retrieve_country_list().

% Retrieves all the owned games from a list of Steam Players


run() ->
friendslist(),
ownedgames(),
hoursplayed(),
timer:sleep(1000),
map:ma(),
timer:sleep(1000),
test_map:get_sum_riak(),
timer:sleep(1000),
database:store_map(),
achievements:start(),
timer:sleep(1000),
database:store_countries(countrycode:start(countries:start())).

ownedgames() ->

database:connect(),

List=["76561197960435530","76561197965032141","76561198088291210"],
[friendslist:retrieve(ID) || ID <-List],

[database:store_app(ID)|| ID <-List].


% Retrieves a list of all games in the Steam Library

gamenames() ->

database:connect(),
gamename:findgames().


% Retrieves every game played by hours recently from a list of Steam Players

hoursplayed() ->

database:connect(),
A=database:get_friendslist("76561197960435530"),
B=database:get_friendslist("76561197965032141"),
C=database:get_friendslist("76561198088291210"),
[hoursplayed:findHours(N) || N <- A],
[hoursplayed:findHours(N) || N <- B],
[hoursplayed:findHours(N) || N <- C].


% Retrieves a lists of Steam Players to use in further data retrieval

friendslist()->

database:connect(),

List=["76561197960435530","76561197965032141","76561198088291210"],

[friendslist:retrieve(ID)|| ID <-List].


length([], Length) -> Length;
length([_|T], Length) -> length(T, Length + 1).















