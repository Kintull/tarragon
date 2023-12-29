defmodule Tarragon.Inventory.CharacterItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tarragon.Inventory.GameItem
  alias Tarragon.Inventory.ItemContainer

  @purposes [:head, :feet, :hand, :body, :belt, :transport]

  @type t :: %__MODULE__{}

  schema "character_items" do
    field :current_condition, :integer, default: 0

    belongs_to :game_item, GameItem
    belongs_to :item_container, ItemContainer, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:current_condition, :game_item_id, :item_container_id])
    |> validate_required([:current_condition])
  end

  def get_purposes do
    @purposes
  end
end
