defmodule Tarragon.Ecspanse.Battles.Components.ActionPoints do
  @moduledoc """
  The action points are used to perform actions.
  """
  use Ecspanse.Component, state: [current: 50, max: 50]
end
