defmodule Tarragon.Battles.BattleFinderGs do
  use GenServer

  @check_max_wait_interval :timer.seconds(1)
  @max_waiting_time :timer.seconds(10)

  def start_link(args \\ nil) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, %{players: []}}
  end

  def get_players() do
    GenServer.call(__MODULE__, {:get_players})
  end

  def join(player_id) do
    GenServer.cast(__MODULE__, {:join, player_id})
  end

  def leave(player_id) do
    GenServer.cast(__MODULE__, {:leave, player_id})
  end

  # max wait processing
  @spec check_max_wait(state :: map) :: map
  defp send_check_max_wait(state) do
    unless Enum.empty?(state.players) do
      Process.send_after(self(), :check_max_wait, @check_max_wait_interval)
    end

    state
  end

  def handle_info(:check_max_wait, state) do
    state =
      state
      |> check_max_wait
      |> send_check_max_wait

    {:noreply, state}
  end

  def handle_call({:get_players}, _from, state) do
    {:reply, get_players(state), state}
  end

  def handle_cast({:join, player_id}, state) do
    state =
      state
      |> add_player(player_id)
      |> find_pairings()
      |> send_check_max_wait

    {:noreply, state}
  end

  def handle_cast({:leave, player_id}, state) do
    state =
      state
      |> remove_player(player_id)

    {:noreply, state}
  end

  # state maintenance logic
  defp add_player(state, player_id) do
    case Enum.find(state.players, nil, fn x -> x.player_id == player_id end) do
      nil ->
        %{
          state
          | players:
              List.insert_at(state.players, -1, %{
                player_id: player_id,
                joined_at: DateTime.utc_now()
              })
        }

      _ ->
        state
    end
  end

  defp check_max_wait(state) do
    IO.inspect(length(state.players), label: "Check Max Wait> players waiting")

    players =
      Enum.filter(state.players, fn p ->
        DateTime.diff(DateTime.utc_now(), p.joined_at, :millisecond) > @max_waiting_time
      end)

    if Enum.any?(players) do
      IO.inspect(players, label: "Check Max Wait> players to pair with bots")
    end

    # TODO pair them with bots
    # TODO notify players

    %{state | players: Enum.reject(state.players, fn p -> p in players end)}
  end

  defp find_pairings(state) do
    IO.inspect(length(state.players), label: "FindPairing> players")

    case length(state.players) >= Tarragon.Battles.Room.max_participants() do
      true ->
        {_players, remaining_players} =
          Enum.split(state.players, Tarragon.Battles.Room.max_participants())

        # TODO: make a room
        # TODO: notify players
        # TODO: notify remaining players?

        %{state | players: remaining_players}

      _ ->
        state
    end
  end

  defp get_players(state) do
    Enum.into(state.players, [], & &1.player_id)
  end

  defp remove_player(state, player_id) do
    %{
      state
      | players: Enum.reject(state.players, fn x -> x.player_id == player_id end)
    }
  end
end
