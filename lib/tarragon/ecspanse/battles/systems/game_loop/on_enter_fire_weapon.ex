defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterFireWeapon do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.fire_weapon

  require Logger

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterFireWeapon #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)

      shoot_scheduled_actions =
        Enum.filter(
          scheduled_action_entities,
          &Ecspanse.Query.has_component?(&1, Components.Actions.Shooting.Shoot)
        )

      double_tap_scheduled_actions =
        Enum.filter(
          scheduled_action_entities,
          &Ecspanse.Query.has_component?(&1, Components.Actions.Shooting.DoubleTap)
        )

      if Enum.any?(shoot_scheduled_actions) or Enum.any?(double_tap_scheduled_actions) do
        shoot_scheduled_actions
        |> Enum.each(&fire_main_weapon(battle_entity, &1))

        double_tap_scheduled_actions
        |> IO.inspect(label: "Double scheduled actions")
        |> Enum.each(fn sa ->
          fire_main_weapon(battle_entity, sa)
          fire_main_weapon(battle_entity, sa)
        end)

        shoot_scheduled_actions |> Ecspanse.Command.despawn_entities!()
        double_tap_scheduled_actions |> Ecspanse.Command.despawn_entities!()
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  defp fire_main_weapon(battle_entity, scheduled_action_entity) do
    with {:ok, shooter_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, {position, main_weapon}} <-
           Ecspanse.Query.fetch_components(
             shooter_entity,
             {Components.Position, Components.MainWeapon}
           ),
         {:ok, action} <-
           Ecspanse.Query.fetch_tagged_component(scheduled_action_entity, [:action, :shooting]),
         {:ok, target_entity} <- Ecspanse.Entity.fetch(action.target_entity_id),
         {:ok, target_position} <- Components.Position.fetch(target_entity) do
      Enum.each(
        Range.new(1, main_weapon.projectiles_per_shot),
        fn _ ->
          spawn_projectile(
            battle_entity,
            position,
            action.target_entity_id,
            target_position,
            main_weapon.damage_per_projectile
          )
        end
      )
    end
  end

  defp spawn_projectile(battle_entity, position, target_entity_id, target_position, damage) do
    bullet_entity =
      Ecspanse.Command.spawn_entity!(
        Entities.Bullet.new(
          battle_entity,
          position,
          target_entity_id,
          damage
        )
      )

    Ecspanse.Command.spawn_entity!(
      Entities.Animations.Moving.new(
        bullet_entity,
        position,
        target_position,
        @movement_durations.bullets
      )
    )
  end
end
