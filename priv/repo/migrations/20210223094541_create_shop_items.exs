defmodule Tarragon.Repo.Migrations.CreateShopItems do
  use Ecto.Migration

  def change do
    create table(:shop_items) do
      add :title, :string
      add :description, :string
      add :max_condition, :integer
      add :image, :string
      add :purpose, :string
      add :base_damage, :integer

      timestamps()
    end

  end
end
