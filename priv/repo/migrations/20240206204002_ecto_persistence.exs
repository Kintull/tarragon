defmodule Tarragon.Repo.Migrations.EctoPersistence do
  use Ecto.Migration

  def change do
    create table("ecsx_components") do
      add :module, :string
      add :data, :string

      timestamps()
    end
  end
end
