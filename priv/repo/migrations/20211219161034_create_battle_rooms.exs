defmodule Tarragon.Repo.Migrations.CreateBattleRooms do
  use Ecto.Migration

  def change do
    create table(:battle_rooms) do
      add :turn_duration_sec, :integer
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :step, :integer
      add :awaiting_start, :boolean, default: true
      add :max_participants, :integer

      timestamps()
    end
  end
end
