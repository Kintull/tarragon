defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardComponent do
  use TarragonWeb, :live_component

  @board_width 640
  @board_height 360
  @cell_count 20
  @cell_width @board_width / 20
  @cell_height @board_height / 10

  defp board_dimensions() do
    [
      width: @board_width,
      height: @board_height,
      half_width: @board_width / 2.0,
      half_height: @board_height / 2.0,
      cell_count: @cell_count,
      cell_width: @cell_width,
      cell_height: @cell_height
    ]
  end

  def x_to_board(x), do: @cell_width * x + 1.5 * @cell_width
  def y_to_board(y), do: @cell_height * 2 * y + 1.5 * @cell_height

  def render(assigns) do
    assigns = assign(assigns, board_dimensions())

    ~H"""
    <div>
      <div>
        Turn: <%= @battle.battle.turn %> of <%= @battle.battle.max_turns %> Phase: <%= @battle.state_machine.current_state %>
        <div class={["inline-block", @battle.state_machine.paused && "opacity-25"]}>
          <.countdown_timer
            id={"board_state_timer_#{@battle.entity.id}"}
            state_machine={@battle.state_machine}
          />
        </div>
      </div>

      <svg width={@width} height={@height}>
        <.board_background battle={@battle} {board_dimensions()} />
        <%= for team <- @battle.teams do %>
          <.live_component
            :for={combatant <- team.combatants}
            module={TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardCombatant}
            id={"board_combatant_#{combatant.entity.id}"}
            combatant={combatant}
            is_player={false}
            {board_dimensions()}
          />
        <% end %>

        <.live_component
          :for={grenade <- @battle.grenades}
          module={TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardGrenade}
          id={"board_grenade_#{grenade.entity.id}"}
          grenade={grenade}
          {board_dimensions()}
        />

        <.live_component
          :for={bullet <- @battle.bullets}
          module={TarragonWeb.PageLive.Ecspanse.Battles.Play.BoardBullet}
          id={"board_bullet_#{bullet.entity.id}"}
          bullet={bullet}
          {board_dimensions()}
        />
      </svg>
    </div>
    """
  end

  attr :state_machine, :any, required: true
  attr :width, :integer, default: 100
  attr :height, :integer, default: 10
  attr :id, :string, required: true

  def countdown_timer(assigns) do
    ~H"""
    <svg id={@id} width={@width} height={@height}>
      <rect width={@width} height={@height} stroke="black" />
      <rect
        id={"#{@id}_bar"}
        x="1"
        y="1"
        width={ceil((@width - 2) * @state_machine.time / @state_machine.duration * 10) / 10}
        height={@height - 2}
        fill="#00F"
      />
    </svg>
    """
  end

  def board_background(assigns) do
    ~H"""
    <defs>
      <linearGradient id={"board_background_#{@battle.entity.id}"} x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0" stop-color="red" />
        <stop offset="33%" stop-color="white" />
        <stop offset="67%" stop-color="white" />
        <stop offset="100%" stop-color="blue" />
      </linearGradient>
    </defs>

    <rect width={@width} height={@height} fill={"url(#board_background_#{@battle.entity.id})"} />

    <g id={"board_grid_lines_#{@battle.entity.id}"}>
      <line
        :for={x <- 0..@cell_count}
        x1={x * @cell_width}
        y1="0"
        x2={x * @cell_width}
        y2={@height}
        stroke="#000"
        stroke-width="1"
        stroke-opacity="0.3"
        stroke-dasharray="2, 2"
      />
      <line
        x1={@half_width}
        y1="0"
        x2={@half_width}
        y2={@height}
        stroke="#000"
        stroke-width="4"
        stroke-opacity="0.3"
        stroke-dasharray="2, 2"
      />
    </g>
    """
  end
end
