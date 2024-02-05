defmodule Tarragon.Inventory.ItemContainer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Inventory.CharacterItem

  @type t :: %__MODULE__{}

  schema "item_containers" do
    field :capacity, :integer, default: 1
    belongs_to :head_gear_slot, UserCharacter, foreign_key: :head_gear_slot_id
    belongs_to :chest_gear_slot, UserCharacter, foreign_key: :chest_gear_slot_id
    belongs_to :knee_gear_slot, UserCharacter, foreign_key: :knee_gear_slot_id
    belongs_to :foot_gear_slot, UserCharacter, foreign_key: :foot_gear_slot_id
    belongs_to :primary_weapon_slot, UserCharacter, foreign_key: :primary_weapon_slot_id
    belongs_to :backpack, UserCharacter, foreign_key: :backpack_id
    belongs_to :item_container, ItemContainer, foreign_key: :parent_container_id
    has_many :items, CharacterItem
    has_one :item, CharacterItem

    timestamps()
  end

  @doc false
  def changeset(item_container, attrs) do
    item_container
    |> cast(attrs, [
      :capacity,
      :head_gear_slot_id,
      :chest_gear_slot_id,
      :knee_gear_slot_id,
      :foot_gear_slot_id,
      :primary_weapon_slot_id,
      :backpack_id
    ])
    |> validate_required([:capacity])
  end
end
