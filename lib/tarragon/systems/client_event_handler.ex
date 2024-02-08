defmodule Tarragon.Systems.ClientEventHandler do
  @moduledoc """
  Documentation for ClientEventHandler system.
  """
  alias Tarragon.EcsxFactories.DamageOverTime
  alias Tarragon.Components.OneShotDamageTarget
  alias Tarragon.Components.OneShotDamagePoints
  alias Tarragon.EcsxFactories.Character
  alias Tarragon.Components.HealthRegenerationRateInMs
  import Tarragon.Systems.SystemHelpers

  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic
    client_events = ECSx.ClientEvents.get_and_clear()

    Enum.each(client_events, &process_event/1)
    :ok
  end

  defp process_event({_entity, {:spawn, character, callback_fn}}) do
    callback_fn.(character)
  end

  # Creates or updates a player
  defp process_event({_entity, {:spawn_character, %Character{} = character}}) do
    Character.spawn_callback(character)
  end

  defp process_event({entity, :remove_character}) do
    Character.remove(entity)
  end

  defp process_event({_entity, {:randomize_health_points}}) do
    Tarragon.Components.HealthPoints.get_all()
    |> Enum.each(fn {entity, _hp} ->
      max = Tarragon.Components.HealthMaxPoints.get(entity)
      Tarragon.Components.HealthPoints.update(entity, Enum.random(1..max))
    end)
  end

  defp process_event({_entity, {:randomize_damage_over_time, percent}}) do
    all = Tarragon.Components.DisplayName.get_all()
    take = ceil(percent * length(all) / 100)

    all
    |> Enum.take_random(take)
    |> Enum.each(fn {entity, _name} ->
      dot_name = if Enum.random(0..1) == 0, do: "☢️", else: "🤮"

      Tarragon.EcsxFactories.DamageOverTime.spawn_callback(
        entity,
        dot_name,
        Enum.random(5..25),
        Enum.random(1..50) * 100
      )
    end)
  end

  # applies one shot damage
  defp process_event({entity, {:one_shot_damage, damage}}) do
    one_shot_id = Ecto.UUID.generate()
    OneShotDamagePoints.add(one_shot_id, damage)
    OneShotDamageTarget.add(one_shot_id, entity)
  end

  # initiates damage over time
  defp process_event({entity, {:damage_over_time, name, occurrences, rate_in_ms}}) do
    DamageOverTime.spawn_callback(entity, name, occurrences, rate_in_ms)
  end

  # instant heal
  # defp process_event({entity, {:instant_heal, points}}) do
  #   InstantHeal.add(entity, points)
  # end

  defp process_event(
         {entity, {:health_regeneration_rate_in_ms_changed, health_regeneration_rate_in_ms}}
       ) do
    upsert(entity, HealthRegenerationRateInMs, health_regeneration_rate_in_ms)
  end

  # traps unhandled events
  defp process_event(tuple) do
    IO.inspect(tuple, label: "ClientEventHandler Unhandled event")
  end
end
