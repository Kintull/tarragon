defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.TeamComponent do
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
          <div class="flex flex-wrap items-start gap-2">
            <.brand_dot brand={@team.brand} />
            <h2 class="font-bold text-xl">
              <%= @team.brand.name %>
            </h2>
            <%= @team.brand.icon %>
          </div>
        </:header>

        <FlexGridLayouts.auto_grid>
          <.live_component
            :for={combatant <- @team.combatants}
            module={TarragonWeb.PageLive.Ecspanse.Battles.Dump.CombatantComponent}
            id={combatant.entity.id}
            combatant={combatant}
          />
        </FlexGridLayouts.auto_grid>
      </CommonComponents.properties_card>
    </div>
    """
  end

  def brand_dot(assigns) do
    ~H"""
    <div
      class="rounded-full h-4 w-4"
      style={"background-color: #{@brand.color};"}
      title={@brand.name}
    />
    """
  end
end
