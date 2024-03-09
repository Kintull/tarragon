defmodule TarragonWeb.PageLive.Ecspanse.EcspanseComponents do
  use TarragonWeb, :html

  attr :timer, :any
  attr :fg_color, :string, default: "bg-green-300"
  attr :class, :string, default: ""

  def horizontal_timer_bar(assigns) do
    ~H"""
    <div>
      <.horizontal_value_bar
        max={@timer.duration}
        current={@timer.time}
        class={@timer.paused && "opacity-10"}
      />
    </div>
    """
  end

  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :current, :integer, default: 50
  attr :bg_color, :string, default: "bg-green-600"
  attr :class, :string, default: ""

  def horizontal_value_bar(assigns) do
    ~H"""
    <div class={[
      "flex-grow bg-gray-700 r-rounded-full h-4 transition-all transform ease-in-out duration-300",
      @class
    ]}>
      <div
        class={[@bg_color, "h-full transform transition-all ease-linear duration-300"]}
        style={"width: #{(@current - @min) * 100 / max((@max - @min), 1)}%"}
      >
      </div>
    </div>
    """
  end
end
