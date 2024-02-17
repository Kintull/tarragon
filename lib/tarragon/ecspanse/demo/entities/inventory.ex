defmodule Tarragon.Ecspanse.Demo.Entities.Inventory do
  alias Tarragon.Ecspanse.Demo.Components.Currencies
  alias Tarragon.Ecspanse.Demo.Components.InventoryItems

  @spec new_boots() :: Ecspanse.Entity.entity_spec()
  def new_boots do
    {Ecspanse.Entity, components: [InventoryItems.Boots, {Currencies.Gold, [amount: 3], [:cost]}]}
  end

  @spec new_compass() :: Ecspanse.Entity.entity_spec()
  def new_compass do
    {Ecspanse.Entity,
     components: [
       InventoryItems.Compass,
       {Currencies.Gold, [amount: 3], [:cost]},
       {Currencies.Gems, [amount: 2], [:cost]}
     ]}
  end

  @spec new_map() :: Ecspanse.Entity.entity_spec()
  def new_map do
    {Ecspanse.Entity, components: [InventoryItems.Map, {Currencies.Gold, [amount: 2], [:cost]}]}
  end

  @spec new_potion() :: Ecspanse.Entity.entity_spec()
  def new_potion do
    {Ecspanse.Entity,
     components: [InventoryItems.Potion, {Currencies.Gold, [amount: 1], [:cost]}]}
  end
end
