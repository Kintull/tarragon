defmodule Tarragon.Accounts.UserCharacter do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Accounts.User
  alias Tarragon.Battles.Participant
  alias Tarragon.Inventory.ItemContainer

  schema "user_characters" do
    field :nickname, :string
    field :current_health, :integer, default: 10
    field :max_health, :integer, default: 10
    field :active, :boolean, default: false

    belongs_to :user, User
    has_one :hand, ItemContainer, foreign_key: :hand_id
    has_one :backpack, ItemContainer, foreign_key: :backpack_id
    has_one :participation, Participant

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:nickname, :max_health, :current_health])
    |> validate_required([:nickname, :max_health, :current_health])
  end
end
