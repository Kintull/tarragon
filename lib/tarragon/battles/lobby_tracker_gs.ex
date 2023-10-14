defmodule Tarragon.Battles.LobbyTracker do
  @moduledoc """
  Process that tracks rooms that await start
  """

  use GenServer

  alias Tarragon.Repo
  alias Tarragon.Battles
  alias Tarragon.Battles.Participant
  alias Tarragon.Battles.Room

  alias Ecto.Multi

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
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

    awaiting_participant_groups =
      Repo.all(Participant)
      |> Enum.filter(&(&1.battle_room_id == nil))
      |> Repo.preload(:user_character)
      |> Enum.chunk_every(max_participants, max_participants, :discard)

    Enum.each(awaiting_participant_groups, &start_battle/1)

    Process.send_after(self(), :check_awaiting_participants, 2000)
    {:noreply, state}
  end

  defp start_battle(awaiting_participants) do
      {:ok, room} = Battles.get_open_room_or_create()
      multi = Battles.update_room_multi(Multi.new(), "activate_room", room, %{awaiting_start: false})
      multi =
        Enum.reduce(
          awaiting_participants,
          multi,
          fn awaiting_participant, multi ->
            multi
            |> Battles.update_participant_multi(
                 "assign_room_awaiting_participant_#{awaiting_participant.id}",
                 awaiting_participant,
                 %{battle_room_id: room.id}
               )
            |> Multi.run(
                 "notify_awaiting_participant_#{awaiting_participant.id}",
                 fn _, _ ->
                   case Phoenix.PubSub.broadcast(
                          Tarragon.PubSub,
                          "awaiting_participant:#{awaiting_participant.id}",
                          "battle_room_assigned"
                        ) do
                     :ok ->
                       {:ok, :success}
                     error_tuple ->
                       error_tuple
                   end
                 end
               )
          end
        )

      Repo.transaction(multi)
  end

end