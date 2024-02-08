defmodule Tarragon.EcsxFactories.DamageOverTime do
  alias Tarragon.Components.DamageOverTimeOccurrencesRemaining
  alias Tarragon.Components.DamageOverTimeTarget
  alias Tarragon.Components.DamageOverTimeRateInMs
  alias Tarragon.Components.DamageOverTimeName
  use TypedStruct

  typedstruct enforce: true do
    field :name, binary, default: "dot"
    field :rate_in_ms, integer, default: 1000
    field :occurrences_remaining, integer, default: 10
    field :target, binary
  end

  def spawn_callback(target, name, occurrences, rate_in_ms) do
    dot_id = Ecto.UUID.generate()
    DamageOverTimeName.add(dot_id, name)
    DamageOverTimeOccurrencesRemaining.add(dot_id, occurrences)
    DamageOverTimeRateInMs.add(dot_id, rate_in_ms)
    DamageOverTimeTarget.add(dot_id, target)
  end

  def get_for_target(target) do
    DamageOverTimeTarget.search(target)
    |> Enum.map(fn entity ->
      %__MODULE__{
        name: DamageOverTimeName.get(entity),
        rate_in_ms: DamageOverTimeRateInMs.get(entity),
        occurrences_remaining: DamageOverTimeOccurrencesRemaining.get(entity),
        target: DamageOverTimeTarget.get(entity)
      }
    end)
  end

  def remove(entity) do
    DamageOverTimeName.remove(entity)
    DamageOverTimeOccurrencesRemaining.remove(entity)
    DamageOverTimeRateInMs.remove(entity)
    DamageOverTimeTarget.remove(entity)
  end
end
