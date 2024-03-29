defprotocol Tarragon.Ecspanse.Battles.Encumbering do
  @spec encumber(t()) :: number()
  def encumber(value)
end

defimpl Tarragon.Ecspanse.Battles.Encumbering,
  for: Tarragon.Ecspanse.Battles.Components.Combatant do
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Encumbering

  @spec encumber(%Tarragon.Ecspanse.Battles.Components.Combatant{}) :: number()
  def encumber(component) do
    entity = Ecspanse.Query.get_component_entity(component)

    with {:ok, {frag_grenade, main_weapon, smoke_grenade}} <-
           Ecspanse.Query.fetch_components(
             entity,
             {Components.FragGrenade, Components.MainWeapon, Components.SmokeGrenade}
           ) do
      Encumbering.encumber(frag_grenade) + Encumbering.encumber(main_weapon) +
        Encumbering.encumber(smoke_grenade)
    end
  end
end

defimpl Tarragon.Ecspanse.Battles.Encumbering,
  for: Tarragon.Ecspanse.Battles.Components.FragGrenade do
  @spec encumber(%Tarragon.Ecspanse.Battles.Components.FragGrenade{}) :: number()
  def encumber(component) do
    component.encumbrance * component.count
  end
end

defimpl Tarragon.Ecspanse.Battles.Encumbering,
  for: Tarragon.Ecspanse.Battles.Components.MainWeapon do
  @spec encumber(%Tarragon.Ecspanse.Battles.Components.MainWeapon{}) :: number()
  def encumber(component) do
    case component.deployed do
      true -> component.deployed_encumbrance
      false -> component.packed_encumbrance
    end
  end
end

defimpl Tarragon.Ecspanse.Battles.Encumbering,
  for: Tarragon.Ecspanse.Battles.Components.SmokeGrenade do
  @spec encumber(%Tarragon.Ecspanse.Battles.Components.SmokeGrenade{}) :: number()
  def encumber(component) do
    component.encumbrance * component.count
  end
end
