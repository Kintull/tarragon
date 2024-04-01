defmodule Tarragon.Ecspanse.Demo.Systems.Startup.MarketSpawner do
  @moduledoc """
  Spawns a market at startup
  """
  alias Tarragon.Ecspanse.Demo.Entities.InventoryApi
  alias Tarragon.Ecspanse.Demo.Components
  alias Tarragon.Ecspanse.Demo.Entities

  use Ecspanse.System

  def run(_frame) do
    entity = Ecspanse.Command.spawn_entity!(Entities.Market.new())

    case Ecspanse.Query.fetch_component(entity, Components.Market) do
      {:ok, market} ->
        Ecspanse.Command.update_component!(market,
          name: Faker.Company.name()
        )
    end

    Enum.each(1..Enum.random(1..3), fn _x ->
      InventoryApi.spawn_random_inventory_item(entity)
    end)
  end
end
