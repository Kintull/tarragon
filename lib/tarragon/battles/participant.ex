defmodule Tarragon.Battles.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Battles.Room
  alias Tarragon.Accounts.UserCharacter

  @type t :: %__MODULE__{}

  schema "battle_room_participants" do
    field :team_a, :boolean, default: false
    field :team_b, :boolean, default: false
    field :is_bot, :boolean, default: false
    field :eliminated, :boolean, default: false
    field :closure_shown, :boolean, default: false

    belongs_to(:user_character, UserCharacter)
    belongs_to(:battle_room, Room)

    timestamps()
  end

  @doc false
  def changeset(fighters, attrs) do
    fighters
    |> cast(attrs, [
      :team_a,
      :team_b,
      :is_bot,
      :eliminated,
      :user_character_id,
      :battle_room_id,
      :closure_shown
    ])
    |> validate_required([:user_character_id])
  end
end
