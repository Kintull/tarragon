defmodule Tarragon.Ecspanse.Battles.Components.AttackTargetOption do
  @moduledoc """
  A character_id that is reachable by a player.
  """
  use Ecspanse.Component, state: [:user_id, :combatant_entity_id]
end
