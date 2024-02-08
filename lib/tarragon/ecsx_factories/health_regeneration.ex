defmodule Tarragon.EcsxFactories.HealthRegeneration do
  @moduledoc """
  Health is a composite of health points and max health points.
  """
  alias Tarragon.Components.HealthRegenerationRateInMs
  alias Tarragon.Components.HealthRegenerationStatus
  import Tarragon.Systems.SystemHelpers

  use TypedStruct

  typedstruct enforce: true do
    # field :entity, binary
    field :rate_in_ms, integer, default: 2000
    field :status, atom, default: HealthRegenerationStatus.idle()
  end

  def spawn_callback(entity, %__MODULE__{} = regen) do
    upsert(entity, HealthRegenerationRateInMs, regen.rate_in_ms, persist: true)
  end

  def get(entity) do
    %__MODULE__{
      rate_in_ms: HealthRegenerationRateInMs.get(entity, 1000),
      status: HealthRegenerationStatus.get(entity, HealthRegenerationStatus.idle())
    }
  end

  def remove(entity) do
    remove_components(entity, [
      HealthRegenerationRateInMs,
      HealthRegenerationStatus
    ])
  end
end
