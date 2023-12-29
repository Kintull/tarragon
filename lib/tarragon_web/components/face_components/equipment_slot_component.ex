defmodule EquipmentSlotComponent do
  # In Phoenix apps, the line is typically: use MyAppWeb, :live_component
  use Phoenix.LiveComponent
  import TarragonWeb.FaceComponents
  import TarragonWeb.CoreComponents
  alias Phoenix.LiveView.JS

  def handle_event("display_actions", _params, socket) do
    socket =
      socket
      |> assign(:display_actions, true)

    {:noreply, socket}
  end

  def handle_event("hide_actions", _params, socket) do
    socket =
      socket
      |> assign(:display_actions, false)

    {:noreply, socket}
  end
end
