defmodule Tarragon.Repo.Migrations.CreateGameItems do
  use Ecto.Migration

  def change do
    create table(:game_items) do
      add :title, :string
      add :description, :string
      add :initial_condition, :integer
      add :image, :string
      add :purpose, :string
      add :base_damage_bonus, :integer
      add :base_defence_bonus, :integer
      add :base_health_bonus, :integer
      add :base_range_bonus, :integer

      timestamps()
    end
  end
end
