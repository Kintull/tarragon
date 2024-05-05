defmodule Tarragon.Battles.BattleTrackerEcs do
  @moduledoc """
  Process that tracks rooms that await start
  """

  use GenServer

  alias Tarragon.Repo
  alias Tarragon.Battles
  alias Tarragon.Battles.Participant
  alias Tarragon.Battles.Room
  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Battles.CharacterBattleBonuses

  alias Tarragon.Ecspanse.GameParameters
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Lobby.LobbyGame.PlayerCombatant

  alias Ecto.Multi

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defmodule RoomState do
    defstruct [
      :id,
      :room,
      :characters,
      :character_battle_bonuses,
      :turn_character_actions,
      :bot_participants,
      :team_a_participants,
      :team_b_participants,
      :current_turn,
      :seconds_left
    ]

    @type character_id :: integer
    @type target_id :: character_id
    @type turn_id :: integer
    @type t :: %__MODULE__{
            id: integer,
            room: Room.t(),
            bot_participants: [Participant.t()],
            team_a_participants: [Participant.t()],
            team_b_participants: [Participant.t()],
            characters: %{character_id => UserCharacter.t()},
            character_battle_bonuses: %{
              character_id => CharacterBattleBonuses.t()
            },
            turn_character_actions: %{
              character_id => %{move: atom, attack: atom, target_id: integer}
            }
          }
  end

  @impl true
  def init(_) do
    state = %{battle_rooms: %{}}
    {:ok, state, {:continue, :init_active_battles}}
  end

  def init_battle(participants) do
    GenServer.call(__MODULE__, {:init_battle, participants})
  end

  def turn_seconds_left(battle_room_id) do
    GenServer.call(__MODULE__, {:turn_seconds_left, battle_room_id})
  end

  def udpate_room_with_winner_team(room, winner_team) do
    Battles.impl().update_room(room, %{
      ended_at: DateTime.utc_now(),
      winner_team: winner_team
    })
  end

  @impl true
  def handle_continue(:init_active_battles, state) do
    IO.inspect("BattleTrackerEcs init_active_battles")
    active_rooms = Battles.impl().get_all_active_rooms!()

    battle_rooms =
      active_rooms
      |> Enum.reduce(%{}, fn room, acc ->
        bot_participants = Enum.filter(room.participants, & &1.is_bot)
        team_a_participants = Enum.filter(room.participants, & &1.team_a)
        team_b_participants = Enum.filter(room.participants, & &1.team_b)

        battle_room_state = %RoomState{
          id: room.id,
          bot_participants: bot_participants,
          team_a_participants: team_a_participants,
          team_b_participants: team_b_participants,
          room: room,
          characters: build_characters_map(room.participants),
          character_battle_bonuses: build_character_battle_bonuses_map(room.participants),
          current_turn: room.current_turn,
          seconds_left: room.turn_duration_sec
        }

        lobby_game = build_ecs_lobby(room, team_a_participants, team_b_participants)
        Tarragon.Ecspanse.Battles.Api.spawn_battle(lobby_game)

        Map.put(acc, room.id, battle_room_state)
      end)

    Process.send_after(self(), :tick_timer, 1000)

    {:noreply, %{state | battle_rooms: battle_rooms}}
  end

  @impl true
  def handle_call({:init_battle, human_participants}, _, state) do
    {:ok, room} = Battles.impl().get_open_room_or_create()
    IO.inspect("BattleTrackerEcs init_battle room #{room.id}")

    bot_participants =
      create_additional_bot_characters(
        room.max_participants,
        length(human_participants)
      )

    participants = human_participants ++ bot_participants

    {team_a_participants, team_b_participants} = define_teams(participants)

    Multi.new()
    |> multi_activate_room(room)
    |> multi_assign_team_and_room(room, participants, team_a_participants, team_b_participants)
    |> multi_broadcast_battle_room_assigned(participants)
    |> Repo.transaction()

    lobby_game = build_ecs_lobby(room, team_a_participants, team_b_participants)
    Tarragon.Ecspanse.Battles.Api.spawn_battle(lobby_game)

    # reload room with registered participants
    room = Battles.impl().get_room!(room.id)

    battle_room_state = %RoomState{
      id: room.id,
      bot_participants: bot_participants,
      team_a_participants: team_a_participants,
      team_b_participants: team_b_participants,
      room: room,
      characters: build_characters_map(participants),
      character_battle_bonuses: build_character_battle_bonuses_map(participants),
      seconds_left: room.turn_duration_sec
    }

    battle_rooms = Map.merge(state.battle_rooms, %{room.id => battle_room_state})

    {:reply, room.id, %{state | battle_rooms: battle_rooms}}
  end

  def handle_call({:turn_seconds_left, battle_room_id}, _, state) do
    battle_room = state.battle_rooms[battle_room_id]

    {:reply, battle_room.seconds_left, state}
  end

  @impl true
  def handle_info(:tick_timer, state) do
    Process.send_after(self(), :tick_timer, 1000)

    {:noreply, state}
  end

  defp multi_activate_room(multi, room) do
    Battles.impl().update_room_multi(multi, "activate_room", room, %{
      started_at: DateTime.utc_now(),
      awaiting_start: false
    })
  end

  defp multi_assign_team_and_room(
         multi,
         room,
         participants,
         team_a_participants,
         team_b_participants
       ) do
    Enum.reduce(
      participants,
      multi,
      fn participant, multi_acc ->
        Battles.impl().update_participant_multi(
          multi_acc,
          "assign_room_participant_#{participant.id}",
          participant,
          %{
            team_a: participant.id in Enum.map(team_a_participants, & &1.id),
            team_b: participant.id in Enum.map(team_b_participants, & &1.id),
            battle_room_id: room.id
          }
        )
      end
    )
  end

  defp multi_broadcast_battle_room_assigned(multi, participants) do
    Enum.reduce(
      participants,
      multi,
      fn %{id: participant_id}, mult_acc ->
        Multi.run(
          mult_acc,
          "notify_awaiting_participant_#{participant_id}",
          fn _, _ ->
            case Phoenix.PubSub.broadcast(
                   Tarragon.PubSub,
                   "awaiting_participant:#{participant_id}",
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
  end

  defp build_characters_map(participants) do
    Enum.map(participants, fn participant ->
      {participant.user_character.id, participant.user_character}
    end)
    |> Enum.into(%{})
  end

  defp create_additional_bot_characters(max_participants, human_participants_count) do
    if human_participants_count < max_participants do
      Enum.map(1..(max_participants - human_participants_count), fn _ ->
        bot_character = Battles.impl().create_bot_character()
        Battles.impl().create_participant(%{user_character_id: bot_character.id, is_bot: true})
      end)
    else
      []
    end
  end

  defp define_teams(participants) do
    len = round(length(participants) / 2)
    Enum.split(participants, len)
  end

  def build_character_battle_bonuses_map(participants) do
    Enum.map(participants, fn participant ->
      {
        participant.user_character.id,
        Battles.impl().build_character_bonuses(participant.user_character.id) |> Map.from_struct()
      }
    end)
    |> Enum.into(%{})
  end

  defp build_ecs_lobby(room, team_a_participants, team_b_participants) do
    ecs_player_combatants_team_a =
      team_a_participants
      |> Enum.map(fn participant ->
        %PlayerCombatant{
          team: :team_a,
          profession: :sniper,
          character_id: participant.user_character_id
        }
      end)

    ecs_player_combatants_team_b =
      team_b_participants
      |> Enum.map(fn participant ->
        %PlayerCombatant{
          team: :team_b,
          profession: :sniper,
          character_id: participant.user_character_id
        }
      end)

    player_combatants = ecs_player_combatants_team_a ++ ecs_player_combatants_team_b

    %LobbyGame{
      id: room.id,
      game_parameters: GameParameters.new(),
      player_combatants: player_combatants
    }
  end
end
