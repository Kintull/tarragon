defmodule Tarragon.Ecspanse.Battles.Projections.Combatant do
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.Projection,
    fields: [
      :available_actions,
      :action_points,
      :brand,
      :combatant,
      :entity,
      :frag_grenade,
      :health,
      :main_weapon,
      :position,
      :profession,
      :scheduled_actions,
      :smoke_grenade,
      :is_dodging,
      :is_obscured,
      :is_moving,
      :is_shooting,
      :is_throwing
    ]

  @impl true
  def project(%{entity_id: entity_id} = _attrs) do
    result = project_combatant(entity_id)

    {:ok, result}
  end

  @impl true
  def on_change(%{client_pid: pid} = _attrs, new_projection, _previous_projection) do
    # when the projection changes, send it to the client
    send(pid, {:projection_updated, new_projection})
  end

  def project_combatant(combatant_entity_id) when is_binary(combatant_entity_id) do
    with {:ok, entity} <- Ecspanse.Entity.fetch(combatant_entity_id) do
      project_combatant(entity)
    end
  end

  def project_combatant(%Ecspanse.Entity{} = combatant_entity) do
    with {:ok,
          {action_points, brand, combatant, frag_grenade, health, main_weapon, position,
           profession,
           smoke_grenade}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.ActionPoints, Components.Brand, Components.Combatant,
              Components.FragGrenade, Components.Health, Components.MainWeapon,
              Components.Position, Components.Profession, Components.SmokeGrenade}
           ) do
      available_action_projections =
        Lookup.list_children(combatant_entity, Components.AvailableAction)
        |> Enum.map(&Projections.AvailableAction.project_available_action/1)

      scheduled_action_projections =
        Lookup.list_children(combatant_entity, Components.ScheduledAction)
        |> Enum.map(&Projections.ScheduledAction.project_scheduled_action/1)

      is_dodging = Ecspanse.Query.has_component?(combatant_entity, Components.Effects.Dodging)

      is_moving =
        Enum.any?(
          Ecspanse.Query.list_tagged_components_for_entity(combatant_entity, [:animation, :moving])
        )

      is_shooting =
        Enum.any?(
          Ecspanse.Query.list_tagged_components_for_entity(combatant_entity, [
            :animation,
            :shooting
          ])
        )

      is_obscured = Ecspanse.Query.has_component?(combatant_entity, Components.Effects.Obscured)

      is_throwing =
        Enum.any?(
          Ecspanse.Query.list_tagged_components_for_entity(combatant_entity, [
            :animation,
            :throwing
          ])
        )

      struct!(__MODULE__,
        available_actions: available_action_projections,
        action_points: ProjectionUtils.project(action_points),
        brand: ProjectionUtils.project(brand),
        combatant: ProjectionUtils.project(combatant),
        entity: ProjectionUtils.project(combatant_entity),
        frag_grenade: ProjectionUtils.project(frag_grenade),
        health: ProjectionUtils.project(health),
        main_weapon: ProjectionUtils.project(main_weapon),
        position: Projections.Position.project_position(position),
        profession: ProjectionUtils.project(profession),
        scheduled_actions: scheduled_action_projections,
        smoke_grenade: ProjectionUtils.project(smoke_grenade),
        is_dodging: is_dodging,
        is_moving: is_moving,
        is_shooting: is_shooting,
        is_throwing: is_throwing,
        is_obscured: is_obscured
      )
    end
  end
end