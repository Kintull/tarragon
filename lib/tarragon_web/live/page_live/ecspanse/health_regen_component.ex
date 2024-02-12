defmodule TarragonWeb.PageLive.Ecspanse.HealthRegenComponent do
  use TarragonWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex-grow bg-gray-700 r-rounded-full h-1">
        <div
          class="bg-red-500 h-full transition-color duration-100 ease-linear"
          style={"width: #{((@health_regen_timer.duration - @health_regen_timer.time) * 100) / @health_regen_timer.duration}%"}
        >
        </div>
      </div>
    </div>
    """
  end
end
