%%%-------------------------------------------------------------------
%% @doc exchangerate public API
%% @end
%%%-------------------------------------------------------------------

-module(exchangerate_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ets:new(exchangerate, [set, public, named_table, {read_concurrency, true}]),

    inets:start(),

    Dispatch = cowboy_router:compile([
      {'_', [{"/xml", exchangerate_handler, []}]}
    ]),

    {ok, _} = cowboy:start_clear(my_http_listener, [{port, 4000}], #{env => #{dispatch => Dispatch}}),

    exchangerate_sup:start_link().

stop(_State) ->
    ok.
