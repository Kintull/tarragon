defmodule Tarragon.Inventory do
  @moduledoc """
  The Inventory context.
  """

  alias Tarragon.Inventory.GameItem
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.ItemContainer

  @type id :: integer
  @type attrs :: map
  @type item :: GameItem.t()
  @type container :: ItemContainer.t()

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
end
