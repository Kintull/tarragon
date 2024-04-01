defmodule Tarragon.Ecspanse.Demo.Events.ChangePositionRequest do
  @moduledoc """
  The hero will be able to move in the four directions: up, down, left and right.
  """
  use Ecspanse.Event, fields: [:entity_id, :direction]
end
