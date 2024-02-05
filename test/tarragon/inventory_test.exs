defmodule Tarragon.InventoryTest do
  use Tarragon.DataCase

  alias Tarragon.Inventory

  describe "items" do
    alias Tarragon.Inventory.GameItem

    @valid_attrs %{
      description: "some description",
      image: "some image",
      max_condition: 42,
      title: "some title",
      purpose: "head"
    }
    @update_attrs %{
      description: "some updated description",
      image: "some updated image",
      max_condition: 43,
      title: "some updated title",
      purpose: "body"
    }
    @invalid_attrs %{description: nil, image: nil, max_condition: nil, title: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Inventory.list_items() == [item]
    end

    test "get_game_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Inventory.get_game_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %GameItem{} = item} = Inventory.create_item(@valid_attrs)
      assert item.description == "some description"
      assert item.max_condition == 42
      assert item.title == "some title"
      assert item.image == "some image"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %GameItem{} = item} = Inventory.update_item(item, @update_attrs)
      assert item.description == "some updated description"
      assert item.max_condition == 43
      assert item.title == "some updated title"
      assert item.image == "some updated image"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_item(item, @invalid_attrs)
      assert item == Inventory.get_game_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %GameItem{}} = Inventory.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_game_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Inventory.change_item(item)
    end

    test "get_item_purposes/0 returns list of atoms" do
      assert is_atom(Inventory.get_item_purposes() |> Enum.at(0))
    end
  end

  describe "character_items" do
    alias Tarragon.Inventory.CharacterItem

    @valid_character_item_attrs %{current_condition: 42}
    @valid_container_attrs %{capacity: 1}

    def character_item_fixture(attrs \\ %{}) do
      {:ok, character_item} =
        attrs
        |> Enum.into(@valid_character_item_attrs)
        |> Inventory.create_character_item()

      character_item
    end

    def container_fixture(attrs \\ %{}) do
      {:ok, container} =
        attrs
        |> Enum.into(@valid_container_attrs)
        |> Inventory.create_container()

      container
    end

    test "update user_character item container" do
      character_item = character_item_fixture()
      character_item2 = character_item_fixture()
      container1 = container_fixture()
      container2 = container_fixture()

      {:ok, %CharacterItem{} = character_item} =
        Inventory.update_character_item_container(character_item, container1)

      {:ok, %CharacterItem{}} =
        Inventory.update_character_item_container(character_item2, container1)

      assert character_item.item_container.id == container1.id
      assert Repo.preload(container1, [:items]).items |> length == 2
      assert Repo.preload(container2, [:items]).items |> length == 0

      {:ok, %CharacterItem{} = character_item} =
        Inventory.update_character_item_container(character_item, container2)

      assert character_item.item_container.id == container2.id
      assert Repo.preload(container1, [:items]).items |> length == 1
      assert Repo.preload(container2, [:items]).items |> length == 1
    end
  end
end
