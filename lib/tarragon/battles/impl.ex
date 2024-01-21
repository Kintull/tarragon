defmodule Tarragon.Battles.Impl do
  @moduledoc """
  The Battles context.
  """
  @behaviour Tarragon.Battles

  import Ecto.Query, warn: false

  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Battles.Participant
  alias Tarragon.Battles.Room
  alias Tarragon.Repo

  alias Tarragon.Inventory
  alias Tarragon.Accounts

  @impl true
  defdelegate build_character_bonuses(integer), to: Tarragon.Battles.CharacterBattleBonuses

  @doc """
  Returns the list of battle_rooms.

  ## Examples

      iex> list_battle_rooms()
      [%Room{}, ...]

  """
  @impl true
  def list_battle_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  @impl true
  def get_room!(id) do
    Repo.one!(
      from r in Room,
        where: r.id == ^id,
        preload: [participants: [user_character: :user]]
    )
  end

  @impl true
  def get_all_rooms!() do
    Repo.all(
      from r in Room,
        preload: [participants: [user_character: :user]]
    )
  end

  @impl true
  def get_all_active_rooms!() do
    active_rooms_query =
      from r in Room,
        join: p in assoc(r, :participants),
        join: uc in assoc(p, :user_character),
        where: r.awaiting_start == false and not is_nil(r.started_at),
        where: p.closure_shown == false and p.is_bot == false,
        select: r.id

    Repo.all(
      from r in Room,
        where: r.id in subquery(active_rooms_query),
        join: p in assoc(r, :participants),
        join: uc in assoc(p, :user_character),
        preload: [participants: {p, [user_character: uc]}]
    )
  end

  @impl true
  def get_open_room_or_create() do
    rooms_awaiting_start = Enum.filter(get_all_rooms!(), & &1.awaiting_start)

    case rooms_awaiting_start do
      [] ->
        create_room()

      rooms ->
        fullest_room =
          rooms
          |> Enum.sort_by(&length(&1.participants), &>=/2)
          |> hd

        {:ok, fullest_room}
    end
  end

  @impl true
  def get_assigned_room(character_id) do
    case Repo.get_by!(Participant, user_character_id: character_id)
         |> Repo.preload(:battle_room) do
      nil ->
        nil

      {:ok, %{room: room}} ->
        room
    end
  end

  @impl true
  def get_character_active_room(character_id) do
    room_id_query =
      from r in Room,
        join: p in assoc(r, :participants),
        join: uc in assoc(p, :user_character),
        where: r.awaiting_start == false and not is_nil(r.started_at),
        where: uc.id == ^character_id,
        where: p.closure_shown == false and p.is_bot == false,
        select: r.id

    Repo.one(
      from r in Room,
        where: r.id == subquery(room_id_query),
        join: p in assoc(r, :participants),
        join: uc in assoc(p, :user_character),
        preload: [participants: {p, [user_character: uc]}]
    )
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @impl true
  def update_room_multi(multi, multi_name, %Room{} = room, attrs) do
    Ecto.Multi.update(multi, multi_name, Room.changeset(room, attrs))
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  @impl true
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  alias Tarragon.Battles.Participant

  @doc """
  Returns the list of battle_participant.

  ## Examples

      iex> list_human_battle_participants()
      [%Participant{}, ...]

  """
  @impl true
  def list_human_battle_participants do
    q =
      from p in Participant,
        join: uc in assoc(p, :user_character),
        join: u in assoc(uc, :user),
        where: u.is_bot == false,
        preload: [user_character: :user]

    Repo.all(q)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  @impl true
  def get_participant!(id),
    do:
      Repo.get!(Participant, id)
      |> Repo.preload(:battle_room)
      |> Repo.preload(:user_character)

  @impl true
  def get_participant(%Room{} = room, %UserCharacter{} = character) do
    Repo.get_by!(Participant, %{battle_room_id: room.id, user_character_id: character.id})
    |> Repo.preload(:battle_room)
    |> Repo.preload(:user_character)
  end

  @impl true
  def get_active_participant(%UserCharacter{} = character) do
    participant =
      Repo.get_by(Participant, %{user_character_id: character.id, closure_shown: false})

    if participant do
      participant
      |> Repo.preload(:battle_room)
      |> Repo.preload(:user_character)
    end
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(user_character: [:user])
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @impl true
  def update_participant_multi(multi, multi_name, %Participant{} = participant, attrs) do
    Ecto.Multi.update(multi, multi_name, Participant.changeset(participant, attrs))
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  @impl true
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end

  @impl true
  def create_bot_character do
    id = Ecto.UUID.generate()

    {:ok, bot_user} =
      Accounts.impl().create_user(%{
        hidden: true,
        email: "bot-#{id}@email.com",
        name: "Bot #{id}",
        password: "password-#{id}"
      })

    {:ok, character} =
      Accounts.impl().create_user_character(%{
        user_id: bot_user.id,
        nickname: "Bot #{id}",
        current_health: 100,
        max_health: 100,
        active: true
      })

    {:ok, pw_container} =
      Inventory.impl().create_container(%{capacity: 1, primary_weapon_slot_id: character.id})

    {:ok, hg_container} =
      Inventory.impl().create_container(%{capacity: 1, head_gear_slot_id: character.id})

    {:ok, cg_container} =
      Inventory.impl().create_container(%{capacity: 1, chest_gear_slot_id: character.id})

    {:ok, kg_container} =
      Inventory.impl().create_container(%{capacity: 1, knee_gear_slot_id: character.id})

    {:ok, fg_container} =
      Inventory.impl().create_container(%{capacity: 1, foot_gear_slot_id: character.id})

    all_items = Inventory.impl().list_items()
    bow = Enum.find(all_items, fn %{purpose: purpose} -> purpose == :primary_weapon end)
    chest_plate = Enum.find(all_items, fn %{purpose: purpose} -> purpose == :chest_gear end)
    boots = Enum.find(all_items, fn %{purpose: purpose} -> purpose == :foot_gear end)
    knee_pads = Enum.find(all_items, fn %{purpose: purpose} -> purpose == :knee_gear end)
    helmet = Enum.find(all_items, fn %{purpose: purpose} -> purpose == :head_gear end)

    Inventory.impl().create_character_item(%{
      game_item_id: bow.id,
      current_condition: bow.initial_condition,
      item_container_id: pw_container.id
    })

    Inventory.impl().create_character_item(%{
      game_item_id: chest_plate.id,
      current_condition: chest_plate.initial_condition,
      item_container_id: cg_container.id
    })

    Inventory.impl().create_character_item(%{
      game_item_id: boots.id,
      current_condition: boots.initial_condition,
      item_container_id: fg_container.id
    })

    Inventory.impl().create_character_item(%{
      game_item_id: knee_pads.id,
      current_condition: knee_pads.initial_condition,
      item_container_id: kg_container.id
    })

    Inventory.impl().create_character_item(%{
      game_item_id: helmet.id,
      current_condition: helmet.initial_condition,
      item_container_id: hg_container.id
    })

    character
    |> Repo.reload()
    |> Repo.preload([
      :primary_weapon_slot,
      :head_gear_slot,
      :chest_gear_slot,
      :knee_gear_slot,
      :foot_gear_slot
    ])
  end

  @impl true
  defdelegate init_battle_process(participants), to: Tarragon.Battles.BattleRoom, as: :init_battle

  @impl true
  defdelegate submit_battle_action(battle_room_id, action_map),
    to: Tarragon.Battles.BattleRoom,
    as: :submit_action

  @impl true
  defdelegate battle_turn_seconds_left(battle_room_id),
    to: Tarragon.Battles.BattleRoom,
    as: :turn_seconds_left

  @impl true
  defdelegate check_all_submitted(battle_room_id), to: Tarragon.Battles.BattleRoom

  @impl true
  defdelegate count_submitted(battle_room_id), to: Tarragon.Battles.BattleRoom

  @impl true
  defdelegate finalize_battle_process_turn(battle_room_id),
    to: Tarragon.Battles.BattleRoom,
    as: :finalize_turn

  @impl true
  defdelegate decide_bot_move(participants, atk_options), to: Tarragon.Battles.BattleBots
end
