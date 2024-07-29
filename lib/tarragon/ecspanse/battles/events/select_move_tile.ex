defmodule Tarragon.Ecspanse.Battles.Events.SelectMoveTile do
  @moduledoc """
  Updates movement action destination for a player
  """
  use Ecspanse.Event, fields: [:combatant_entity_id, :x, :y, :z]
end
