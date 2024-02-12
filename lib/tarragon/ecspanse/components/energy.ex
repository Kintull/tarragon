defmodule Tarragon.Ecspanse.Components.Energy do
  @moduledoc """
  The energy points are used to perform actions.
  It starts with 50 energy points and it can have a maximum of 100 energy points.
  """
  use Ecspanse.Component, state: [current: 90, max: 100]
end
