defmodule TarragonWeb.PageLive.Ecspanse.Demo.BoardComponent do
  use TarragonWeb, :live_component

  def mount(socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
    <div
      class="grid gap-0 border-2 border-black w-fit h-fit"
      style="grid-template-columns: repeat(21, 12px);
              grid-template-rows: repeat(21, 12px);"
    >
      <.live_component
        :for={hero <- @heroes}
        module={TarragonWeb.PageLive.Ecspanse.Demo.BoardHeroComponent}
        id={"hero_grid_area_#{hero.entity.id}"}
        hero={hero}
      />
    </div>
    """
  end
end

defmodule TarragonWeb.PageLive.Ecspanse.Demo.BoardHeroComponent do
  use TarragonWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      class="m-0.5"
      style={
        "grid-area: #{11 - @hero.position.y} / #{11 + @hero.position.x} / span 1 / span 1"
      }
    >
      <div
        class="rounded-full h-2 w-2"
        style={"background-color: ##{@hero.hero.color};"}
        title={@hero.hero.name}
      />
    </div>
    """
  end
end
