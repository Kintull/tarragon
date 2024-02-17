defmodule Tarragon.Ecspanse.Demo.Components.Position do
  @moduledoc """
  This is the characters location.
  the hero can move in four directions in a tiles-like manner.
  """
  use Ecspanse.Component, state: [x: 0, y: 0]
end
