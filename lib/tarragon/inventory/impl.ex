defmodule Tarragon.Inventory.Impl do
  @moduledoc """
  The Inventory context.
  """

  @behaviour Tarragon.Inventory

  import Ecto.Query, warn: false
  alias Tarragon.Repo

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
end
