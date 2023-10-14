defmodule Tarragon.Battles.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Battles.Participant

  schema "battle_rooms" do
    field :ended_at, :utc_datetime
    field :started_at, :utc_datetime
    field :step, :integer, default: 0
    field :turn_duration_sec, :integer, default: 30
    field :awaiting_start, :boolean, default: true
    field :max_participants, :integer, default: 2

    has_many :participants, Participant, foreign_key: :battle_room_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:turn_duration_sec, :started_at, :ended_at, :step, :awaiting_start, :max_participants])
  end

  def max_participants do
    2
  end
end
