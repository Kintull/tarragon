defmodule TarragonWeb.AuthenticationController do
  use TarragonWeb, :controller

  def index(conn, %{"user_id" => user_id}) do
    conn
    |> put_session(:user_id, String.to_integer(user_id))
    |> redirect(to: ~p"/game_screen")
  end
end
