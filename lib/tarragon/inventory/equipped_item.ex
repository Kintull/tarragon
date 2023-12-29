defmodule Tarragon.Inventory.EquippedItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Accounts.User

  @purposes [:head, :feet, :hand, :body, :belt, :transport]

  schema "character_items" do
    field :purpose, Ecto.Enum, values: @purposes
    belongs_to :user, User
    belongs_to :character_item, CharacterItem

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:purpose])
    |> validate_required([:purpose])
  end
end
