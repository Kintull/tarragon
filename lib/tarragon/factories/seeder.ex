defmodule Seeder do
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
end
