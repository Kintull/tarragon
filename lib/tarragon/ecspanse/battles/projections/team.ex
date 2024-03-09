defmodule Tarragon.Ecspanse.Battles.Projections.Team do
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Projections

  use Ecspanse.Projection,
    fields: [
      :combatants,
      :entity,
      :team,
      :brand
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_team(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_team(team_entity_id) when is_binary(team_entity_id) do
    case Ecspanse.Entity.fetch(team_entity_id) do
      {:ok, entity} -> project_team(entity)
      err -> raise err
    end
  end

  def project_team(%Ecspanse.Entity{} = team_entity) do
    {:ok, {team, brand}} =
      Ecspanse.Query.fetch_components(team_entity, {Components.Team, Components.Brand})

    combatants =
      Lookup.list_children(team_entity, Components.Combatant)
      |> Enum.map(&Projections.Combatant.project_combatant(&1))

    struct!(__MODULE__,
      combatants: combatants,
      entity: ProjectionUtils.project(team_entity),
      team: ProjectionUtils.project(team),
      brand: ProjectionUtils.project(brand)
    )
  end
end
