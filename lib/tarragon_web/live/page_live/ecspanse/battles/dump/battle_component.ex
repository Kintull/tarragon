defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.BattleComponent do
  alias TarragonWeb.FlexGridLayouts
  alias TarragonWeb.PageLive.Ecspanse.CommonComponents
  use TarragonWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <CommonComponents.properties_card>
        <:header>
          <div class="flex justify-between">
            <h2 class="font-bold text-2xl">Battle: <%= @battle.battle.name %></h2>
            <.link patch={~p"/ecspanse/battles/play?battle_id=#{@battle.entity.id}"}>
              <.button>▶️ Play</.button>
            </.link>
          </div>
        </:header>

        <FlexGridLayouts.content_with_right_sidebar>
          <:sidebar>
            <FlexGridLayouts.auto_grid>
              <CommonComponents.details_card_from_map label="Entity" map={@battle.entity} />
              <CommonComponents.details_card_from_map label="Battle" map={@battle.battle} />
              <CommonComponents.horizontal_timer_bar
                label={"#{@battle.state_machine.current_state} Countdown"}
                state_machine={@battle.state_machine}
              />
            </FlexGridLayouts.auto_grid>
          </:sidebar>

          <.live_component
            :for={team <- @battle.teams}
            module={TarragonWeb.PageLive.Ecspanse.Battles.Dump.TeamComponent}
            id={team.entity.id}
            team={team}
          />
        </FlexGridLayouts.content_with_right_sidebar>
      </CommonComponents.properties_card>
    </div>
    """
  end
end
