defmodule Tarragon.Ecspanse.Entities.MarketApi do
  @moduledoc """
  Internal api to get entities with their components
  """
  alias Tarragon.Ecspanse.Entities.InventoryApi
  alias Tarragon.Ecspanse.Components

  use TypedStruct

  typedstruct module: Market, enforce: true do
    field :entity, Ecspanse.Entity.t()
    field :market, Components.Market.t()
    field :market_restock_timer, Components.MarketRestockTimer.t()
    field :inventory, list(), default: []
  end

  @spec list_markets() :: list(__MODULE__.Market.t())
  @doc """
  returns markets with their components
  """
  def list_markets() do
    Ecspanse.Query.select({Ecspanse.Entity}, with: [Components.Market])
    |> Ecspanse.Query.stream()
    |> Enum.map(fn {entity} -> list_market!(entity) end)

    # |> IO.inspect(label: "markets")
  end

  @spec list_market!(Ecspanse.Entity.id()) :: __MODULE__.Market.t()
  def list_market!(entity_id) when is_binary(entity_id) do
    case Ecspanse.Entity.fetch(entity_id) do
      {:ok, entity} -> list_market!(entity)
      err -> raise err
    end
  end

  @spec list_market!(Ecspanse.Entity.t()) :: __MODULE__.Market.t()
  def list_market!(%Ecspanse.Entity{} = entity) do
    case Ecspanse.Query.fetch_components(
           entity,
           {Components.Market, Components.MarketRestockTimer}
         ) do
      {:ok, {market, restock_timer}} ->
        inventory = InventoryApi.list_inventory_items(entity)

        %__MODULE__.Market{
          entity: entity,
          market: market,
          market_restock_timer: restock_timer,
          inventory: inventory
        }

      err ->
        raise err
    end
  end
end
