defmodule Tarragon.Accounts.GearItemTest do
  use ExUnit.Case

  alias Tarragon.Accounts.GearItem

  describe "calculate_xp_on_level/2" do
    test "all rarities" do
      levels = 0..30

      xps =
        for level <- levels do
          assert {level, {:common, GearItem.calculate_xp_on_level(level, "common")},
                  {:uncommon, GearItem.calculate_xp_on_level(level, "uncommon")},
                  {:rare, GearItem.calculate_xp_on_level(level, "rare")},
                  {:epic, GearItem.calculate_xp_on_level(level, "epic")},
                  {:legendary, GearItem.calculate_xp_on_level(level, "legendary")}}
        end

      assert xps ==
               [
                 {0, {:common, 0}, {:uncommon, 0}, {:rare, 0}, {:epic, 0}, {:legendary, 0}},
                 {1, {:common, 14}, {:uncommon, 56}, {:rare, 1960}, {:epic, 13720},
                  {:legendary, 19600}},
                 {2, {:common, 42}, {:uncommon, 168}, {:rare, 5880}, {:epic, 41160},
                  {:legendary, 58800}},
                 {3, {:common, 118}, {:uncommon, 472}, {:rare, 16520}, {:epic, 115_640},
                  {:legendary, 165_200}},
                 {4, {:common, 266}, {:uncommon, 1064}, {:rare, 37240}, {:epic, 260_680},
                  {:legendary, 372_400}},
                 {5, {:common, 510}, {:uncommon, 2040}, {:rare, 71400}, {:epic, 499_800},
                  {:legendary, 714_000}},
                 {6, {:common, 874}, {:uncommon, 3496}, {:rare, 122_360}, {:epic, 856_520},
                  {:legendary, 1_223_600}},
                 {7, {:common, 1382}, {:uncommon, 5528}, {:rare, 193_480}, {:epic, 1_354_360},
                  {:legendary, 1_934_800}},
                 {8, {:common, 2058}, {:uncommon, 8232}, {:rare, 288_120}, {:epic, 2_016_840},
                  {:legendary, 2_881_200}},
                 {9, {:common, 2926}, {:uncommon, 11704}, {:rare, 409_640}, {:epic, 2_867_480},
                  {:legendary, 4_096_400}},
                 {10, {:common, 4010}, {:uncommon, 16040}, {:rare, 561_400}, {:epic, 3_929_800},
                  {:legendary, 5_614_000}},
                 {11, {:common, 5334}, {:uncommon, 21336}, {:rare, 746_760}, {:epic, 5_227_320},
                  {:legendary, 7_467_600}},
                 {12, {:common, 6922}, {:uncommon, 27688}, {:rare, 969_080}, {:epic, 6_783_560},
                  {:legendary, 9_690_800}},
                 {13, {:common, 8798}, {:uncommon, 35192}, {:rare, 1_231_720}, {:epic, 8_622_040},
                  {:legendary, 12_317_200}},
                 {14, {:common, 10986}, {:uncommon, 43944}, {:rare, 1_538_040},
                  {:epic, 10_766_280}, {:legendary, 15_380_400}},
                 {15, {:common, 13510}, {:uncommon, 54040}, {:rare, 1_891_400},
                  {:epic, 13_239_800}, {:legendary, 18_914_000}},
                 {16, {:common, 16394}, {:uncommon, 65576}, {:rare, 2_295_160},
                  {:epic, 16_066_120}, {:legendary, 22_951_600}},
                 {17, {:common, 19662}, {:uncommon, 78648}, {:rare, 2_752_680},
                  {:epic, 19_268_760}, {:legendary, 27_526_800}},
                 {18, {:common, 23338}, {:uncommon, 93352}, {:rare, 3_267_320},
                  {:epic, 22_871_240}, {:legendary, 32_673_200}},
                 {19, {:common, 27446}, {:uncommon, 109_784}, {:rare, 3_842_440},
                  {:epic, 26_897_080}, {:legendary, 38_424_400}},
                 {20, {:common, 32010}, {:uncommon, 128_040}, {:rare, 4_481_400},
                  {:epic, 31_369_800}, {:legendary, 44_814_000}},
                 {21, {:common, 37054}, {:uncommon, 148_216}, {:rare, 5_187_560},
                  {:epic, 36_312_920}, {:legendary, 51_875_600}},
                 {22, {:common, 42602}, {:uncommon, 170_408}, {:rare, 5_964_280},
                  {:epic, 41_749_960}, {:legendary, 59_642_800}},
                 {23, {:common, 48678}, {:uncommon, 194_712}, {:rare, 6_814_920},
                  {:epic, 47_704_440}, {:legendary, 68_149_200}},
                 {24, {:common, 55306}, {:uncommon, 221_224}, {:rare, 7_742_840},
                  {:epic, 54_199_880}, {:legendary, 77_428_400}},
                 {25, {:common, 62510}, {:uncommon, 250_040}, {:rare, 8_751_400},
                  {:epic, 61_259_800}, {:legendary, 87_514_000}},
                 {26, {:common, 70314}, {:uncommon, 281_256}, {:rare, 9_843_960},
                  {:epic, 68_907_720}, {:legendary, 98_439_600}},
                 {27, {:common, 78742}, {:uncommon, 314_968}, {:rare, 11_023_880},
                  {:epic, 77_167_160}, {:legendary, 110_238_800}},
                 {28, {:common, 87818}, {:uncommon, 351_272}, {:rare, 12_294_520},
                  {:epic, 86_061_640}, {:legendary, 122_945_200}},
                 {29, {:common, 97566}, {:uncommon, 390_264}, {:rare, 13_659_240},
                  {:epic, 95_614_680}, {:legendary, 136_592_400}},
                 {30, {:common, 108_010}, {:uncommon, 432_040}, {:rare, 15_121_400},
                  {:epic, 105_849_800}, {:legendary, 151_214_000}}
               ]
    end
  end

  test "calculate_level_by_xp" do
    levels = 0..29

    xps =
      for level <- levels do
        next_level = level + 1

        assert {level,
                [
                  {"common", GearItem.calculate_xp_on_level(next_level, "common") - 1},
                  {"uncommon", GearItem.calculate_xp_on_level(next_level, "uncommon") - 1},
                  {"rare", GearItem.calculate_xp_on_level(next_level, "rare") - 1},
                  {"epic", GearItem.calculate_xp_on_level(next_level, "epic") - 1},
                  {"legendary", GearItem.calculate_xp_on_level(next_level, "legendary") - 1}
                ]}
      end

    for {level, rarity_list} <- xps do
      for {rarity, xp} <- rarity_list do
        #        IO.inspect({level, rarity, xp})
        assert GearItem.calculate_level_by_xp(xp, rarity) == level
      end
    end
  end
end
