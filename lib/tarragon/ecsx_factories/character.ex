defmodule Tarragon.EcsxFactories.Character do
  alias Tarragon.EcsxFactories.DamageOverTime
  alias Tarragon.EcsxFactories.HealthRegeneration
  alias Tarragon.EcsxFactories.Health
  alias Tarragon.Components.DisplayName
  import Tarragon.Systems.SystemHelpers

  use TypedStruct

  typedstruct enforce: true do
    field :entity, binary
    field :name, integer
    field :health, Health.t()
    field :health_regeneration, HealthRegeneration.t()
    field :damage_over_time, list(DamageOverTime.t()), default: []
  end

  def spawn_entity(
        %__MODULE__{
          entity: entity
        } = character
      ) do
    ECSx.ClientEvents.add(entity, {:spawn, character, &spawn_callback/1})
  end

  def spawn_callback(%__MODULE__{
        entity: entity,
        name: name,
        health: health,
        health_regeneration: health_regeneration
      }) do
    upsert(entity, DisplayName, name, persist: true)
    Health.spawn_callback(entity, health.points, health.max_points)
    HealthRegeneration.spawn_callback(entity, health_regeneration)
  end

  def get_all() do
    DisplayName.get_all()
    |> Enum.map(fn {entity, _name} -> get(entity) end)
  end

  def get(%__MODULE__{entity: entity}), do: get(entity)

  def get(entity) do
    %__MODULE__{
      entity: entity,
      name: DisplayName.get(entity),
      health: Health.get(entity),
      health_regeneration: HealthRegeneration.get(entity),
      damage_over_time: DamageOverTime.get_for_target(entity)
    }
  end

  def remove(%__MODULE__{entity: entity}), do: remove(entity)

  def remove(entity) do
    DisplayName.remove(entity)
    Health.remove(entity)
    HealthRegeneration.remove(entity)
  end
end
