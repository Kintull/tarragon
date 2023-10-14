defmodule TarragonWeb.PageController do
  use TarragonWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def game_screen(conn, _params) do
    render(conn, :game_screen, layout: false, overflow_hidden: true, current_location_id: 320)
  end
end
