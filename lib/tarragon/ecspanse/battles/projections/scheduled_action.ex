defmodule Tarragon.Ecspanse.Battles.Projections.ScheduledAction do
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.ProjectionUtils

  use Ecspanse.Projection,
    fields: [
      :action,
      :scheduled_action,
      :entity
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_scheduled_action(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_scheduled_action(entity_id) when is_binary(entity_id) do
    case Ecspanse.Entity.fetch(entity_id) do
      {:ok, entity} -> project_scheduled_action(entity)
      err -> raise err
    end
  end

  def project_scheduled_action(%Ecspanse.Entity{} = entity) do
    {:ok, scheduled_action} = Components.ScheduledAction.fetch(entity)

    {:ok, action} = Ecspanse.Query.fetch_tagged_component(entity, [:action])

    struct!(__MODULE__,
      scheduled_action: ProjectionUtils.project(scheduled_action),
      action: ProjectionUtils.project(action),
      entity: ProjectionUtils.project(entity)
    )
  end
end
