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



apple_shop_item = Tarragon.Repo.insert!(%Tarragon.Inventory.ShopItem{title: "Apple", description: "medium fruit", max_condition: 10, purpose: :head, image: "/images/appel.jpg", base_damage: 4})
watermelon_shop_item = Tarragon.Repo.insert!(%Tarragon.Inventory.ShopItem{title: "Watermelon", description: "large fruit", max_condition: 100, image: "/images/watermelon.jpg", base_damage: 8})
grape_shop_item = Tarragon.Repo.insert!(%Tarragon.Inventory.ShopItem{title: "A grape", description: "small fruit", max_condition: 5, image: "/images/grape.jpg", base_damage: 2})

apple1 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: apple_shop_item, current_condition: 10})
apple2 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: apple_shop_item, current_condition: 10})
watermelon1 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: watermelon_shop_item, current_condition: 10})
watermelon2 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: watermelon_shop_item, current_condition: 5})
grape1 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: grape_shop_item, current_condition: 5})
grape2 = Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{shop_item: grape_shop_item, current_condition: 10})

bag_roma = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [apple1], capacity: 5})
bag_alisa = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [watermelon1, grape1], capacity: 5})

hand_roma = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [grape2]})
hand_alisa = Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{items: [apple2]})

roma_user = Tarragon.Repo.insert!(%Tarragon.Accounts.User{name: "roman", email: "roman@email.com"})
alisa_user = Tarragon.Repo.insert!(%Tarragon.Accounts.User{name: "alice", email: "alice@email.com"})

roma_character = Tarragon.Repo.insert!(%Tarragon.Accounts.UserCharacter{active: true, user: roma_user, nickname: "kintull", hand: hand_roma, backpack: bag_roma, max_health: 10, current_health: 10})
alisa_character = Tarragon.Repo.insert!(%Tarragon.Accounts.UserCharacter{active: true, user: alisa_user, nickname: "amber", hand: hand_alisa, backpack: bag_alisa, max_health: 10, current_health: 10})
