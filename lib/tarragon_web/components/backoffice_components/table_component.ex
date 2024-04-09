defmodule TarragonWeb.BackofficeComponents.TableComponent do
  @moduledoc """
  Table component for displaying data in a tabular format.
  """

  use Phoenix.LiveComponent

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
