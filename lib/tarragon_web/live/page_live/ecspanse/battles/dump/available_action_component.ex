defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.AvailableActionComponent do
  alias TarragonWeb.PageLive.Ecspanse.CommonComponents
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <CommonComponents.properties_card>
        <:header>
          <%= @action_state.action.name %>
        </:header>
        <CommonComponents.details_card_from_map label="Action" map={@action_state.action} />
        <CommonComponents.details_card_from_map
          label="Available Action"
          map={@action_state.action_state}
        /> <CommonComponents.details_card_from_map label="Entity" map={@action_state.entity} />
      </CommonComponents.properties_card>
    </div>
    """
  end
end
