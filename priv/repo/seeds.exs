# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tarragon.Repo.insert!(%Tarragon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Application.put_env(:tarragon, :battles_impl, Tarragon.Battles.Impl)
Application.put_env(:tarragon, :inventory_impl, Tarragon.Inventory.Impl)
Application.put_env(:tarragon, :accounts_impl, Tarragon.Accounts.Impl)

bow =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Scout bow",
    description: "Modern ranged weapon",
    base_item_condition: 10,
    base_damage_bonus: 4,
    base_range_bonus: 4,
    base_defence_bonus: 0,
    base_health_bonus: 0,
    purpose: :primary_weapon,
    image: "/images/bow.webp"
  })

bow =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Scout chest plate",
    description: "Plate made of complex alloys",
    base_item_condition: 10,
    base_damage_bonus: 0,
    base_range_bonus: 0,
    base_defence_bonus: 10,
    base_health_bonus: 10,
    purpose: :chest_gear,
    image: "/images/chest-plate-transparent.webp"
  })

boots =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Scout Boots",
    description: "Boots that almost never break",
    base_item_condition: 10,
    base_damage_bonus: 0,
    base_range_bonus: 0,
    base_defence_bonus: 2,
    base_health_bonus: 2,
    purpose: :foot_gear,
    image: "/images/boot-transparent.webp"
  })

boots =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Scout kneepads",
    description: "Protects your knees when you fall",
    base_item_condition: 10,
    base_damage_bonus: 0,
    base_range_bonus: 0,
    base_defence_bonus: 3,
    base_health_bonus: 3,
    purpose: :knee_gear,
    image: "/images/knee-pads-transparent.webp"
  })

helmet =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Scout helmet",
    description: "Gives you clear vision and protects your head",
    base_item_condition: 10,
    base_damage_bonus: 0,
    base_range_bonus: 0,
    base_defence_bonus: 5,
    base_health_bonus: 5,
    purpose: :head_gear,
    image: "/images/helmet.webp"
  })

apple_game_item =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Apple",
    description: "medium fruit",
    base_item_condition: 10,
    purpose: :head_gear,
    image: "/images/appel.jpg",
    base_damage_bonus: 4
  })

watermelon_game_item =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "Watermelon",
    description: "large fruit",
    base_item_condition: 100,
    image: "/images/watermelon.jpg",
    base_damage_bonus: 8
  })

grape_game_item =
  Tarragon.Repo.insert!(%Tarragon.Inventory.GameItem{
    title: "A grape",
    description: "small fruit",
    base_item_condition: 5,
    image: "/images/grape.jpg",
    base_damage_bonus: 2
  })

apple1 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: apple_game_item,
    current_condition: 10
  })

apple2 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: apple_game_item,
    current_condition: 10
  })

watermelon1 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: watermelon_game_item,
    current_condition: 10
  })

watermelon2 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: watermelon_game_item,
    current_condition: 5
  })

grape1 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: grape_game_item,
    current_condition: 5
  })

grape2 =
  Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
    game_item: grape_game_item,
    current_condition: 10
  })

bag_roma = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [apple1], capacity: 5})

bag_alisa =
  Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{
    items: [watermelon1, grape1],
    capacity: 5
  })

hand_roma = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [grape2]})
hand_alisa = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [apple2]})

roma_user =
  Tarragon.Repo.insert!(%Tarragon.Accounts.User{name: "roman", email: "roman@email.com"})

alisa_user =
  Tarragon.Repo.insert!(%Tarragon.Accounts.User{name: "alice", email: "alice@email.com"})

roma_character =
  Tarragon.Repo.insert!(%Tarragon.Accounts.UserCharacter{
    active: true,
    user: roma_user,
    nickname: "kintull",
    avatar_url: "/images/male-character-avatar.webp",
    primary_weapon_slot: hand_roma,
    backpack: bag_roma,
    max_health: 10,
    current_health: 10
  })

alisa_character =
  Tarragon.Repo.insert!(%Tarragon.Accounts.UserCharacter{
    active: true,
    user: alisa_user,
    nickname: "amber",
    avatar_url: "/images/female-character-avatar.webp",
    primary_weapon_slot: hand_alisa,
    backpack: bag_alisa,
    max_health: 10,
    current_health: 10
  })

for _ <- 0..6 do
  %{character: _bot_character} = Tarragon.Battles.BattleBots.create_new_bot()
end
