defmodule Tarragon.Ecspanse.Battles.Components.Team do
  @moduledoc """
  One of the sides in the battle.

  A team will have combatants as children

  """
  use Ecspanse.Component,
    state: [],
    tags: [:team]

  @impl true
  def validate(_component), do: :ok
end
