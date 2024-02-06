defmodule Tarragon.Repo.Migrations.CreateUserCharacterMessageTable do
  use Ecto.Migration

  def change do
    create table(:user_character_messages) do
      add :message, :string
      add :user_character_id, references(:user_characters)
      add :chat_rooms_id, references(:chat_rooms)
      timestamps()
    end
  end
end
