defmodule TarragonWeb.PageLive.Ecspanse.HealthComponent do
  use TarragonWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between gap-2">
        <h3 class="font-semibold">Health</h3>
         <span><%= @health.current %> / <%= @health.max %></span>
      </div>
      
      <div class="flex-grow bg-gray-700 r-rounded-full h-4 ">
        <div
          class="h-full transition-color duration-100 ease-linear bg-red-500"
          style={"width: #{@health.current * 100 / max(@health.max, 1)}%"}
        >
        </div>
      </div>
    </div>
    """
  end
end
