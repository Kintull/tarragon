defmodule Tarragon.Ecspanse.Battles.Components.MoveActionDirection do
  @moduledoc """
  The direction submitted when submitting move action by a player.
  """
  use Ecspanse.Component, state: [x: 0, y: 0, z: 0]
end
