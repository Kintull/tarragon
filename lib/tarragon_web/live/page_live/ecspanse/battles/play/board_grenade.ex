defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardGrenade do
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <g
      id={"grenade_#{@grenade.entity.id}"}
      transform={"translate(#{@cell_width * @grenade.position.x + 0.5 * @cell_width}, #{(@board_row + 0.5) * @cell_height})"}
    >
      <image
        x={-1 * @cell_width / 2}
        y={-1 * @cell_height / 2}
        width={@cell_width}
        height={@cell_height}
        href="/images/svg/hand-grenade-svgrepo-com.svg"
      />
    </g>
    """
  end
end
