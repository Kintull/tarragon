defmodule Tarragon.Ecspanse.Battles.Components.GridTile do
  @moduledoc """
  A grid piece of the board
  """
  use Ecspanse.Component,
      state: [
        :left,
        :top,
        :width,
        :height
      ]
end
