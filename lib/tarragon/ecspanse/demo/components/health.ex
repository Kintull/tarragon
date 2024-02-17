defmodule Tarragon.Ecspanse.Demo.Components.Health do
  @moduledoc """
  Entities can have health.  This is their current health and max health.
  Min health is 0.
  """
  use Ecspanse.Component, state: [current: 50, max: 100]
end
