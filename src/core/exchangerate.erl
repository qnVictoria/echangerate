-module(exchangerate).

-export([update/0, build_xml/0]).

-define(Url, "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5").

update() ->
  {ok, {_Status, _Headers, Body}} = httpc:request(get, {?Url, []}, [], [{sync, true}]),
  EchangeRateResult = json_body(Body),
  ets:insert(exchangerate, EchangeRateResult).

build_xml() ->
  CachedRates = ets:match_object(exchangerate, {'$0', '$1', '$2', '$3'}),
  lists:concat(["<?xml version='1.0' encoding='UTF-8' standalone='yes'?>", "<exchangerates>\n", build_inner_elements(CachedRates, []), "</exchangerates>"]).

build_inner_elements([], Acc) -> Acc;
build_inner_elements([{Ccy, BaseCcy, Buy, Sale}|T], Acc) ->
  Element = lists:concat(["<row>\n", "<exchangerate ccy='", binary:bin_to_list(Ccy),
                          "' base_ccy='", binary:bin_to_list(BaseCcy),
                          "' buy='", binary:bin_to_list(Buy),
                          "' sale='", binary:bin_to_list(Sale), "'/>\n"
                          "</row>\n"]),
  build_inner_elements(T, [Element|Acc]).

json_body(Body) ->
  DecodedList = jsone:decode(list_to_binary(Body)),
  lists:reverse(map_to_tuple(DecodedList)).

map_to_tuple(List) -> map_to_tuple(List, []).
map_to_tuple([], Acc) -> Acc;
map_to_tuple([H|T], Acc) ->
  ExchangeTuple = {maps:get(<<"ccy">>, H),
                   maps:get(<<"base_ccy">>, H),
                   maps:get(<<"buy">>, H),
                   maps:get(<<"sale">>, H)},
  map_to_tuple(T, [ExchangeTuple|Acc]).
