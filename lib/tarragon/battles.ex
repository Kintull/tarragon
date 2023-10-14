defmodule Tarragon.Battles do
  @moduledoc """
  The Battles context.
  """

  import Ecto.Query, warn: false
  alias Tarragon.Repo

  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Battles.Room
  alias Tarragon.Battles.Participant

  @doc """
  Returns the list of battle_rooms.

  ## Examples

      iex> list_battle_rooms()
      [%Room{}, ...]

  """
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
  def get_room!(id), do: Repo.get!(Room, id)

  def get_all_rooms!(), do: Repo.all(Room)

  def get_open_room_or_create() do
    rooms_awaiting_start = Enum.filter(get_all_rooms!(), &(&1.awaiting_start))

    case rooms_awaiting_start do
      [] ->
        create_room()
      rooms ->
         fullest_room =
          rooms
          |> Repo.preload(:participants)
          |> Enum.sort_by(&(length(&1.participants)), &>=/2)
          |> hd

         {:ok, fullest_room}
    end
  end

  def get_assigned_room(character_id) do
    case Repo.get_by(Participant, user_character_id: character_id) |> Repo.preload(:battle_room) do
      nil ->
        nil
      {:ok, %{room: room}} ->
        room
    end
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

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
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  alias Tarragon.Battles.Participant

  @doc """
  Returns the list of battle_participant.

  ## Examples

      iex> list_battle_participant()
      [%Participant{}, ...]

  """
  def list_battle_participant do
    Repo.all(Participant)
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
  def get_participant!(id), do:
    Repo.get!(Participant, id)
    |> Repo.preload(:battle_room)
    |> Repo.preload(:user_character)

  def get_participant(%Room{} = room, %UserCharacter{} = character) do
    Repo.get_by!(Participant, %{battle_room_id: room.id, user_character_id: character.id})
    |> Repo.preload(:battle_room)
    |> Repo.preload(:user_character)
  end

  def get_participant(%UserCharacter{} = character) do
    Repo.get_by(Participant, %{user_character_id: character.id})
    |> Repo.preload(:battle_room)
    |> Repo.preload(:user_character)
  end


  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

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
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end
end
