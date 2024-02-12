defmodule Tarragon.Ecspanse.Events.EnergyChanged do
  @moduledoc """
  event that will be emitted whenever the amount of energy changes
  """
  use Ecspanse.Event, fields: [:entity_id]
end
