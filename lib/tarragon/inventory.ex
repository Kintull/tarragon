defmodule Tarragon.Inventory do
  @moduledoc """
  The Inventory context.

  ItemContainer(backpack_id: user_character.id)
  CharacterItem(item_container_id: item_container.id, game_item_id: game_item.id
  """

  alias Tarragon.Accounts.GearItem
  alias Tarragon.Inventory.GameItem
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.ItemContainer

  @type id :: integer
  @type user_character_id :: integer
  @type item_id :: integer
  @type attrs :: map
  @type item :: GameItem.t()
  @type container :: ItemContainer.t()
  @type added_xp :: integer

  def impl(), do: Application.get_env(:tarragon, :inventory_impl)

  @callback list_items :: [GameItem.t()]
  @callback get_game_item!(id) :: GameItem.t()
  @callback get_character_item!(id) :: CharacterItem
  @callback create_item(attrs) :: {:ok, GameItem.t()} | {:error, Ecto.Changeset}
  @callback create_character_item(attrs) :: {:ok, CharacterItem.t()} | {:error, Ecto.Changeset}
  @callback create_container(attrs) :: {:ok, ItemContainer.t()} | {:error, Ecto.Changeset}
  @callback update_item(item, attrs) :: {:ok, GameItem.t()} | {:error, Ecto.Changeset}
  @callback update_character_item(item, attrs) ::
              {:ok, CharacterItem.t()} | {:error, Ecto.Changeset}
  @callback update_character_item_container(item, container) ::
              {:ok, CharacterItem.t()} | {:error, Ecto.Changeset}
  @callback delete_item(item) :: {:ok, GameItem.t()} | {:error, Ecto.Changeset}
  @callback change_item(item, attrs) :: Ecto.Changeset
  @callback get_item_purposes() :: [atom]

  @callback get_user_character_items(id) :: %{
              backpack: [GearItem.t()],
              head_gear: GearItem.t(),
              chest_gear: GearItem.t(),
              knee_gear: GearItem.t(),
              foot_gear: GearItem.t(),
              primary_weapon: GearItem.t()
            }

  @callback unequip_item(user_character_id, item_id) :: :ok
  @callback equip_item(user_character_id, item_id) :: :ok
  @callback upgrade_item_with_items(item_id, [item_id], added_xp) :: {:ok, any} | {:error, any}
end
