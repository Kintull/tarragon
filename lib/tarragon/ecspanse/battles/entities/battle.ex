defmodule Tarragon.Ecspanse.Battles.Entities.Battle do
  @moduledoc """
  Factory for creating a battle
  """
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  require Logger

  @spec list_living_combatants(Ecspanse.Entity.t()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns a list of entities descendent from the battle entity that have current health > 0.
  """
  def list_living_combatants(%Ecspanse.Entity{} = entity) do
    Lookup.list_descendants(entity, Components.Combatant)
    |> Enum.filter(fn descendant ->
      {:ok, health_component} = Components.Health.fetch(descendant)
      health_component.current > 0
    end)
  end

  def blueprint(name) do
    {Ecspanse.Entity,
     components: [
       {Components.Battle, [name: name]},
       EcspanseStateMachine.state_machine(
         "Battle Start",
         [
           [name: "Battle Start", exits_to: ["Decisions Phase"]],
           [name: "Decisions Phase", exits_to: ["Action Phase Start"]],
           [name: "Action Phase Start", exits_to: ["Pop Smoke"]],
           [name: "Pop Smoke", exits_to: ["Frag Out"]],
           [name: "Frag Out", exits_to: ["Dodge"]],
           [name: "Dodge", exits_to: ["Unpack Weapons"]],
           [name: "Unpack Weapons", exits_to: ["Shooting"]],
           [name: "Shooting", exits_to: ["Frag Grenades Detonate"]],
           [name: "Frag Grenades Detonate", exits_to: ["Pack Weapons"]],
           [name: "Pack Weapons", exits_to: ["Move"]],
           [name: "Move", exits_to: ["Action Phase End"]],
           [name: "Action Phase End", exits_to: ["Decisions Phase", "Battle End"]],
           [name: "Battle End", exits_to: []]
         ],
         false
       ),
       EcspanseStateMachine.state_timer([
         [name: "Battle Start", duration: 3_000, exits_to: "Decisions Phase"],
         [name: "Decisions Phase", duration: 15_000, exits_to: "Action Phase Start"],
         [name: "Action Phase Start", duration: 1_000, exits_to: "Pop Smoke"],
         [name: "Pop Smoke", duration: 1_000, exits_to: "Frag Out"],
         [name: "Frag Out", duration: 1_000, exits_to: "Dodge"],
         [name: "Dodge", duration: 1_000, exits_to: "Unpack Weapons"],
         [name: "Unpack Weapons", duration: 1_000, exits_to: "Shooting"],
         [name: "Shooting", duration: 1_000, exits_to: "Frag Grenades Detonate"],
         [name: "Frag Grenades Detonate", duration: 1_000, exits_to: "Pack Weapons"],
         [name: "Pack Weapons", duration: 1_000, exits_to: "Move"],
         [name: "Move", duration: 1_000, exits_to: "Action Phase End"]
       ])
     ]}
  end
end
