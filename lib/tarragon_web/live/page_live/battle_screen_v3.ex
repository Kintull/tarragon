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

    cell_width = 63
#    grid = generate_grid_rectangle_flat(9, 5, cell_width)
#    grid = generate_grid_rectangle_pointy(9, 5, cell_width)
#    grid = generate_grid_circle_pointy(3, cell_width)
    grid = generate_grid_circle_flat(5, cell_width)

    IO.inspect(grid)
    socket = assign(socket, grid: grid)

    {:ok, socket, layout: false}
  end

  def distance(hex_a, hex_b) do
    Enum.max([abs(hex_a.x - hex_b.x), abs(hex_a.y - hex_b.y), abs(hex_a.z - hex_b.z)])
  end

  def hex_to_offset_pointy(hex) do
    x = hex.x + div(hex.y, 2)
    y = hex.y
    %{x: x, y: y}
  end

  def offset_to_hex_pointy(offset) do
    x = offset.x - div(offset.y, 2)
    y = offset.y
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def offset_to_hex_flat(offset) do
    x = offset.x
    y = offset.y - div(offset.x, 2)
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def generate_grid_circle_pointy(map_radius, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_width / 2) |> round
    outer_r = (cell_height / 2) |> round

    cells = for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
      offset_coords = %{x: x, y: y}
      hex_coordinates = offset_to_hex_pointy(offset_coords)

      if distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius do
        left = ((x + y * 0.5 - div(y,2)) * (inner_r * 2)) |> round
        top = (y * outer_r * 1.5) |> round
        height = (outer_r * 2) |> round
        width = (inner_r * 2) |> round
        %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)

    %{name: "circular_grid_pointy", cells: cells, width: map_radius * cell_width, height: map_radius * cell_height}
  end

  def generate_grid_rectangle_pointy(height_cells, width_cells, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_width / 2) |> round
    outer_r = (cell_height / 2) |> round

    cells = for x <- 0..width_cells-1, y <- 0..height_cells-1 do

        if rem(y,2) != 0 and x == width_cells-1 do
           # make it symmetrical by removing extra cells on the right on every odd row
          nil
        else
          offset_coords = %{x: x, y: y}
          hex_coordinates = offset_to_hex_pointy(offset_coords)

          left = ((x + y * 0.5 - div(y,2)) * (inner_r * 2)) |> round
          top = (y * outer_r * 1.5) |> round
          height = cell_height
          width = cell_width
          %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
        end
    end
    |> Enum.reject(&is_nil/1)

    %{name: "rectangular_grid_pointy", cells: cells, width: width_cells * cell_width, height: height_cells * cell_height}
  end

  def generate_grid_circle_flat(map_radius, cell_width) do
    ratio = 1.6

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_height / 2) |> round
    outer_r = (cell_width / 2) |> round


    cells = for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
              offset_coords = %{x: x, y: y}
              hex_coordinates = offset_to_hex_flat(offset_coords)

              if (distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius) and (x <= 3 and x >= -3) do
                left = (x * outer_r * 1.5) |> round
                top = ((y + x * 0.5 - div(x,2)) * inner_r * 2) |> round
                height = cell_height
                width = cell_width
                %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
              else
                nil
              end
            end
            |> Enum.reject(&is_nil/1)

    map_diameter = Enum.map(-map_radius..map_radius, & &1) |> length
    width = map_diameter * 1.5 * cell_width
    height = map_diameter * cell_height
    %{name: "circular_grid_flat", cells: cells, width: width, height: height}
  end


  def generate_grid_rectangle_flat(height_cells, width_cells, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width * ratio) |> round

    inner_r = (cell_height / 2) |> round
    outer_r = (cell_width / 2) |> round

    cells = for x <- 0..width_cells-1, y <- 0..height_cells-1 do
              if rem(x,2) != 0 and y == height_cells-1 do
                # make it symmetrical by removing extra cells on the right on every odd row
                nil
              else
                offset_coords = %{x: x, y: y}
                hex_coordinates = offset_to_hex_flat(offset_coords)

                left = (x * outer_r * 1.5) |> round
                top = ((y + x * 0.5 - div(x,2)) * inner_r * 2) |> round
                height = cell_height
                width = cell_width
                %{coord: offset_coords, hex_coords: hex_coordinates, left: left, top: top, width: width, height: height}
              end
            end
            |> Enum.reject(&is_nil/1)

    %{name: "rectangular_grid_flat", cells: cells, width: width_cells * cell_width, height: height_cells * cell_height}
  end



end
