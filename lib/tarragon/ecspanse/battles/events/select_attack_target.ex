defmodule Tarragon.Ecspanse.Battles.Events.SelectAttackTarget do
  @moduledoc """
  Request to persist selected attack target
  """
  use Ecspanse.Event, fields: [:player_combatant_entity_id, :selected_combatant_entity_id]
end
