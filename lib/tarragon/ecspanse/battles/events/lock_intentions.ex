defmodule Tarragon.Ecspanse.Battles.Events.LockIntentions do
  @moduledoc """
  A combatant has locked in their action choices
  """
  use Ecspanse.Event, fields: [:combatant_entity_id]
end
