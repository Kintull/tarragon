defmodule TarragonWeb.Plugs.User do
  import Plug.Conn

  alias Tarragon.Repo
  alias Tarragon.Accounts.User

  def init(default), do: default

  def call(%Plug.Conn{params: %{user_id: user_id}} = conn, _default) do
    user = Repo.get!(User, user_id)
    assign(conn, :user, user)
  end

  def call(conn, _default) do
    conn
  end
end
