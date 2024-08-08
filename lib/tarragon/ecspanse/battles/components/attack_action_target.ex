defmodule Tarragon.Ecspanse.Battles.Components.AttackActionTarget do
  @moduledoc """
  The attacked character_id submitted when submitting attack action by a player.
  """
  use Ecspanse.Component, state: [:entity_id]
end
