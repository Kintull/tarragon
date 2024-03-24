defmodule TarragonWeb.PageLive.BattleScreenV3 do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Inventory
  alias Tarragon.Battles

  def mount(_params, _, socket) do
    # hexagonal grid coordinates include x, y, z, where x + y + z = 0

    # creating a hexagonal grid with 7 hexagons
    grid = for x <- -3..3, y <- -3..3, z = -x - y, do: {x, y, z}

    socket = assign(socket, grid: grid)

    {:ok, socket, layout: false}
  end
end
