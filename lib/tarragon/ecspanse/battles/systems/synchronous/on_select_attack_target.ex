defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnSelectAttackTarget do
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
      event_subscriptions: [Events.SelectAttackTarget]

  def run(
        %Events.SelectAttackTarget{
          player_combatant_entity_id: player_combatant_entity_id,
          selected_combatant_entity_id: selected_combatant_entity_id
        },
        _frame
      ) do
    IO.inspect("OnSelectAttackTarget for: #{player_combatant_entity_id}, selected: #{selected_combatant_entity_id}")
    {:ok, combatant_entity} = Ecspanse.Entity.fetch(player_combatant_entity_id)
    {:ok, attack_target_component} =
      Ecspanse.Query.fetch_component(
        combatant_entity,
        Components.AttackActionTarget
      )

    :ok = Ecspanse.Command.update_component!(attack_target_component, entity_id: selected_combatant_entity_id)
  end

end
