defmodule Tarragon.Ecspanse.Battles.Projections.Bullet do
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.Projection,
    fields: [
      :entity,
      :bullet,
      :position
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_bullet(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_bullet(bullet_entity_id) when is_binary(bullet_entity_id) do
    case Ecspanse.Entity.fetch(bullet_entity_id) do
      {:ok, entity} -> project_bullet(entity)
      err -> raise err
    end
  end

  def project_bullet(%Ecspanse.Entity{} = bullet_entity) do
    with {:ok, {position, bullet}} <-
           Ecspanse.Query.fetch_components(
             bullet_entity,
             {Components.Position, Components.Bullet}
           ) do
      struct!(__MODULE__,
        entity: ProjectionUtils.project(bullet_entity),
        bullet: ProjectionUtils.project(bullet),
        position: Projections.Position.project_position(position)
      )
    end
  end
end
