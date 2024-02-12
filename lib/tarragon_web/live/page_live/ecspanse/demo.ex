defmodule TarragonWeb.PageLive.Ecspanse.Demo do
  @moduledoc """
  The hero screen
  """
  alias Tarragon.Ecspanse.Api
  use TarragonWeb, :live_view

  defp fetch_and_assign_heroes(socket) do
    heroes = Api.list_heroes()

    socket
    |> assign(:heroes, heroes)
  end

  defp fetch_and_assign_markets(socket) do
    markets = Api.list_markets()

    socket
    |> assign(markets: markets)
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(200, self(), :tick)
    end

    socket =
      socket
      |> fetch_and_assign_heroes()
      |> fetch_and_assign_markets()

    {:ok, socket}
  end

  def handle_event("move", %{"direction" => direction_string, "entity_id" => entity_id}, socket) do
    direction = String.to_atom(direction_string)
    Api.move_hero(entity_id, direction)
    {:noreply, socket}
  end

  def handle_event(
        "purchase_market_item",
        %{"market_item_entity_id" => market_item_entity_id, "hero_id" => hero_id},
        socket
      ) do
    Api.purchase_market_item(hero_id, market_item_entity_id)

    {:noreply, socket}
  end

  def handle_event("spawn_heroes", %{"count" => count}, socket) do
    Api.spawn_heroes(String.to_integer(count))
    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: "unhandled_event")
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    socket =
      socket
      |> fetch_and_assign_heroes()
      |> fetch_and_assign_markets()

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "unhandled_info")
    {:noreply, socket}
  end
end
