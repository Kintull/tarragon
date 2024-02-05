defmodule Tarragon.Repo.Migrations.CreateBattleRooms do
  use Ecto.Migration

  def change do
    create table(:battle_rooms) do
      add :turn_duration_sec, :integer
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :current_turn, :integer
      add :awaiting_start, :boolean, default: true
      add :max_participants, :integer
      add :winner_team, :string
      add :logs, :jsonb, default: "[]"

      timestamps()
    end
  end
end
