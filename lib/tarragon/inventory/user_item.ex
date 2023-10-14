defmodule Tarragon.Inventory.CharacterItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tarragon.Inventory.ShopItem
  alias Tarragon.Inventory.ItemContainer

  @purposes [:head, :feet, :hand, :body, :belt, :transport]

  schema "character_items" do
    field :current_condition, :integer

    belongs_to :shop_item, ShopItem
    belongs_to :item_container, ItemContainer, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:current_condition])
    |> validate_required([:current_condition])
  end

  def get_purposes do
    @purposes
  end
end
