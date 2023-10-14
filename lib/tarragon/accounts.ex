defmodule Tarragon.Accounts do
  @moduledoc """
  The Accounts context.
  """

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
  def list_users do
    Repo.all(User)
    |> Repo.preload([:characters])
    |> Repo.preload([:characters])
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload([characters: [:participation, hand: [items: [:shop_item]], backpack: [items: [:shop_item]]]])
  end

  def get_user_character!(id) do
    UserCharacter
    |> Repo.get!(id)
    |> Repo.preload([hand: [items: [:shop_item]]])
    |> Repo.preload([backpack: [items: [:shop_item]]])
    |> Repo.preload([:user])
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

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
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

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
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def change_user_character(%UserCharacter{} = user_character, attrs \\ %{}) do
    UserCharacter.changeset(user_character, attrs)
  end
end