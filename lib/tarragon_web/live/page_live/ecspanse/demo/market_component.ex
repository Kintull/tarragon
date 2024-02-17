defmodule TarragonWeb.PageLive.Ecspanse.Demo.MarketComponent do
  use TarragonWeb, :live_component

  def mount(socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
    <div
      class="bg-neutral-700 p-2 rounded-xl
      flex flex-col
      divide-y-2 divide-neutral-500"
      id={"market_entity_#{@market.entity.id}"}
    >
      <div class="m-2 text-neutral-300 font-semibold">
        🏪 <%= @market.market.name %>
      </div>
      
      <div class="m-1 text-neutral-300">
        Shopper: <%= @hero_name %>
      </div>
       <.market_items inventory={@market.inventory} hero_id={@hero_id} />
    </div>
    """
  end

  attr :inventory, :list
  attr :hero_id, :string

  def market_items(assigns) do
    ~H"""
    <div class="pt-2 flex flex-wrap gap-2">
      <div
        :for={market_item <- @inventory}
        class="bg-neutral-700 text-neutral-100
            border-2 border-neutral-500
            shadow-md shadow-neutral-500
            rounded-xl
            p-2
            grid grid-cols-1"
        id={"market_item_entity_id_#{market_item.entity.id}"}
        phx-click="purchase_market_item"
        phx-value-market_item_entity_id={market_item.entity.id}
        phx-value-hero_id={@hero_id}
      >
        <div>
          <%= market_item.item.icon %> <%= market_item.item.name %>
        </div>
        
        <div>
          <span :for={cost <- market_item.costs} title={"#{cost.amount} #{cost.type}"}>
            <%= cost.amount %> <%= cost.icon %>
          </span>
        </div>
      </div>
    </div>
    """
  end
end
