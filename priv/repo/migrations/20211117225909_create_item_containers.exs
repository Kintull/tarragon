defmodule Tarragon.Repo.Migrations.CreateItemContainers do
  use Ecto.Migration

  def change do
    create table(:item_containers) do
      add :capacity, :integer

      add :head_gear_slot_id, references(:user_characters, on_delete: :delete_all)
      add :chest_gear_slot_id, references(:user_characters, on_delete: :delete_all)
      add :knee_gear_slot_id, references(:user_characters, on_delete: :delete_all)
      add :foot_gear_slot_id, references(:user_characters, on_delete: :delete_all)
      add :primary_weapon_slot_id, references(:user_characters, on_delete: :delete_all)
      add :backpack_id, references(:user_characters, on_delete: :delete_all)

      timestamps()
    end
  end
end
