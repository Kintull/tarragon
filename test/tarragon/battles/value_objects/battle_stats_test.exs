defmodule Tarragon.CharacterBattleBonusesTest do
  use Tarragon.DataCase

  describe "build_character_bonuses/1" do
    test "aggregates bonuses from all gear slots correctly" do
      bow = insert(:game_item, base_damage_bonus: 5)
      helmet = insert(:game_item, base_defence_bonus: 3)
      chest = insert(:game_item, base_health_bonus: 2)
      knee_pad = insert(:game_item, base_range_bonus: 1)
      boots = insert(:game_item, base_health_bonus: 1)

      character_bow = insert(:character_item, game_item: bow)
      character_helmet = insert(:character_item, game_item: helmet)
      character_chest = insert(:character_item, game_item: chest)
      character_knee_pad = insert(:character_item, game_item: knee_pad)
      character_boots = insert(:character_item, game_item: boots)

      weapon = insert(:item_container, items: [character_bow])
      head_gear = insert(:item_container, items: [character_helmet])
      chest_gear = insert(:item_container, items: [character_chest])
      knee_gear = insert(:item_container, items: [character_knee_pad])
      foot_gear = insert(:item_container, items: [character_boots])

      user_character =
        insert(:user_character,
          nickname: "TestPlayer",
          max_health: 10,
          head_gear_slot: head_gear,
          chest_gear_slot: chest_gear,
          knee_gear_slot: knee_gear,
          foot_gear_slot: foot_gear,
          primary_weapon_slot: weapon
        )

      # Call your function
      result = Tarragon.Battles.CharacterBattleBonuses.build_character_bonuses(user_character.id)

      # Assertions
      assert result.character_id == user_character.id
      assert result.nickname == "TestPlayer"
      assert result.attack_bonus == 5
      assert result.defence_bonus == 3
      # 2 from chest_gear + 1 from foot_gear
      assert result.health_bonus == 3
      # 10 base + 3 health bonus
      assert result.max_health == 13
      assert result.range_bonus == 1
    end
  end
end
