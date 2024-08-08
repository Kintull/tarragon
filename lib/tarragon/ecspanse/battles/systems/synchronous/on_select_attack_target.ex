defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnSelectAttackTarget do
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
      event_subscriptions: [Events.SelectMoveTile]

  def run(
        %Events.SelectAttackTarget{combatant_entity_id: combatant_entity_id, character_id: character_id},
        _frame
      ) do
    {:ok, combatant_entity} = Ecspanse.Entity.fetch(combatant_entity_id)
    {:ok, attack_target_component} =
      Ecspanse.Query.fetch_component(
        combatant_entity,
        Components.AttackActionTarget
      )

    Ecspanse.Command.update_component!(attack_target_component, user_id: character_id, combatant_entity_id: combatant_entity.id)
  end

end
