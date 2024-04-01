defmodule TarragonWeb.PageLive.Ecspanse.CommonComponents do
  use TarragonWeb, :html

  attr :thing, :any, required: true

  def inspect(assigns) do
    ~H"""
    <pre><%= inspect(@thing, pretty: true) %></pre>
    """
  end

  slot :header
  slot :inner_block, required: true

  def details_card(assigns) do
    ~H"""
    <div class="m-2 p-2
               border-black border-2 rounded-lg shadow shadow-neutral-700">
      <details>
        <summary class="font-semibold">
          <%= render_slot(@header) %>
        </summary>
        <%= render_slot(@inner_block) %>
      </details>
    </div>
    """
  end

  slot :header
  slot :inner_block, required: true

  def properties_card(assigns) do
    ~H"""
    <div class="m-2 p-2
               border-black border-2 rounded-lg shadow shadow-neutral-700">
      <div>
        <div class="font-semibold">
          <%= render_slot(@header) %>
        </div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :label, :string, default: nil
  attr :timer, :any
  attr :fg_color, :string, default: "bg-green-300"
  attr :class, :string, default: ""

  def horizontal_timer_bar(assigns) do
    ~H"""
    <.horizontal_value_bar
      label={@label}
      max={@timer.duration}
      current={@timer.time}
      class={@timer.paused && "opacity-10"}
    />
    """
  end

  attr :label, :string, default: nil
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :current, :integer, default: 50
  attr :bg_color, :string, default: "bg-green-600"
  attr :class, :string, default: ""

  def horizontal_value_bar(assigns) do
    ~H"""
    <.properties_card>
      <:header><%= @label %></:header>

      <div class={[
        "flex-1 bg-gray-700 r-rounded-full h-4 transition-all transform ease-in-out duration-300",
        @class
      ]}>
        <div
          class={[@bg_color, "h-full transform transition-all ease-linear duration-300"]}
          style={"width: #{(@current - @min) * 100 / max((@max - @min), 1)}%"}
        >
        </div>
      </div>
    </.properties_card>
    """
  end

  attr :label, :string, required: true
  attr :map, :map, required: true

  def details_card_from_map(assigns) do
    ~H"""
    <.details_card>
      <:header><%= @label %></:header>
      <.properties_table_from_map map={@map} />
    </.details_card>
    """
  end

  attr :label, :string, default: nil
  attr :map, :map, required: true

  def properties_table_from_map(assigns) do
    ~H"""
    <table class="border-collapse">
      <caption :if={@label != nil} class="font-semibold"><%= @label %></caption>
      <tbody>
        <tr :for={key <- Map.keys(@map)}>
          <td class="align-text-top text-right p-1">
            <%= key |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize() %>
          </td>

          <td class="align-text-top p-1"><%= Map.get(@map, key) %></td>
        </tr>
      </tbody>
    </table>
    """
  end
end
