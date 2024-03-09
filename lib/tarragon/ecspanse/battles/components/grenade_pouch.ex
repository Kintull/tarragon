defmodule Tarragon.Ecspanse.Battles.Components.GrenadePouch do
  @moduledoc """
    Count of each type of grenade
  """
  use Ecspanse.Component, state: [smoke: 0, explosive: 0]
end
