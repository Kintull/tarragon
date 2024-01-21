defmodule Tarragon.Accounts.UserCharacter do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Accounts.User
  alias Tarragon.Battles.Participant
  alias Tarragon.Inventory.ItemContainer

  @type t :: %__MODULE__{}

  @derive {Inspect, only: [:id, :nickname, :user_id, :current_health, :max_health, :active]}

  schema "user_characters" do
    field :nickname, :string
    field :current_health, :integer, default: 10
    field :max_health, :integer, default: 10
    field :active, :boolean, default: false
    field :avatar_url, :string
    field :avatar_background_url, :string

    belongs_to :user, User
    has_one :primary_weapon_slot, ItemContainer, foreign_key: :primary_weapon_slot_id
    has_one :head_gear_slot, ItemContainer, foreign_key: :head_gear_slot_id
    has_one :chest_gear_slot, ItemContainer, foreign_key: :chest_gear_slot_id
    has_one :knee_gear_slot, ItemContainer, foreign_key: :knee_gear_slot_id
    has_one :foot_gear_slot, ItemContainer, foreign_key: :foot_gear_slot_id
    has_one :backpack, ItemContainer, foreign_key: :backpack_id
    has_many :participations, Participant

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:nickname, :max_health, :current_health])
    |> validate_required([:nickname, :max_health, :current_health])
  end

  def truncate_nickname(nickname) when is_binary(nickname) do
    if String.length(nickname) <= 16 do
      nickname
    else
      String.slice(nickname, 0, 10) <> "...#{String.slice(nickname, -3, 3)}"
    end
  end
end
