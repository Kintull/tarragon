defmodule Tarragon.Repo.Migrations.CreateItemContainers do
  use Ecto.Migration

  def change do
    create table(:item_containers) do
      add :capacity, :integer

      add :hand_id, references(:user_characters, on_delete: :delete_all)
      add :backpack_id, references(:user_characters, on_delete: :delete_all)

      timestamps()
    end
  end
end
