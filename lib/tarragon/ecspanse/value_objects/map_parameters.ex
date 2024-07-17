defmodule Tarragon.Ecspanse.MapParameters do
  @moduledoc false

  use TypedStruct

  @type hex_coord :: %{x: integer(), y: integer(), z: integer()}

  typedstruct module: Tile do
    field :coord, %{x: integer(), y: integer()}
    field :hex_coords, MapParameters.hex_coord()
    field :left, integer()
    field :top, integer()
    field :width, integer()
    field :height, integer()
  end

  typedstruct module: MapTiles do
    field :name, String.t()
    field :cells, [Tile.t()]
    field :width, integer()
    field :height, integer()
  end

  typedstruct do
    field :map_tiles, MapTiles.t()
    field :spawns_team_a, [MapParameters.hex_coord()]
    field :spawns_team_b, [MapParameters.hex_coord()]
  end

  def new() do
    %__MODULE__{
      map_tiles: generate_grid_circle_flat(3, 100),
      spawns_team_a: [
        %{x: -1, y: 4, z: -3},
        %{x: 0, y: 4, z: -4},
        %{x: 1, y: 3, z: -4}
      ],
      spawns_team_b: [
        %{x: -1, y: -3, z: 4},
        %{x: 0, y: -4, z: 4},
        %{x: 1, y: -4, z: 3}
      ]
    }
  end

  def generate_grid_circle_flat(map_radius, cell_width) do
    ratio = 1.6

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_height / 2) |> round
    outer_r = (cell_width / 2) |> round

    cells =
      for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
        offset_coords = %{x: x, y: y}
        hex_coordinates = offset_to_hex_flat(offset_coords)

        if distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius and (x <= 3 and x >= -3) do
          left = (x * outer_r * 1.5) |> round
          top = ((y + x * 0.5 - div(x, 2)) * inner_r * 2) |> round
          height = cell_height
          width = cell_width

          %Tile{
            coord: offset_coords,
            hex_coords: hex_coordinates,
            left: left,
            top: top,
            width: width,
            height: height
          }
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

  def offset_to_hex_flat(offset) do
    x = offset.x
    y = offset.y - div(offset.x, 2)
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def distance(hex_a, hex_b) do
    Enum.max([abs(hex_a.x - hex_b.x), abs(hex_a.y - hex_b.y), abs(hex_a.z - hex_b.z)])
  end

  def neighbours(%{x: x, y: y, z: z}, distance) do
    [
      %{x: x + distance, y: y - distance, z: z},
      %{x: x + distance, y: y, z: z - distance},
      %{x: x, y: y + distance, z: z - distance},
      %{x: x - distance, y: y + distance, z: z},
      %{x: x - distance, y: y, z: z + distance},
      %{x: x, y: y - distance, z: z + distance}
    ]
  end
end
