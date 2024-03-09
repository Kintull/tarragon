defmodule Tarragon.Ecspanse.Battles.Components.Effects.Dodging do
  @moduledoc """
  When present, the chance to evade a shot
  """
  use Ecspanse.Component, state: [chance: 10]
end
