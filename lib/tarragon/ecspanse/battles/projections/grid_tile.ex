defmodule Tarragon.Ecspanse.Battles.Projections.GridTile do
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils

  use Ecspanse.Projection,
      fields: [
        :hex_coords,
        :left,
        :top,
        :width,
        :height
      ]


  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_grid_tile(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_grid_tile(grid_tile_entity_id) when is_binary(grid_tile_entity_id) do
    case Ecspanse.Entity.fetch(grid_tile_entity_id) do
      {:ok, entity} -> project_grid_tile(entity)
      err -> raise err
    end
  end

  def project_grid_tile(%Ecspanse.Entity{} = grid_tile_entity) do
    with {:ok, {grid_tile, position}} <-
           Ecspanse.Query.fetch_components(
             grid_tile_entity,
             {Components.GridTile, Components.Position}
           ) do
      grid_tile = ProjectionUtils.project(grid_tile)

      struct!(__MODULE__,
        hex_coords: Projections.Position.project_position(position),
        left: grid_tile.left,
        top: grid_tile.top,
        width: grid_tile.width,
        height: grid_tile.height
      )
    end
  end
end
