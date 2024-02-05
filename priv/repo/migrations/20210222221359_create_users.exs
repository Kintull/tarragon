defmodule Tarragon.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :is_bot, :boolean, default: false
      add :name, :string
      add :email, :string
      add :password_hash, :string

      timestamps()
    end
  end
end
