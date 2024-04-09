defmodule Tarragon.BattlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tarragon.Battles` context.
  """

  @doc """
  Generate a profession.
  """
  def profession_fixture(attrs \\ %{}) do
    {:ok, profession} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        speed: 42,
        health_points: 42
      })
      |> Tarragon.Battles.create_profession()

    profession
  end
end
