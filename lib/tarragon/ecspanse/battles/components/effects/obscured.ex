defmodule Tarragon.Ecspanse.Battles.Components.Effects.Obscured do
  @moduledoc """
  When present, a shot misses
  """
  use Ecspanse.Component, state: [chance: 50]
end
