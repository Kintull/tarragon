defmodule Tarragon.Ecspanse.Demo.Systems.FrameStart.MarketRestocker do
  @moduledoc """
  Listens for EnergyChanged events and pauses or unpauses the EnergyRegenTimer
  depending on energy
  """
  alias Tarragon.Ecspanse.Demo.Entities.InventoryApi
  alias Tarragon.Ecspanse.Demo.Entities
  alias Tarragon.Ecspanse.Demo.Events

  use Ecspanse.System,
    event_subscriptions: [Events.MarketRestockTimerElapsed]

  def run(%Events.MarketRestockTimerElapsed{entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id) do
      market = Entities.MarketApi.list_market!(entity)

      if length(market.inventory) < 6 do
        InventoryApi.spawn_random_inventory_item(market.entity)
      end
    end
  end
end