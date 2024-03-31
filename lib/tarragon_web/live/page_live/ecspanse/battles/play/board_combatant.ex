defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardCombatant do
  @moduledoc false
  alias TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardComponent
  use TarragonWeb, :live_component

  def render(assigns) do
    health_radius = assigns.cell_width * 0.5
    health_circle_circumference = 2 * :math.pi() * health_radius

    health_percent = assigns.combatant.health.current / assigns.combatant.health.max
    healthy_circumference_length = health_percent * health_circle_circumference

    health_dasharray =
      "#{healthy_circumference_length}, #{health_circle_circumference - healthy_circumference_length}"

    # IO.inspect(health_percent, label: "#{assigns.combatant.brand.name}'s health percent")
    # IO.inspect(health_dasharray, label: "health_dasharray")

    assigns =
      assigns
      |> assign(health_dasharray: health_dasharray)
      |> assign(health_radius: health_radius)

    ~H"""
    <g
      id={"combatant_#{@combatant.entity.id}"}
      phx-click="select_combatant"
      phx-value-combatant_entity_id={@combatant.entity.id}
      transform={"translate(#{BoardComponent.x_to_board(@combatant.position.x)}, #{BoardComponent.y_to_board(@combatant.position.y)})"}
    >
      <circle
        :if={@combatant.is_obscured and @combatant.health.current > 0}
        id="obscured_indicator"
        r={@cell_width}
        stroke="none"
        stroke-width="3"
        fill="#FFF"
        fill-opacity="0.5"
      />
      <image
        x={-1 * @cell_width / 2}
        y={-1 * @cell_height / 2}
        width={@cell_width}
        height={@cell_height}
        href="/images/svg/soldier-svgrepo-com.svg"
      />
      <image
        :if={@combatant.is_dodging and @combatant.health.current > 0}
        x="0"
        y="0"
        width={@cell_width / 3}
        height={@cell_height / 3}
        href="/images/svg/player-dodge-svgrepo-com.svg"
      />
      <circle
        id={"health_indicator_combatant_#{@combatant.entity.id}"}
        r={@health_radius}
        stroke="#0F0"
        stroke-width="3"
        stroke-dasharray={@health_dasharray}
        fill="none"
      />
      <circle
        :if={@combatant.health.current > 0}
        id={"range_indicator_combatant_#{@combatant.entity.id}"}
        r={@cell_width * @combatant.main_weapon.range}
        stroke="#000"
        stroke-width="1"
        stroke-dasharray="10, 10"
        fill="none"
      />
    </g>
    """
  end
end

# stroke-dasharray={"#{ceil(1000 * (@combatant.health.current - Enum.random(0..20)) / @combatant.health.max) / 10}%"}
