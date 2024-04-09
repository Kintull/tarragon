defmodule Tarragon.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tarragon.Accounts` context.
  """

  @doc """
  Generate a users.
  """
  def users_fixture(attrs \\ %{}) do
    {:ok, users} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Tarragon.Accounts.create_users()

    users
  end
end
