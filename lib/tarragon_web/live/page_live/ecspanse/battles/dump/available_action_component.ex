defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.AvailableActionComponent do
  alias TarragonWeb.PageLive.Ecspanse.CommonComponents
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <CommonComponents.properties_card>
        <:header>
          <%= @available_action.action.name %>
        </:header>
        <CommonComponents.details_card_from_map label="Action" map={@available_action.action} />
        <CommonComponents.details_card_from_map
          label="Available Action"
          map={@available_action.available_action}
        /> <CommonComponents.details_card_from_map label="Entity" map={@available_action.entity} />
      </CommonComponents.properties_card>
    </div>
    """
  end
end
