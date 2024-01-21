defmodule Tarragon.Inventory.Impl do
  @moduledoc """
  The Inventory context.
  """

  @behaviour Tarragon.Inventory

  import Ecto.Query, warn: false
  alias Tarragon.Repo

  alias Tarragon.Accounts.GearItem
  alias Tarragon.Inventory.GameItem
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.ItemContainer

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%GameItem{}, ...]

  """
  @impl true
  def list_items do
    Repo.all(GameItem)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the GameItem does not exist.

  ## Examples

      iex> get_game_item!(123)
      %GameItem{}

      iex> get_game_item!(456)
      ** (Ecto.NoResultsError)

  """
  @impl true
  def get_game_item!(id), do: Repo.get!(GameItem, id)

  @impl true
  def get_character_item!(id), do: Repo.get!(CharacterItem, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %GameItem{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def create_item(attrs \\ %{}, after_save \\ fn -> :ok end) do
    %GameItem{}
    |> GameItem.changeset(attrs)
    |> after_save(after_save)
    |> Repo.insert()
  end

  @doc """
  Creates a user item.
  """
  @impl true
  def create_character_item(attrs \\ %{}, after_save \\ fn -> :ok end) do
    %CharacterItem{}
    |> CharacterItem.changeset(attrs)
    |> after_save(after_save)
    |> Repo.insert()
  end

  @doc """
  Creates a user item.
  """
  @impl true
  def create_container(attrs \\ %{}, after_save \\ fn -> :ok end) do
    %ItemContainer{}
    |> ItemContainer.changeset(attrs)
    |> after_save(after_save)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %GameItem{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def update_item(%GameItem{} = item, attrs, after_save_func \\ fn -> :ok end) do
    item
    |> GameItem.changeset(attrs)
    |> after_save(after_save_func)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %GameItem{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  @impl true
  def delete_item(%GameItem{} = item) do
    Repo.delete(item)
  end

  @impl true
  def get_item_purposes() do
    GameItem.get_purposes()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %GameItem{}}

  """
  @impl true
  def change_item(%GameItem{} = item, attrs \\ %{}) do
    GameItem.changeset(item, attrs)
  end

  @impl true
  def update_character_item(%CharacterItem{} = item, attrs, after_save_func \\ fn -> :ok end) do
    item
    |> CharacterItem.changeset(attrs)
    |> after_save(after_save_func)
    |> Repo.update()
  end

  @impl true
  def update_character_item_container(%CharacterItem{} = character_item, container) do
    character_item
    |> Repo.preload([:item_container])
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:item_container, container)
    |> Repo.update()
  end

  defp after_save(%{valid?: true} = changeset, func) do
    func.()
    changeset
  end

  defp after_save(error, _func) do
    error
  end

  @impl true
  def get_user_character_items(user_character_id) do
    user_character = Tarragon.Accounts.impl().get_user_character!(user_character_id)

    backpack = user_character.backpack.items

    backpack =
      for item <- backpack do
        GearItem.build(item)
      end

    head_gear_item = user_character.head_gear_slot && user_character.head_gear_slot.item
    chest_gear_item = user_character.chest_gear_slot && user_character.chest_gear_slot.item
    knee_gear_item = user_character.knee_gear_slot && user_character.knee_gear_slot.item
    foot_gear_item = user_character.foot_gear_slot && user_character.foot_gear_slot.item

    primary_weapon_item =
      user_character.primary_weapon_slot && user_character.primary_weapon_slot.item

    %{
      backpack: backpack,
      head_gear: GearItem.build(head_gear_item),
      chest_gear: GearItem.build(chest_gear_item),
      knee_gear: GearItem.build(knee_gear_item),
      foot_gear: GearItem.build(foot_gear_item),
      primary_weapon: GearItem.build(primary_weapon_item)
    }
  end

  @impl true
  def unequip_item(user_character_id, item_id) do
    user_character = Tarragon.Accounts.impl().get_user_character!(user_character_id)
    backpack = user_character.backpack

    item_id
    |> get_character_item!()
    |> Ecto.Changeset.change(%{item_container_id: backpack.id})
    |> Repo.update!()
  end

  @impl true
  def equip_item(user_character_id, item_id) do
    user_character = Tarragon.Accounts.impl().get_user_character!(user_character_id)
    backpack_items = user_character.backpack.items

    item = Enum.find(backpack_items, fn item -> item.id == item_id end)

    container =
      case item.game_item.purpose do
        :head_gear ->
          user_character.head_gear_slot

        :chest_gear ->
          user_character.chest_gear_slot

        :knee_gear ->
          user_character.knee_gear_slot

        :foot_gear ->
          user_character.foot_gear_slot

        :primary_weapon ->
          user_character.primary_weapon_slot
      end

    # change container_id of equipped to backpack
    if container.item do
      unequip_item(user_character_id, container.item.id)
    end

    # change container_id of unequipped to the found container
    item
    |> Ecto.Changeset.change(%{item_container_id: container.id})
    |> Repo.update!()
  end

  @impl true
  def upgrade_item_with_items(item_id, consumed_item_ids, added_xp) do
    item = get_character_item!(item_id)

    %{current_level: new_level, absolute_xp: absolute_xp} =
      Tarragon.Accounts.GearItem.calculate_upgrade_stats(item, added_xp)

    now = DateTime.utc_now()
    del_q = from(ci in CharacterItem, where: ci.id in ^consumed_item_ids)

    update_q =
      from(ci in CharacterItem,
        where: ci.id == ^item_id,
        update: [set: [level: ^new_level, xp_current: ^absolute_xp, updated_at: ^now]]
      )

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_consumed_items, del_q)
    |> Ecto.Multi.update_all("upgrade_item_#{item_id}", update_q, [])
    |> Repo.transaction()
  end
end
