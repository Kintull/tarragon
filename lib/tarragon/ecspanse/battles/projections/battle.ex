defmodule Tarragon.Ecspanse.Battles.Projections.Battle do
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.Projection,
    fields: [
      :battle,
      :state_machine,
      :state_timer,
      :entity,
      :teams,
      :grenades
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_battle(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  # @spec project_battles() :: list(map())
  @doc """
  returns a list of  battles
  """
  def project_battles() do
    Components.Battle.list()
    |> Enum.map(&Ecspanse.Query.get_component_entity/1)
    |> Enum.map(&project_battle/1)
  end

  @spec project_battle(Ecspanse.Entity.id() | Ecspanse.Entity.t()) :: struct()
  def project_battle(entity_id) when is_binary(entity_id) do
    with {:ok, entity} <- Ecspanse.Entity.fetch(entity_id) do
      project_battle(entity)
    end
  end

  def project_battle(%Ecspanse.Entity{} = battle_entity) do
    {:ok, {battle, state_machine, state_timer}} =
      Ecspanse.Query.fetch_components(
        battle_entity,
        {Components.Battle, EcspanseStateMachine.Components.StateMachine,
         EcspanseStateMachine.Components.StateTimer}
      )

    teams =
      Lookup.list_children(battle_entity, Components.Team)
      |> Enum.map(&Projections.Team.project_team/1)

    grenades =
      Lookup.list_children(battle_entity, Components.Grenades.ExplosiveGrenade)
      |> Enum.map(&Projections.Grenade.project_grenade/1)

    struct!(__MODULE__,
      battle: ProjectionUtils.project(battle),
      entity: ProjectionUtils.project(battle_entity),
      state_machine: ProjectionUtils.project(state_machine),
      state_timer: ProjectionUtils.project_timer(state_timer),
      teams: teams,
      grenades: grenades
    )
  end
end
