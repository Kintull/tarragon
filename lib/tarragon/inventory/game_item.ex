defmodule Tarragon.Inventory.GameItem do
  use Ecto.Schema
  import Ecto.Changeset

  @purposes [:primary_weapon, :head_gear, :chest_gear, :knee_gear, :foot_gear]

  @type t :: %__MODULE__{}

  schema "game_items" do
    field :description, :string
    field :image, :string
    field :base_item_condition, :integer
    field :title, :string
    field :purpose, Ecto.Enum, values: @purposes
    field :base_damage_bonus, :integer
    field :base_defence_bonus, :integer
    field :base_health_bonus, :integer
    field :base_range_bonus, :integer
    has_one :character_item, Tarragon.Inventory.CharacterItem

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :title,
      :description,
      :base_item_condition,
      :purpose,
      :image,
      :base_damage_bonus,
      :base_defence_bonus,
      :base_health_bonus,
      :base_range_bonus
    ])
    |> validate_required([:title, :description, :base_item_condition, :purpose])
  end

  def get_purposes do
    @purposes
  end
end
