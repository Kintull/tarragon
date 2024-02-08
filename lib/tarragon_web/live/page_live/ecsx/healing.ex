defmodule TarragonWeb.PageLive.ECSx.Healing do
  use TarragonWeb, :live_view

  alias Tarragon.EcsxFactories.Character

  @spec mount(any(), any(), map()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_new(:characters, fn -> [] end)

    if connected?(socket) do
      :timer.send_interval(100, :load_characters)
    end

    {:ok, socket}
  end

  def handle_info(:load_characters, socket) do
    updated_characters = Character.get_all()

    socket = assign(socket, :characters, updated_characters)

    {:noreply, socket}
  end

  def handle_event("delete-characters", _params, socket) do
    Character.get_all()
    |> Enum.each(fn c ->
      ECSx.ClientEvents.add(c.entity, :remove_character)
    end)

    {:noreply, socket}
  end

  def handle_event("generate-characters", %{"count" => count_str}, socket) do
    Enum.map(1..String.to_integer(count_str), fn _ ->
      maxPoints = Enum.random(200..500)

      character_id = Ecto.UUID.generate()

      %Tarragon.EcsxFactories.Character{
        entity: character_id,
        name: MnemonicSlugs.generate_slug(2),
        health: %Tarragon.EcsxFactories.Health{
          entity: character_id,
          points: Enum.random(1..maxPoints),
          max_points: maxPoints
        },
        health_regeneration: %Tarragon.EcsxFactories.HealthRegeneration{
          rate_in_ms: Enum.random(2..10) * 1000
        }
      }
    end)
    |> Enum.each(&ECSx.ClientEvents.add(&1.entity, {:spawn_character, &1}))

    {:noreply, socket}
  end

  def handle_event("randomize-health", _unsigned_params, socket) do
    ECSx.ClientEvents.add(:none, {:randomize_health_points})
    {:noreply, socket}
  end

  def handle_event("randomize_damage_over_time", %{"percent" => percent_str}, socket) do
    ECSx.ClientEvents.add(:none, {:randomize_damage_over_time, String.to_integer(percent_str)})
    {:noreply, socket}
  end

  def handle_event("dagger_attack", %{"damage" => damage, "entity" => entity}, socket) do
    ECSx.ClientEvents.add(entity, {:one_shot_damage, String.to_integer(damage)})
    {:noreply, socket}
  end

  def handle_event(
        "damage_over_time_attack",
        %{
          "occurrences" => occurrences,
          "entity" => entity,
          "rate-in-ms" => rate_in_ms,
          "name" => name
        },
        socket
      ) do
    ECSx.ClientEvents.add(
      entity,
      {:damage_over_time, name, String.to_integer(occurrences), String.to_integer(rate_in_ms)}
    )

    {:noreply, socket}
  end

  def handle_event("instant_heal", %{"points" => points, "entity" => entity}, socket) do
    ECSx.ClientEvents.add(entity, {:instant_heal, String.to_integer(points)})

    {:noreply, socket}
  end

  def handle_event(
        "health_regeneration_rate_in_ms_changed",
        %{
          "health_regeneration_rate_in_ms" => health_regeneration_rate_in_ms,
          "entity" => entity
        },
        socket
      ) do
    ECSx.ClientEvents.add(
      entity,
      {:health_regeneration_rate_in_ms_changed, String.to_integer(health_regeneration_rate_in_ms)}
    )

    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    IO.inspect(event, label: "Unhandled event event")
    IO.inspect(params, label: "Unhandled event params")
    {:noreply, socket}
  end
end
