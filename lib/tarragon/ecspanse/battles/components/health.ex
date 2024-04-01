defmodule Tarragon.Ecspanse.Battles.Components.Health do
  @moduledoc """
  Entities can have health.  This is their current health and max health.
  Min health is 0.
  """
  use Ecspanse.Component, state: [current: 20, max: 20]
end
