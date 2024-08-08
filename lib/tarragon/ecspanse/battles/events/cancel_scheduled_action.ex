defmodule Tarragon.Ecspanse.Battles.Events.CancelScheduledAction do
  @moduledoc """
  Request to cancel a scheduled action.  The scheduled action should become available again
  """
  use Ecspanse.Event, fields: [:action_entity_id]
end
