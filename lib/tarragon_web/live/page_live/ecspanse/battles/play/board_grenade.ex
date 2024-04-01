defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardGrenade do
  alias TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardComponent
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <g
      id={"grenade_#{@grenade.entity.id}"}
      transform={"translate(#{BoardComponent.x_to_board(@grenade.position.x)}, #{BoardComponent.y_to_board(@grenade.position.y)})"}
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
