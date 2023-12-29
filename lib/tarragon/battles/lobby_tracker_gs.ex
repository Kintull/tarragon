defmodule Tarragon.Battles.LobbyTracker do
  @moduledoc """
  Process that tracks rooms that await start
  """

  use GenServer

  alias Tarragon.Battles.Room
  alias Tarragon.Battles

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :start_loop}}
  end

  @impl true
  def handle_continue(:start_loop, state) do
    Process.send_after(self(), :check_awaiting_participants, 2000)
    {:noreply, state}
  end

  @impl true
  def handle_info(:check_awaiting_participants, state) do
    max_participants = Room.max_participants()

    participant_groups =
      Battles.impl().list_human_battle_participants()
      |> Enum.filter(&(&1.battle_room_id == nil))

    start_immediately = Application.get_env(:tarragon, :start_versus_immediately)

    participant_groups =
      if start_immediately do
        Enum.chunk_every(participant_groups, max_participants)
      else
        Enum.chunk_every(participant_groups, max_participants, max_participants, :discard)
      end

    case participant_groups do
      [] ->
        :ok

      [group] ->
        Battles.impl().init_battle_process(group)
    end

    Process.send_after(self(), :check_awaiting_participants, 2000)

    {:noreply, state}
  end
end
