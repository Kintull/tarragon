defmodule TarragonWeb.PageLive.Ecspanse.Demo.HeroComponent do
  use TarragonWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      id={"hero_entity_id_#{@hero.entity.id}"}
      class="
        bg-neutral-100
        m-2 p-2
        rounded-xl
        shadow-lg shadow-neutral-700
        grid grid-cols-1 gap-2
        divide-y divide-neutral-300"
    >
      <div class="flex justify-between gap-2">
        <h2 class="font-bold text-lg">
          🤺 <%= @hero.hero.name %>
        </h2>
         <.hero_dot hero={@hero.hero} />
      </div>
      
      <.live_component
        module={TarragonWeb.PageLive.Ecspanse.Demo.HealthComponent}
        id={"health_#{@hero.entity.id}"}
        health={@hero.health}
      />
      <%!-- <.live_component
        module={TarragonWeb.PageLive.Ecspanse.HealthRegenComponent}
        id={"health_regen_#{@hero.entity.id}"}
        health_regen_timer={@hero.health_regen_timer}
      /> --%>
      <div>
        <div class="flex justify-between gap-2">
          <h3 class="font-semibold">Energy</h3>
           <span><%= @hero.energy.current %> / <%= @hero.energy.max %></span>
        </div>
         <.value_bar current={@hero.energy.current} max={@hero.energy.max} bg_color="bg-green-500" />
        <%!-- <div class={["flex gap-2 items-center"]}>
          <div>Regen:</div>

          <.countdown_timer_bar
            timer={@hero.energy_regen_timer}
            fg_color="bg-green-500"
            class={@hero.energy_regen_timer.paused && "opacity-0"}
          />
          <div><%= @hero.energy_regen_timer.duration %> MS</div>
        </div> --%>
      </div>
       <.inventory inventory={@hero.inventory} /> <.currencies currencies={@hero.currencies} />
      <div>
        <div class="flex justify-between gap-2">
          <h3 class="font-semibold">Position</h3>
           <span><%= @hero.position.x %>, <%= @hero.position.y %></span>
        </div>
        
        <div>
          <.movement_button
            title="up"
            icon="hero-arrow-up-solid"
            direction="up"
            key="w"
            entity_id={@hero.entity.id}
          />
          <.movement_button
            title="left"
            icon="hero-arrow-left-solid"
            direction="left"
            key="a"
            entity_id={@hero.entity.id}
          />
          <.movement_button
            title="down"
            icon="hero-arrow-down-solid"
            direction="down"
            key="s"
            entity_id={@hero.entity.id}
          />
          <.movement_button
            title="right"
            icon="hero-arrow-right-solid"
            direction="right"
            key="d"
            entity_id={@hero.entity.id}
          />
        </div>
      </div>
    </div>
    """
  end

  def hero_dot(assigns) do
    ~H"""
    <div class="rounded-full h-4 w-4" style={"background-color: ##{@hero.color};"} title={@hero.name} />
    """
  end

  attr :title, :string
  attr :icon, :string
  attr :direction, :string
  attr :key, :string
  attr :entity_id, :string

  def movement_button(assigns) do
    ~H"""
    <button
      title={@title}
      class="w-7 h-7
          align-middle
          rounded-md
          border-1 border-neutral-400
          shadow-sm shadow-neutral-600
          hover:border-2 active:bg-neutral-100 "
      phx-click="move"
      phx-value-direction={@direction}
      phx-value-entity_id={@entity_id}
    >
      <%!-- phx-window-keydown="move"
      phx-key={@key} --%>
      <TarragonWeb.CoreComponents.icon name={@icon} class="h-4 w-4" />
    </button>
    """
  end

  attr :timer, :any
  attr :fg_color, :string, default: "bg-green-300"
  attr :class, :string, default: ""

  def countdown_timer_bar(assigns) do
    ~H"""
    <div class={[@class, @fg_color, "  r-rounded-full h-4 w-2"]}>
      <div
        class={["bg-gray-700 h-full transition-color duration-100 ease-linear"]}
        style={"height: #{(@timer.time * 100) / @timer.duration}%"}
      >
      </div>
    </div>
    """
  end

  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :current, :integer, default: 50
  attr :bg_color, :string, default: "bg-green-600"

  def value_bar(assigns) do
    ~H"""
    <div class="flex-grow bg-gray-700 r-rounded-full h-4 ">
      <div
        class={[@bg_color, "h-full transition-color duration-100 ease-linear"]}
        style={"width: #{(@current - @min) * 100 / max((@max - @min), 1)}%"}
      >
      </div>
    </div>
    """
  end

  attr :currencies, :list, default: []

  def currencies(assigns) do
    ~H"""
    <div>
      <h3>Money</h3>
      
      <div class="flex flex-wrap  gap-2">
        <div :for={currency <- @currencies}>
          <div><%= currency.icon %> <%= currency.name %>: <%= currency.amount %></div>
        </div>
      </div>
    </div>
    """
  end

  attr :inventory, :list, default: []

  def inventory(assigns) do
    ~H"""
    <div>
      <h3>Inventory</h3>
      
      <div class="flex flex-wrap  gap-2">
        <div :for={item <- @inventory}>
          <div><%= item.item.icon %> <%= item.item.name %></div>
        </div>
      </div>
    </div>
    """
  end
end
