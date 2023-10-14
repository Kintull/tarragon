defmodule Tarragon.Inventory.ItemContainer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Inventory.CharacterItem

  schema "item_containers" do
    field :capacity, :integer, default: 1
    belongs_to :hand, UserCharacter
    belongs_to :backpack, UserCharacter
    has_many :items, CharacterItem

    timestamps()
  end

  @doc false
  def changeset(item_container, attrs) do
    item_container
    |> cast(attrs, [:capacity])
    |> validate_required([:capacity])
  end
end
