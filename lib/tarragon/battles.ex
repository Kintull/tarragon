defmodule Tarragon.Battles do
  @moduledoc """
  The Battles context.
  """

  alias Tarragon.Battles.Room
  alias Tarragon.Battles.Participant
  alias Tarragon.Battles.CharacterBattleBonuses
  alias Tarragon.Accounts.UserCharacter

  @type attrs :: map

  def impl(), do: Application.get_env(:tarragon, :battles_impl)
  @callback list_battle_rooms :: [Room.t()]
  @callback get_room!(integer) :: Room.t()
  @callback get_all_rooms!() :: [Room.t()]
  @callback get_all_active_rooms!() :: [Room.t()]
  @callback get_character_active_room(character_id) :: Room.t() | nil
  @callback get_open_room_or_create() :: {:ok, Room.t()} | {:error, any}
  @callback get_assigned_room(UserCharacter.t()) :: Room.t() | nil
  @callback create_room(attrs) :: {:ok, Room.t()} | {:error, Ecto.Changeset}
  @callback update_room(Room.t(), attrs) :: {:ok, Room.t()} | {:error, Ecto.Changeset}
  @callback update_room_multi(Ecto.Multi.t(), atom, Room.t(), attrs) :: Ecto.Multi.t()
  @callback delete_room(Room.t()) :: {:ok, Room.t()} | {:error, Ecto.Changeset}
  @callback change_room(Room.t(), attrs) :: Ecto.Changeset

  @callback list_human_battle_participants :: [Participant.t()]
  @callback get_participant!(integer) :: Participant.t()
  @callback get_participant(Room.t(), UserCharacter.t()) :: Participant.t()
  @callback get_participant(UserCharacter.t()) :: Participant.t() | nil
  @callback get_active_participant(UserCharacter.t()) :: Participant.t() | nil
  @callback create_participant(attrs) :: {:ok, Participant.t()} | {:error, Ecto.Changeset}
  @callback update_participant(Participant.t(), attrs) ::
              {:ok, Participant.t()} | {:error, Ecto.Changeset}
  @callback update_participant_multi(Ecto.Multi.t(), atom, Participant.t(), attrs) ::
              Ecto.Multi.t()
  @callback delete_participant(Participant.t()) ::
              {:ok, Participant.t()} | {:error, Ecto.Changeset}
  @callback change_participant(Participant.t(), attrs) :: Ecto.Changeset
  @callback build_character_bonuses(integer) :: CharacterBattleBonuses.t()

  @callback create_bot_character :: [UserCharacter.t()]

  @type battle_room_id :: integer()
  @type participants :: [Participant.t()]
  @callback init_battle_process(participants) :: battle_room_id
  @callback submit_battle_action(
              battle_room_id,
              %{
                character_id: character_id,
                move: String.t(),
                attack: String.t(),
                target_id: character_id
              }
            ) :: :ok
  @callback finalize_battle_process_turn(battle_room_id) :: :ok
  @callback battle_turn_seconds_left(battle_room_id) :: :ok
  @callback check_all_submitted(battle_room_id) :: boolean
  @callback count_submitted(battle_room_id) :: boolean

  @type atk_options :: [%{distance: integer, health: integer, target_id: character_id}]
  @type bot_id :: integer
  @type character_id :: integer
  @callback decide_bot_move(bot_id, [atk_options]) :: %{
              target_id: character_id,
              move: String.t(),
              attack: String.t()
            }
end
