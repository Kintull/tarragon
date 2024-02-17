defmodule Tarragon.Ecspanse.Demo.Entities.HeroApi do
  @moduledoc """
  Internal api to get entities with their components
  """
  alias Tarragon.Ecspanse.Demo.Entities.InventoryApi
  alias Tarragon.Ecspanse.Demo.Components

  use TypedStruct

  typedstruct module: Hero, enforce: true do
    field :entity, Ecspanse.Entity.t()
    field :hero, Components.Hero.t()
    field :health, Components.Health.t()
    field :health_regen_timer, Components.HealthRegenTimer.t()
    field :energy, Components.Energy.t()
    field :energy_regen_timer, Components.EnergyRegenTimer.t()
    field :position, Components.Position.t()
    field :currencies, list(), default: []
    field :inventory, list(), default: []
  end

  @spec list_heroes() :: list(__MODULE__.Hero.t())
  @doc """
  returns heroes with their components
  """
  def list_heroes() do
    Ecspanse.Query.select({Ecspanse.Entity}, with: [Components.Hero])
    |> Ecspanse.Query.stream()
    |> Enum.map(fn {entity} -> list_hero!(entity) end)
  end

  @spec list_hero!(Ecspanse.Entity.id()) :: __MODULE__.Hero.t()
  def list_hero!(entity_id) when is_binary(entity_id) do
    case Ecspanse.Entity.fetch(entity_id) do
      {:ok, entity} -> list_hero!(entity)
      err -> raise err
    end
  end

  @spec list_hero!(Ecspanse.Entity.t()) :: __MODULE__.Hero.t()
  def list_hero!(%Ecspanse.Entity{} = entity) do
    case Ecspanse.Query.fetch_components(
           entity,
           {Components.Hero, Components.Health, Components.HealthRegenTimer, Components.Energy,
            Components.EnergyRegenTimer, Components.Position}
         ) do
      {:ok, {hero, health, health_regen_timer, energy, energy_timer, position}} ->
        currencies =
          Ecspanse.Query.list_tagged_components_for_entity(entity, [:currency, :available])
          |> Enum.sort_by(& &1.name)

        inventory =
          InventoryApi.list_inventory_items(entity)

        %__MODULE__.Hero{
          entity: entity,
          hero: hero,
          health: health,
          health_regen_timer: health_regen_timer,
          energy: energy,
          energy_regen_timer: energy_timer,
          position: position,
          currencies: currencies,
          inventory: inventory
        }

      err ->
        raise err
    end
  end
end
