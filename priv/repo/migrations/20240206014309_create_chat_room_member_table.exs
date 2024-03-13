defmodule Tarragon.Repo.Migrations.CreateChatRoomMemberChat do
  use Ecto.Migration

  def change do
    create table(:chat_room_members) do
      add :chat_room_id, references("chat_rooms")

      timestamps()
    end
  end
end
