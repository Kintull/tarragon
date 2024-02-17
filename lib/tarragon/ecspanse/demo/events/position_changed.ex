defmodule Tarragon.Ecspanse.Demo.Events.PositionChanged do
  @moduledoc """
  event that will be emitted when the hero actually moved
  """
  use Ecspanse.Event, fields: [:entity_id]
end
