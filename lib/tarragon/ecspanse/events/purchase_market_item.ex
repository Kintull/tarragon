defmodule Tarragon.Ecspanse.Events.PurchaseMarketItem do
  use Ecspanse.Event, fields: [:hero_id, :market_item_entity_id]
end
