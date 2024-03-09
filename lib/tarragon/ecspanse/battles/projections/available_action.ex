defmodule Tarragon.Ecspanse.Battles.Projections.AvailableAction do
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.Projection,
    fields: [
      :action,
      :available_action,
      :entity
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_available_action(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_available_action(entity_id) when is_binary(entity_id) do
    case Ecspanse.Entity.fetch(entity_id) do
      {:ok, entity} -> project_available_action(entity)
      err -> raise err
    end
  end

  def project_available_action(%Ecspanse.Entity{} = entity) do
    {:ok, available_action} =
      Components.AvailableAction.fetch(entity)

    {:ok, action_component} =
      Ecspanse.Query.fetch_tagged_component(entity, [:action])

    struct!(__MODULE__,
      available_action: ProjectionUtils.project(available_action),
      action: ProjectionUtils.project(action_component),
      entity: ProjectionUtils.project(entity)
    )
  end
end
