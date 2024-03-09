defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardCombatant do
  use TarragonWeb, :live_component

  def render(assigns) do
    health_circle_circumference = 2 * :math.pi() * min(assigns.cell_width, assigns.cell_height)
    health_percent = assigns.combatant.health.current / assigns.combatant.health.max
    healthy_circumference_length = health_percent * health_circle_circumference

    assigns =
      assign(
        assigns,
        healthy_dasharray:
          "#{healthy_circumference_length}, #{health_circle_circumference - healthy_circumference_length}"
      )

    ~H"""
    <g
      id={"combatant_#{@combatant.entity.id}"}
      phx-click="select_combatant"
      phx-value-combatant_entity_id={@combatant.entity.id}
      transform={"translate(#{@cell_width * @combatant.position.x + 0.5 * @cell_width}, #{(@board_row + 0.5) * @cell_height})"}
    >
      <circle
        :if={@combatant.is_obscured}
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
        :if={@combatant.is_dodging}
        x="0"
        y="0"
        width={@cell_width / 3}
        height={@cell_height / 3}
        href="/images/svg/player-dodge-svgrepo-com.svg"
      />
      <circle
        r={@cell_width}
        stroke="#0F0"
        stroke-width="3"
        stroke-dasharray={@healthy_dasharray}
        fill="none"
      />
    </g>
    """
  end
end

# stroke-dasharray={"#{ceil(1000 * (@combatant.health.current - Enum.random(0..20)) / @combatant.health.max) / 10}%"}
