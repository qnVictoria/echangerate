%%%-------------------------------------------------------------------
%% @doc exchangerate top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(exchangerate_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init(_Args) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 10,
        period => 60},

    ChildSpecs =
        [#{id => exchangerate_scheduler,
           start => {exchangerate_scheduler, start_link, []},
           restart => permanent,
           shutdown => 2000,
           type => worker,
           modules => [exchangerate_scheduler]}],
    {ok, {SupFlags, ChildSpecs}}.
