defmodule Tarragon.Ecspanse.Entities.InventoryApi do
  @moduledoc """
  Internal api to get inventory items with their components
  """
  alias Tarragon.Ecspanse.Entities.Inventory

  use TypedStruct

  typedstruct module: InventoryItem, enforce: true do
    field :entity, Ecspanse.Entity.t()
    field :item, Component.t()
    field :costs, list(), default: []
  end

  @spec list_inventory_items(Ecspanse.Entity.t()) :: list(__MODULE__.InventoryItem)
  def list_inventory_items(%Ecspanse.Entity{} = parent) do
    Ecspanse.Query.list_tagged_components_for_children(parent, [:inventory])
    |> Enum.map(fn item_component ->
      item_entity =
        Ecspanse.Query.get_component_entity(item_component)

      costs =
        Ecspanse.Query.list_tagged_components_for_entity(item_entity, [:currency, :cost])
        |> Enum.sort_by(& &1.name)

      %__MODULE__.InventoryItem{
        costs: costs,
        entity: item_entity,
        item: item_component
      }
    end)
    |> Enum.sort_by(& &1.item.name)
  end

  @spec fetch_inventory_item(Ecspanse.Entity.id()) :: __MODULE__.InventoryItem.t()
  def fetch_inventory_item(entity_id) do
    {:ok, entity} = Ecspanse.Entity.fetch(entity_id)

    {:ok, item} =
      Ecspanse.Query.fetch_tagged_component(entity, [:inventory])

    costs =
      Ecspanse.Query.list_tagged_components_for_entity(entity, [:currency, :cost])
      |> Enum.sort_by(& &1.name)

    %__MODULE__.InventoryItem{
      costs: costs,
      entity: entity,
      item: item
    }
  end

  def spawn_random_inventory_item(parent_entity \\ nil) do
    inventory_item =
      case Enum.random([:boots, :compass, :map, :potion]) do
        :boots ->
          Ecspanse.Command.spawn_entity!(Inventory.new_boots())

        :compass ->
          Ecspanse.Command.spawn_entity!(Inventory.new_compass())

        :map ->
          Ecspanse.Command.spawn_entity!(Inventory.new_map())

        :potion ->
          Ecspanse.Command.spawn_entity!(Inventory.new_potion())
      end

    if parent_entity, do: Ecspanse.Command.add_child!(parent_entity, inventory_item)
    inventory_item
  end
end
