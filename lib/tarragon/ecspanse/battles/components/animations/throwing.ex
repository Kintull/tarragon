defmodule Tarragon.Ecspanse.Battles.Components.Animations.Throwing do
  @moduledoc """
  Data to toss a grenade
  """
  use Ecspanse.Component,
    state: [:from, :to, duration_in_milliseconds: 250],
    tags: [:animation, :throwing]
end
