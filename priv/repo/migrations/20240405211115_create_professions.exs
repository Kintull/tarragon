defmodule Tarragon.Repo.Migrations.CreateProfessions do
  use Ecto.Migration

  def change do
    create table(:professions) do
      add :name, :string
      add :description, :string
      add :health_points, :integer
      add :speed, :integer

      timestamps()
    end
  end
end
