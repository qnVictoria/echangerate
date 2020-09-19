-module(exchangerate_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
  XML = exchangerate:build_xml(),

  Req = cowboy_req:reply(200,
    #{<<"content-type">> => <<"text/xml">>},
      XML,
      Req0),
  {ok, Req, State}.
