defmodule Tarragon.Repo.Migrations.AddItemQuantitiesAndEquippedItem do
  use Ecto.Migration

  def change do
    create table("character_items") do
      add :current_condition, :integer
      add :shop_item_id, references(:shop_items, on_delete: :delete_all)
      add :item_container_id, references(:item_containers, on_delete: :delete_all)
      timestamps()
    end

    create index("character_items", [:item_container_id])
  end
end
