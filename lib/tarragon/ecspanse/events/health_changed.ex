defmodule Tarragon.Ecspanse.Events.HealthChanged do
  @moduledoc """
  event that will be emitted whenever the amount of health changes
  """
  use Ecspanse.Event, fields: [:entity_id]
end
