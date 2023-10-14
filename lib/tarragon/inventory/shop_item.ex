defmodule Tarragon.Inventory.ShopItem do
  use Ecto.Schema
  import Ecto.Changeset

  @purposes [:head, :feet, :hand, :body, :belt, :transport]

  schema "shop_items" do
    field :description, :string
    field :image, :string
    field :max_condition, :integer
    field :title, :string
    field :purpose, Ecto.Enum, values: @purposes
    field :base_damage, :integer

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :description, :max_condition, :purpose, :image])
    |> validate_required([:title, :description, :max_condition, :purpose])
  end

  def get_purposes do
    @purposes
  end
end
