defmodule Tarragon.Repo do
  use Ecto.Repo,
    otp_app: :tarragon,
    adapter: Ecto.Adapters.Postgres
end
