defmodule Tarragon.Repo.Migrations.AddActiveToCharacter do
  use Ecto.Migration

  def change do
    alter table(:user_characters) do
      add :active, :boolean, default: false
    end
  end
end
