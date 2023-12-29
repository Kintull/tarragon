defmodule Tarragon.Repo.Migrations.AddCharacterItems do
  use Ecto.Migration

  def change do
    create table("character_items") do
      add :current_condition, :integer
      add :game_item_id, references(:game_items, on_delete: :delete_all)
      add :item_container_id, references(:item_containers, on_delete: :delete_all)
      timestamps()
    end

    create index("character_items", [:item_container_id])
  end
end
