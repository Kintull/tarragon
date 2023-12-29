defmodule Tarragon.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Tarragon.Accounts.User
  alias Tarragon.Accounts.UserCharacter

  @type id :: integer
  @type user :: User.t()
  @type user_id :: integer
  @type user_character :: UserCharacter.t()
  @type attrs :: map
  @type opts :: map

  def impl(), do: Application.get_env(:tarragon, :accounts_impl)

  @callback get_character_by_user_id!(user_id) :: UserCharacter.t()
  @callback get_user_character!(id) :: UserCharacter.t()
  @callback create_user_character(attrs) :: {:ok, UserCharacter.t()} | {:error, Ecto.Changeset}
  @callback update_user_character(user_character, attrs) ::
              {:ok, UserCharacter.t()} | {:error, Ecto.Changeset}
  @callback update_user_character_multi(Ecto.Multi.t(), atom, UserCharacter.t(), attrs) ::
              Ecto.Multi.t()
  @callback change_user_character(user_character, attrs) :: Ecto.Changeset

  @callback list_users(opts) :: [User.t()]
  @callback get_user!(id) :: User.t()
  @callback create_user(attrs) :: {:ok, User.t()} | {:error, Ecto.Changeset}
  @callback update_user(user, attrs) :: {:ok, User.t()} | {:error, Ecto.Changeset}
  @callback change_user(user, attrs) :: Ecto.Changeset
  @callback delete_user(user) :: {:ok, User.t()} | {:error, Ecto.Changeset}
end
