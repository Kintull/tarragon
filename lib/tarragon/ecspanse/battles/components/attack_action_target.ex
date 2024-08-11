defmodule Tarragon.Ecspanse.Battles.Components.AttackActionTarget do
  @moduledoc """
  The attacked character_id submitted when submitting attack action by a player.
  """
  use Ecspanse.Component, state: [:entity_id]

#  @impl true
#  def validate(state) do
#    if state.entity_id == nil, do: {:error, "entity_id is required"}, else: :ok
#  end
end
