defmodule Tarragon.Ecspanse.Battles.Events.ScheduleAvailableAction do
  @moduledoc """
  Request to convert an available action to a scheduled action
  """
  use Ecspanse.Event, fields: [:available_action_entity_id]
end
