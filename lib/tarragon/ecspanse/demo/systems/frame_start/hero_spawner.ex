defmodule Tarragon.Ecspanse.Demo.Systems.FrameStart.HeroSpawner do
  @moduledoc """
  Subscribes to SpawnHeroRequest events and spawns a hero
  """

  alias Tarragon.Ecspanse.Demo.Entities.Inventory
  alias Tarragon.Ecspanse.Demo.Components
  alias Tarragon.Ecspanse.Demo.Components.Currencies
  alias Tarragon.Ecspanse.Demo.Entities
  alias Tarragon.Ecspanse.Demo.Events.SpawnHeroRequest
  alias Tarragon.Ecspanse.Demo.Events

  use Ecspanse.System, event_subscriptions: [Events.SpawnHeroRequest]

  @impl true
  def run(%SpawnHeroRequest{}, _frame) do
    entity = Ecspanse.Command.spawn_entity!(Entities.Hero.new())

    case Ecspanse.Query.fetch_component(entity, Components.Hero) do
      {:ok, hero} ->
        Ecspanse.Command.update_component!(hero,
          name: Faker.Superhero.name(),
          color: Faker.Color.rgb_hex()
        )
    end

    case Ecspanse.Query.fetch_component(entity, Components.Position) do
      {:ok, position} ->
        Ecspanse.Command.update_component!(position,
          x: Enum.random(-10..10),
          y: Enum.random(-10..10)
        )
    end

    case Ecspanse.Query.fetch_component(entity, Components.Health) do
      {:ok, health} ->
        max = Enum.random(100..300)
        current = Enum.random(1..max)
        Ecspanse.Command.update_component!(health, max: max, current: current)
    end

    case Ecspanse.Query.fetch_component(entity, Components.Energy) do
      {:ok, health} ->
        current = Enum.random(1..100)
        Ecspanse.Command.update_component!(health, current: current)
    end

    case Ecspanse.Query.fetch_component(entity, Currencies.Gold) do
      {:ok, currency} -> Ecspanse.Command.update_component!(currency, amount: Enum.random(2..5))
    end

    case Ecspanse.Query.fetch_component(entity, Currencies.Gems) do
      {:ok, currency} -> Ecspanse.Command.update_component!(currency, amount: Enum.random(2..5))
    end

    Enum.each(1..Enum.random(1..1), fn _x ->
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

      Ecspanse.Command.add_child!(entity, inventory_item)
    end)
  end
end
