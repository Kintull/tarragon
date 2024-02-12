defmodule Tarragon.Ecspanse.Api do
  @moduledoc """
  App for code outside of the Ecspanse system
  """

  alias Tarragon.Ecspanse.MapUtils
  alias Tarragon.Ecspanse.Entities
  alias Tarragon.Ecspanse.Events

  @spec list_heroes() :: list(map())
  @doc """
  returns a list of hero maps
  see list_hero!
  """
  def list_heroes() do
    Entities.HeroApi.list_heroes()
    |> MapUtils.project()
  end

  @spec list_hero!(String.t()) :: map()
  @doc """
  returns a map of the hero and it's component values
  """
  def list_hero!(entity_id) do
    Entities.HeroApi.list_hero!(entity_id)
    |> MapUtils.project()
  end

  @spec list_markets() :: list(map())
  @doc """
  returns a list of hero maps
  see list_hero!
  """
  def list_markets() do
    Entities.MarketApi.list_markets()
    |> MapUtils.project()
  end

  @spec list_market!(String.t()) :: map()
  @doc """
  returns a map of the hero and it's component values
  """
  def list_market!(entity_id) do
    Entities.MarketApi.list_market!(entity_id)
    |> MapUtils.project()
  end

  @spec move_hero(Ecspanse.Entity.id(), direction :: :up | :down | :left | :right) :: :ok
  @doc """
  puts a MoveHero event into Ecspanse
  """
  def move_hero(entity_id, direction) do
    Ecspanse.event({Events.ChangePositionRequest, entity_id: entity_id, direction: direction})
  end

  @spec purchase_market_item(
          hero_id :: Ecspanse.Entity.id(),
          market_item_entity_id :: Ecspanse.Entity.id()
        ) :: :ok
  def purchase_market_item(hero_id, market_item_entity_id) do
    Ecspanse.event(
      {Events.PurchaseMarketItem, hero_id: hero_id, market_item_entity_id: market_item_entity_id}
    )
  end

  def spawn_heroes(count) do
    Enum.each(1..count, fn _x -> spawn_hero() end)
  end

  def spawn_hero() do
    Ecspanse.event(Events.SpawnHeroRequest)
  end
end
