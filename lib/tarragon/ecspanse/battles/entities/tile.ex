defmodule Tarragon.Ecspanse.Battles.Entities.TileEntity do
  @moduledoc """
  Factory for a single battlefield tile
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.MapParameters

  def new(%MapParameters.Tile{} = tile, parent) do
    {Ecspanse.Entity,
     components: [
       {Components.GridTile, [
         left: tile.left,
         top: tile.top,
         width: tile.width,
         height: tile.height]},
       {Components.Position, [x: tile.hex_coords.x, y: tile.hex_coords.y, z: tile.hex_coords.z]}
     ],
     parents: [parent]}
  end
end
