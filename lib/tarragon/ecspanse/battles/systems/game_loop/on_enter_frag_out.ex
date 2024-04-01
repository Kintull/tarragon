defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterFragOut do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Lookup

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: "Frag Out"},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(
          &Ecspanse.Query.has_component?(&1, Components.Actions.TossExplosiveGrenade)
        )

      decrement_explosive_grenade_counts(scheduled_action_entities)

      spawn_explosive_grenades(battle_entity, scheduled_action_entities)

      Ecspanse.Command.despawn_entities!(scheduled_action_entities)
    end
  end

  def run(_, _), do: :ok

  defp spawn_explosive_grenades(battle_entity, scheduled_action_entities) do
    explosive_grenade_entities =
      scheduled_action_entities
      |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
      |> Enum.map(&(Components.Position.fetch(&1) |> Withables.val_or_nil()))
      |> Enum.map(&Entities.Grenade.explosive_grenade_blueprint(battle_entity, &1.x))
      |> Ecspanse.Command.spawn_entities!()

    explosive_grenade_entities
    |> IO.inspect(label: "explosive_grenade_entities")
    |> Enum.map(&create_animation_spec/1)
    |> IO.inspect(label: "create_animation_spec")
    |> Ecspanse.Command.add_components!()
  end

  defp create_animation_spec(explosive_grenade_entity) do
    with {:ok, {grenade, position}} <-
           Ecspanse.Query.fetch_components(
             explosive_grenade_entity,
             {Components.Grenades.ExplosiveGrenade, Components.Position}
           ) do
      {explosive_grenade_entity,
       [
         {Components.Animations.Moving,
          [from: position.x, to: position.x + grenade.range, duration: 250]}
       ]}
    end
  end

  defp decrement_explosive_grenade_counts(scheduled_action_entities) do
    scheduled_action_entities
    |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
    |> Enum.map(
      &(Ecspanse.Query.fetch_component(&1, Components.GrenadePouch)
        |> Withables.val_or_nil())
    )
    |> Enum.map(&{&1, explosive: &1.explosive - 1})
    |> Ecspanse.Command.update_components!()
  end
end
