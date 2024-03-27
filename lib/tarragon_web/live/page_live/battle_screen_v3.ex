defmodule TarragonWeb.PageLive.BattleScreenV3 do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Inventory
  alias Tarragon.Battles

  def mount(_params, _, socket) do
    # hexagonal grid coordinates include x, y, z, where x + y + z = 0
    # creating a hexagonal grid with 7 hexagons
    outer_r = 20
    inner_r = round(outer_r * 0.86602540378)

    grid = generate_grid_circle(3, 20)
    grid = generate_grid_rectangle(5, 3, 20)

    IO.inspect(grid)
    socket = assign(socket, grid: grid)

    {:ok, socket, layout: false}
  end

  def distance(hex_a, hex_b) do
    Enum.max([abs(hex_a.x - hex_b.x), abs(hex_a.y - hex_b.y), abs(hex_a.z - hex_b.z)])
  end

  def hex_to_offset(hex) do
    x = hex.x + div(hex.y, 2)
    y = hex.y
    %{x: x, y: y}
  end

  def offset_to_hex(offset) do
    x = offset.x - div(offset.y, 2)
    y = offset.y
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def generate_grid_circle(map_radius, outer_hex_radius) do
    inner_r = round(outer_hex_radius * 0.86602540378)
    for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
      offset_coords = %{x: x, y: y}
      hex_coordinates = offset_to_hex(offset_coords)

      if distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius do
        left = ((x + y * 0.5 - div(y,2)) * (inner_r * 2)) |> round
        top = (y * outer_hex_radius * 1.5) |> round
        height = (outer_hex_radius * 2) |> round
        width = (inner_r * 2) |> round
        %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  def generate_grid_rectangle(height_cells, width_cells, outer_hex_radius) do
    inner_r = round(outer_hex_radius * 0.86602540378)
    for x <- 0..width_cells, y <- 0..height_cells do
#      if div(y, 2) == 0 and x == width_cells do
#        nil
#      else
#      end
        offset_coords = %{x: x, y: y}
        hex_coordinates = offset_to_hex(offset_coords)

        left = ((x + y * 0.5 - div(y,2)) * (inner_r * 2)) |> round
        top = (y * outer_hex_radius * 1.5) |> round
        height = (outer_hex_radius * 2) |> round
        width = (inner_r * 2) |> round
        %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
    end
    |> Enum.reject(&is_nil/1)
  end


end
