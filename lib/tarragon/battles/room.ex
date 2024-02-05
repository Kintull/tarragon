defmodule Tarragon.Battles.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Battles.Participant

  defmodule BattleLogEntry do
    use Ecto.Schema
    @type t :: %__MODULE__{}
    embedded_schema do
      # ===> this is battle log entry <===
      field :event, Ecto.Enum, values: [:miss, :hit, :last_hit, :step_closer, :turn_skip]
      field :turn, :integer
      field :attacker_id, :integer
      field :attacker_attack, :string
      field :attacker_move, :string
      field :target_id, :integer
      field :target_move, :string
      field :damage, :integer
    end

    def changeset(module, attrs) do
      attrs =
        if is_struct(attrs) do
          Map.from_struct(attrs)
        else
          attrs
        end

      changeset =
        module
        |> cast(attrs, [
          :event,
          :turn,
          :attacker_id,
          :target_id,
          :attacker_move,
          :attacker_attack,
          :target_move,
          :damage
        ])
        |> validate_required([:event, :turn])

      cond do
        attrs.event in [:hit, :last_hit] ->
          changeset
          |> validate_required([:attacker_id, :target_id, :attacker_attack, :target_move, :damage])

        attrs.event == :miss ->
          changeset
          |> validate_required([:attacker_id, :target_id, :attacker_attack, :target_move])

        attrs.event == :step_closer ->
          changeset
          |> validate_required([:attacker_move])

        true ->
          changeset
      end
    end
  end

  @type t :: %__MODULE__{}
  schema "battle_rooms" do
    field :ended_at, :utc_datetime
    field :started_at, :utc_datetime
    field :current_turn, :integer, default: 0
    field :turn_duration_sec, :integer, default: 30
    field :awaiting_start, :boolean, default: true
    field :max_participants, :integer, default: 2
    field :winner_team, Ecto.Enum, values: [:team_a, :team_b, :draw]
    embeds_many :logs, __MODULE__.BattleLogEntry

    has_many :participants, Participant, foreign_key: :battle_room_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [
      :ended_at,
      :started_at,
      :current_turn,
      :turn_duration_sec,
      :awaiting_start,
      :max_participants,
      :winner_team
    ])
    |> cast_embed(:logs, with: &BattleLogEntry.changeset/2)
  end

  def max_participants do
    2
  end
end
