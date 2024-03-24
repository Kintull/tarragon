defmodule Seeder do
  alias Tarragon.Battles

  def create_character do
    random_number = :rand.uniform(1_000_000)
    name = "Nick-#{random_number}"
    email = "email_#{random_number}@mail.com"
    password = "123"

    user =
      Tarragon.Repo.insert!(%Tarragon.Accounts.User{name: name, email: email, password: password})

    character =
      Tarragon.Repo.insert!(%Tarragon.Accounts.UserCharacter{
        active: true,
        user: user,
        nickname: name,
        avatar_url:
          Enum.random(["/images/male-character-avatar.png", "/images/female-character-avatar.png"]),
        avatar_background_url:
          Enum.random(["/images/male-character.webp", "/images/female-character.webp"]),
        max_health: 10,
        current_health: 10
      })

    character
  end

  def create_character_with_items do
    character = create_character()

    items =
      Tarragon.Repo.all(Tarragon.Inventory.GameItem)
      |> Enum.uniq_by(fn gi -> gi.purpose end)

    create_bag(character, items)
    create_equipment(character, items)

    bonuses = Battles.impl().build_character_bonuses(character.id)

    Ecto.Changeset.change(character, %{
      current_health: bonuses.max_health,
      max_health: bonuses.max_health
    })
    |> Tarragon.Repo.update!()

    character
  end

  def create_bag(character, items) do
    bag =
      Tarragon.Repo.insert!(%Tarragon.Inventory.ItemContainer{
        items: [],
        capacity: 1000,
        backpack_id: character.id
      })

    Enum.each(items, fn item ->
      Enum.map(
        [:common, :uncommon, :rare, :epic, :legendary],
        fn rarity ->
          init_condition = Tarragon.Accounts.GearItem.init_condition(rarity)

          Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
            quantity: 100,
            rarity: rarity,
            game_item: item,
            item_container_id: bag.id,
            current_condition: init_condition,
            current_max_condition: init_condition
          })

          Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
            quantity: 1,
            rarity: rarity,
            game_item: item,
            item_container_id: bag.id,
            current_condition: 0,
            current_max_condition: init_condition
          })

          Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
            quantity: 1,
            rarity: rarity,
            game_item: item,
            item_container_id: bag.id,
            current_condition: 0,
            current_max_condition: 1
          })
        end
      )
    end)
  end

  def create_equipment(character, items) do
    create_containers(character)

    character = Tarragon.Accounts.Impl.get_user_character!(character.id)

    for item <- items do
      container =
        case item.purpose do
          :head_gear ->
            character.head_gear_slot

          :chest_gear ->
            character.chest_gear_slot

          :knee_gear ->
            character.knee_gear_slot

          :foot_gear ->
            character.foot_gear_slot

          :primary_weapon ->
            character.primary_weapon_slot
        end

      rarity = :common
      init_condition = Tarragon.Accounts.GearItem.init_condition(rarity)

      Tarragon.Repo.insert!(%Tarragon.Inventory.CharacterItem{
        game_item: item,
        item_container_id: container.id,
        rarity: rarity,
        current_condition: init_condition,
        current_max_condition: init_condition
      })
    end
  end

  def create_containers(character) do
    fks = [
      :head_gear_slot_id,
      :chest_gear_slot_id,
      :primary_weapon_slot_id,
      :knee_gear_slot_id,
      :foot_gear_slot_id
    ]

    for fk <- fks do
      Tarragon.Repo.insert!(
        Map.merge(
          %Tarragon.Inventory.ItemContainer{capacity: 1},
          %{fk => character.id}
        )
      )
    end
  end

  def create_battle_room_with_participants(ally_characters, enemy_characters) do
    battle_room =
      Tarragon.Repo.insert!(%Tarragon.Battles.Room{
        participants: [],
        started_at: DateTime.now!("Etc/UTC") |> DateTime.truncate(:second),
        awaiting_start: false
      })

    for character <- ally_characters do
      Tarragon.Repo.insert!(%Tarragon.Battles.Participant{
        user_character: character,
        battle_room: battle_room,
        team_a: true
      })
    end

    for character <- enemy_characters do
      Tarragon.Repo.insert!(%Tarragon.Battles.Participant{
        user_character: character,
        battle_room: battle_room,
        team_b: true
      })
    end

    battle_room
  end

  def delete_all_participants_and_rooms do
    Tarragon.Repo.delete_all(Tarragon.Battles.Participant)
    Tarragon.Repo.delete_all(Tarragon.Battles.Room)
  end

  def hard_reset_battles do
    Seeder.delete_all_participants_and_rooms()
    ally_characters = for x <- 1..3, do: Seeder.create_character_with_items()
    enemy_characters = for x <- 1..3, do: Seeder.create_character_with_items()
    Seeder.create_battle_room_with_participants(ally_characters, enemy_characters)

    ally_characters |> List.first()
  end
end
