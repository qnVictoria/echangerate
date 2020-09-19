-module(exchangerate_scheduler).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_info/2]).

-define(SERVER, ?MODULE).
-define(INTERVAL, 60000). % One minute

%% API

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% Callbacks

init(_) ->
  erlang:send_after(?INTERVAL, self(), process),
  {ok, []}.

handle_info(_, State) ->
  ets:delete_all_objects(exchangerate),
  exchangerate:update(),
  erlang:send_after(?INTERVAL, self(), {}),

  {noreply, State}.
