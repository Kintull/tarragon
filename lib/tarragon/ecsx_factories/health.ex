defmodule Tarragon.EcsxFactories.Health do
  @moduledoc """
  Health is a composite of health points and max health points.
  """
  alias Tarragon.EcsxFactories.Health
  alias Tarragon.Components.HealthMaxPoints
  alias Tarragon.Components.HealthPoints
  import Tarragon.Systems.SystemHelpers

  @dead :dead
  @full :full
  @injured :injured

  use TypedStruct

  typedstruct enforce: true do
    field :entity, binary
    field :points, integer, default: 5
    field :max_points, integer, default: 10
    field :status, atom, default: @injured
  end

  def dead, do: @dead
  def full, do: @full
  def injured, do: @injured

  defguard is_dead(value) when value == @dead
  defguard is_full(value) when value == @full
  defguard is_injured(value) when value == @injured

  def determine_health_status(points, _max_points) when points == 0, do: dead()

  def determine_health_status(points, max_points) when points < max_points,
    do: injured()

  def determine_health_status(_points, _max_points), do: full()

  def spawn_callback(entity, points, max_points) do
    upsert(entity, HealthPoints, points, persist: true)
    upsert(entity, HealthMaxPoints, max_points, persist: true)
  end

  @spec get_all(list({Component.id(), any()})) :: list(Health.t())
  def get_all(tuples), do: Enum.map(tuples, &get(&1))

  @spec get({Component.id(), any()}) :: Health.t()
  def get({entity, _value}), do: get(entity)

  @spec get(Component.id()) :: Health.t()
  def get(entity) do
    points = HealthPoints.get(entity)
    max_points = HealthMaxPoints.get(entity)

    %__MODULE__{
      entity: entity,
      points: points,
      max_points: max_points,
      status: determine_health_status(points, max_points)
    }
  end

  @spec get_all_injured() :: list(Health.t())
  def get_all_injured() do
    HealthPoints.at_least(1)
    |> get_all()
    |> Enum.filter(fn health ->
      health.points < health.max_points
    end)
  end

  def remove(entity) do
    remove_components(entity, [
      HealthPoints,
      HealthMaxPoints
    ])
  end
end
