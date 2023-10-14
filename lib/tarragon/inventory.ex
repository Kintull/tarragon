defmodule Tarragon.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Tarragon.Repo

  alias Tarragon.Inventory.ShopItem
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.ItemContainer

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%ShopItem{}, ...]

  """
  def list_items do
    Repo.all(ShopItem)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the ShopItem does not exist.

  ## Examples

      iex> get_shop_item!(123)
      %ShopItem{}

      iex> get_shop_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shop_item!(id), do: Repo.get!(ShopItem, id)

  def get_user_item!(id), do: Repo.get!(CharacterItem, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %ShopItem{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}, after_save \\ fn -> :ok end) do
    %ShopItem{}
    |> ShopItem.changeset(attrs)
    |> after_save(after_save)
    |> Repo.insert()
  end


  @doc """
  Creates a user item.
  """
  def create_user_item(attrs \\ %{}, after_save \\ fn -> :ok end) do
    %CharacterItem{}
    |> CharacterItem.changeset(attrs)
    |> after_save(after_save)
    |> Repo.insert()
  end

  @doc """
  Creates a user item.
  """
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
      {:ok, %ShopItem{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%ShopItem{} = item, attrs, after_save_func \\ fn -> :ok end) do
    item
    |> ShopItem.changeset(attrs)
    |> after_save(after_save_func)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %ShopItem{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%ShopItem{} = item) do
    Repo.delete(item)
  end

  def get_item_purposes() do
    ShopItem.get_purposes()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %ShopItem{}}

  """
  def change_item(%ShopItem{} = item, attrs \\ %{}) do
    ShopItem.changeset(item, attrs)
  end

  def update_user_item(%CharacterItem{} = item, attrs, after_save_func \\ fn -> :ok end) do
    item
    |> CharacterItem.changeset(attrs)
    |> after_save(after_save_func)
    |> Repo.update()
  end

  def update_user_item_container(%CharacterItem{} = user_item, container) do
    user_item
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
end