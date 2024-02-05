defmodule Tarragon.Repo.Migrations.CreateChatRoomTable do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :title, :string
      timestamps()
    end
  end
end
