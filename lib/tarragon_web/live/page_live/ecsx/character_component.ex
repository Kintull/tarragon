defmodule TarragonWeb.CharacterComponent do
  use TarragonWeb, :live_component

  def health(assigns) do
    ~H"""
    <div class="my-2">
      <div class="flex justify-between">
        <h3 class="font-semibold">Health Points</h3>

        <span>
          <%= @health.max_points %>
        </span>
      </div>

      <div class="flex justify-between">
        <span>
          Status
        </span>

        <span>
          <%= @health.status %>
        </span>
      </div>

      <div class=" bg-neutral-700 rounded-full ">
        <div
          class="bg-red-600
          p-0.5 leading-none rounded-r-full h-4
     text-xs font-medium text-neutral-100 text-center
     flex items-center justify-center
     transition-all duration-500 easing-in-out"
          style={"width: #{@health.points / max(@health.max_points, 1) * 100}%"}
        >
          <%= @health.points %>
        </div>
      </div>
    </div>
    """
  end

  def health_regeneration(assigns) do
    ~H"""
    <div class="my-2">
      <h3 class="font-semibold">Health Regeneration</h3>

      <div class="flex justify-between">
        <span>
          Status
        </span>

        <span class={[
          "h-6",
          @health_regeneration.status == :regenerating && "animate-pulse"
        ]}>
          ❤️
        </span>
        <%!-- <span>
          <%= @health_regeneration.status %>
        </span> --%>
      </div>

      <div class="flex justify-between">
        <span>
          Rate in Ms
        </span>

        <span>
          <%= @health_regeneration.rate_in_ms %>
        </span>
      </div>

      <form phx-change="health_regeneration_rate_in_ms_changed">
        <input
          type="range"
          id={"#{@entity}_health_regeneration_rate_in_ms_changed_range"}
          name="health_regeneration_rate_in_ms"
          class="w-full"
          min="100"
          max="10000"
          step="100"
          phx-debounce
          value={@health_regeneration.rate_in_ms}
        /> <input type="hidden" value={@entity} id={"#{@entity}_entity"} name="entity" />
      </form>
    </div>
    """
  end

  def damage_over_time(assigns) do
    ~H"""
    <div class="my-2">
      <div class="flex justify-between">
        <h3 class="font-semibold">Damage over time</h3>

        <span>
          <%= length(@dots) %>
        </span>
      </div>

      <div :for={dot <- @dots}>
        <div class="flex justify-between">
          <span>
            <%= dot.name %>
          </span>

          <span>
            <%= dot.rate_in_ms %>
          </span>
          <span>
            <%= dot.occurrences_remaining %>
          </span>
        </div>
      </div>
    </div>
    """
  end

  def damage_buttons(assigns) do
    ~H"""
    <div class="my-2">
      <h3 class="font-semibold">Damage</h3>

      <div class="flex gap-2">
        <span phx-click="dagger_attack" phx-value-damage="10" phx-value-entity={@entity}>🗡️</span>
        <span
          phx-click="damage_over_time_attack"
          phx-value-occurrences="10"
          phx-value-rate-in-ms="2000"
          phx-value-name="☢️"
          phx-value-entity={@entity}
        >
          ☢️
        </span>
        <span
          phx-click="damage_over_time_attack"
          phx-value-occurrences="5"
          phx-value-rate-in-ms="5000"
          phx-value-name="🤮"
          phx-value-entity={@entity}
        >
          🤮
        </span>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <section class="flex-col gap-2 divide-y-2 divide-neutral-500">
        <div class="text-lg font-semibold   border-black">
          <h2><%= @character.name %></h2>
        </div>
        <.health health={@character.health} />
        <.health_regeneration
          health_regeneration={@character.health_regeneration}
          entity={@character.entity}
        />
        <.damage_over_time dots={@character.damage_over_time} />
        <.damage_buttons entity={@character.entity} />
        <%!-- <.button
        class="mt-4 text-red-300"
        phx-click="apply_damage"
        phx-value-damage="10"
        phx-value-entity={@character.entity}
      >
        10 Damage
      </.button>

      <.button
        class="mt-4 text-red-300"
        phx-click="apply_damage"
        phx-value-damage="50"
        phx-value-entity={@character.entity}
      >
        50 Damage 🔥
      </.button>

      <.button
        class="mt-4 text-green-300"
        phx-click="instant_heal"
        phx-value-points="25"
        phx-value-entity={@character.entity}
      >
        Heal 25
      </.button> --%>
      </section>
    </div>
    """
  end
end
