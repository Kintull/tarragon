defmodule Tarragon.Factory do
  use ExMachina.Ecto, repo: Tarragon.Repo

  def user_factory do
    %Tarragon.Accounts.User{
      email: sequence(:email, &"user-#{&1}@mail.com"),
      name: sequence("name"),
      password_hash: sequence("passwordHash")
    }
  end

  def user_character_factory do
    %Tarragon.Accounts.UserCharacter{
      id: sequence("id", & &1),
      user: build(:user),
      nickname: sequence("CharacterNickname"),
      current_health: 10,
      max_health: 10,
      active: true
    }
  end

  def with_full_equipment(user_character) do
    bow = build(:game_item, base_damage_bonus: 5, title: sequence("bow"))
    helmet = build(:game_item, base_defence_bonus: 3, title: sequence("helmet"))
    chest = build(:game_item, base_health_bonus: 2, title: sequence("chest"))
    knee_pad = build(:game_item, base_range_bonus: 1, title: sequence("knee_pad"))
    boots = build(:game_item, base_health_bonus: 1, title: sequence("boots"))

    character_bow = build(:character_item, game_item: bow)
    character_helmet = build(:character_item, game_item: helmet)
    character_chest = build(:character_item, game_item: chest)
    character_knee_pad = build(:character_item, game_item: knee_pad)
    character_boots = build(:character_item, game_item: boots)

    weapon = build(:item_container, items: [character_bow])
    head_gear = build(:item_container, items: [character_helmet])
    chest_gear = build(:item_container, items: [character_chest])
    knee_gear = build(:item_container, items: [character_knee_pad])
    foot_gear = build(:item_container, items: [character_boots])

    %{
      user_character
      | head_gear_slot: head_gear,
        chest_gear_slot: chest_gear,
        knee_gear_slot: knee_gear,
        foot_gear_slot: foot_gear,
        primary_weapon_slot: weapon
    }
  end

  def character_item_factory do
    %Tarragon.Inventory.CharacterItem{
      current_condition: 100
    }
  end

  def item_container_factory do
    %Tarragon.Inventory.ItemContainer{
      capacity: 1
    }
  end

  def game_item_factory do
    %Tarragon.Inventory.GameItem{
      description: "A test item",
      image: "test_image.png",
      base_item_condition: 100,
      title: "Test Item",
      # Assuming you have predefined purposes
      purpose: :head_gear,
      base_damage_bonus: 0,
      base_defence_bonus: 0,
      base_health_bonus: 0,
      base_range_bonus: 0
    }
  end
end
