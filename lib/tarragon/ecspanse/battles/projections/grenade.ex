defmodule Tarragon.Ecspanse.Battles.Projections.Grenade do
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.Projection,
    fields: [
      :entity,
      :grenade,
      :position
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_grenade(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_grenade(grenade_entity_id) when is_binary(grenade_entity_id) do
    case Ecspanse.Entity.fetch(grenade_entity_id) do
      {:ok, entity} -> project_grenade(entity)
      err -> raise err
    end
  end

  def project_grenade(%Ecspanse.Entity{} = grenade_entity) do
    with {:ok, position} <-
           Ecspanse.Query.fetch_component(grenade_entity, Components.Position),
         {:ok, grenade} <-
           Ecspanse.Query.fetch_tagged_component(grenade_entity, [:grenade]) do
      struct!(__MODULE__,
        entity: ProjectionUtils.project(grenade_entity),
        grenade: ProjectionUtils.project(grenade),
        position: Projections.Position.project_position(position)
      )
    end
  end
end
