defmodule Tarragon.Battles.BattleLogEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "battle_log_entries" do
    field :message, :string
    field :turn, :integer

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:message, :turn, :battle_room_id])
    |> validate_required([:message, :turn, :battle_room_id])
  end
end
