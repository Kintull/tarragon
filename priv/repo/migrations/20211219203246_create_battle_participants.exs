defmodule Tarragon.Repo.Migrations.CreateBattleParticipants do
  use Ecto.Migration

  def change do
    create table(:battle_room_participants) do
      add :team_a, :boolean, default: false
      add :team_b, :boolean, default: false
      add :is_bot, :boolean, default: false
      add :eliminated, :boolean, default: false
      add :closure_shown, :boolean, default: false

      add :battle_room_id, references(:battle_rooms)
      add :user_character_id, references(:user_characters)

      timestamps()
    end
  end
end
