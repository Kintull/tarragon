defmodule TarragonWeb.PageLive.TutorialScreen do
  use TarragonWeb, :live_view

  def mount(_params, %{}, socket) do
    {:ok, socket, layout: false}
  end
end
