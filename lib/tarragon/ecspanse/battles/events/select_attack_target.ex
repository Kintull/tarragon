defmodule Tarragon.Ecspanse.Battles.Events.SelectAttackTarget do
  @moduledoc """
  Request to persist selected attack target
  """
  use Ecspanse.Event, fields: [:combatant_entity_id, :character_id]
end
