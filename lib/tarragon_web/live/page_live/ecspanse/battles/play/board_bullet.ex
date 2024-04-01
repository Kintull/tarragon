defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardBullet do
  alias TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardComponent
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <g transform={"translate(#{BoardComponent.x_to_board(@bullet.position.x)}, #{BoardComponent.y_to_board(@bullet.position.y)})"}>
      <image
        x={-1 * @cell_width / 4}
        y={-1 * @cell_height / 4}
        width={@cell_width / 2}
        height={@cell_height / 2}
        href="/images/svg/bullet-free-1-svgrepo-com.svg"
      />
    </g>
    """
  end
end
