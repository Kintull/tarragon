defmodule Tarragon.Ecspanse.Battles.Projections.Grid do
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Lookup

  use Ecspanse.Projection,
    fields: [
      :cells
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_grid(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_grid(grid_entity_id) when is_binary(grid_entity_id) do
    case Ecspanse.Entity.fetch(grid_entity_id) do
      {:ok, entity} -> project_grid(entity)
      err -> raise err
    end
  end

  def project_grid(%Ecspanse.Entity{} = grid_entity) do
    grid_tiles =
      Lookup.list_children(grid_entity, Components.GridTile)
      |> Enum.map(&Projections.GridTile.project_grid_tile(&1))

    struct!(__MODULE__,
      cells: ProjectionUtils.project(grid_tiles)
    )
  end
end
