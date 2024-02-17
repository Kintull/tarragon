defmodule Tarragon.Ecspanse.Demo.Systems.FrameEnd.MarketPurchaseManager do
  @moduledoc """
  Listens for PurchaseMarketItem events and completes the transaction
  if the hero has sufficient money
  """
  alias Tarragon.Ecspanse.Demo.Entities
  alias Tarragon.Ecspanse.Demo.Events
  alias Tarragon.Ecspanse.Demo.Components
  alias Tarragon.Ecspanse.Demo.Events.PurchaseMarketItem

  use Ecspanse.System,
    event_subscriptions: [Events.PurchaseMarketItem]

  def run(
        %PurchaseMarketItem{hero_id: hero_id, market_item_entity_id: market_item_entity_id},
        _frame
      ) do
    market_item = Entities.InventoryApi.fetch_inventory_item(market_item_entity_id)
    hero = Entities.HeroApi.list_hero!(hero_id)

    if has_enough_money?(hero.currencies, market_item.costs) do
      market_entity =
        Ecspanse.Query.list_parents(market_item.entity)
        |> Enum.find(fn p -> Ecspanse.Query.has_component?(p, Components.Market) end)

      spend_resources(hero.currencies, market_item.costs)
      Ecspanse.Command.remove_child!(market_entity, market_item.entity)
      Ecspanse.Command.add_child!(hero.entity, market_item.entity)
    end
  end

  defp spend_resources(available_resources, cost_resources) do
    Enum.each(cost_resources, fn cost_resource ->
      available_resource =
        Enum.find(available_resources, fn available_resource ->
          available_resource.type == cost_resource.type
        end)

      Ecspanse.Command.update_component!(available_resource,
        amount: available_resource.amount - cost_resource.amount
      )
    end)
  end

  defp has_enough_money?(available_resources, cost_resources) do
    Enum.all?(cost_resources, fn cost_resource ->
      Enum.any?(available_resources, fn available_resource ->
        available_resource.type == cost_resource.type &&
          available_resource.amount >= cost_resource.amount
      end)
    end)
  end
end
