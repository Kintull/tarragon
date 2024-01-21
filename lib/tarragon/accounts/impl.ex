defmodule Tarragon.Accounts.Impl do
  @moduledoc """
  The Accounts context.
  """

  @behaviour Tarragon.Accounts

  import Ecto.Query, warn: false
  alias Tarragon.Repo

  alias Tarragon.Accounts.User
  alias Tarragon.Accounts.UserCharacter

  @doc """
  Returns the list of user.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @impl true
  def list_users(filter_opts \\ %{}) do
    q = from(u in User)

    q
    |> user_filter(filter_opts)
    |> Repo.all()
    |> Repo.preload([:characters])
  end

  defp user_filter(query, %{:is_bot => is_bot}) do
    from u in query, where: u.is_bot == ^is_bot
  end

  defp user_filter(query, _), do: query

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @impl true
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(
      characters: [
        :participations,
        primary_weapon_slot: [items: [:game_item]],
        backpack: [items: [:game_item]]
      ]
    )
  end

  @impl true
  def get_user_character!(id) do
    UserCharacter
    |> Repo.get!(id)
    |> Repo.preload(primary_weapon_slot: [item: [:game_item]])
    |> Repo.preload(head_gear_slot: [item: [:game_item]])
    |> Repo.preload(chest_gear_slot: [item: [:game_item]])
    |> Repo.preload(knee_gear_slot: [item: [:game_item]])
    |> Repo.preload(foot_gear_slot: [item: [:game_item]])
    |> Repo.preload(backpack: [items: [:game_item]])
    |> Repo.preload([:user])
  end

  alias Tarragon.Battles.Participant
  @impl true
  def list_all_healing_user_characters! do
    q =
      from uc in UserCharacter,
        left_join: p in Participant,
        on: uc.id == p.user_character_id and p.eliminated == false,
        where: uc.active == true and uc.current_health < uc.max_health,
        where: is_nil(p.id),
        group_by: uc.id

    Repo.all(q)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @impl true
  def create_user_character(attrs \\ %{}) do
    %UserCharacter{}
    |> UserCharacter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @impl true
  def update_user_character(%UserCharacter{} = user_character, attrs) do
    user_character
    |> UserCharacter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  @impl true
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @impl true
  def change_user_character(%UserCharacter{} = user_character, attrs \\ %{}) do
    UserCharacter.changeset(user_character, attrs)
  end

  @impl true
  def update_user_character_multi(multi, multi_name, %UserCharacter{} = user_character, attrs) do
    Ecto.Multi.update(multi, multi_name, UserCharacter.changeset(user_character, attrs))
  end

  @impl true
  def get_character_by_user_id!(user_id) do
    q = from uc in UserCharacter, where: uc.user_id == ^user_id and uc.active == true

    Repo.one!(q)
  end
end
