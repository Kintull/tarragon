defmodule Tarragon.Ecspanse.Battles.Components.ActionPoints do
  @moduledoc """
  The action points are used to perform actions.
  """
  use Ecspanse.Component, state: [current: 3, max: 3]
end
