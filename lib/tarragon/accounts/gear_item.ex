defmodule Tarragon.Accounts.GearItem do
  @moduledoc """
  Value object representing a character gear item.

  * build/1
  * calculate_xp_on_level/2
  * calculate_level_by_xp/2
  * calculate_consume_xp_value/4
  * sell_xp_value/1
  * calculate_reparation_costs/1
  * rarity_drop_chance/1
  * init_condition/1
  * calculate_resources_per_hour/2
  * ceil_nearest/1
  """
  use Ecto.Schema

  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.GameItem

  @type t :: %__MODULE__{}

  embedded_schema do
    field :game_item_id, :string
    field :kind, :string
    field :img_url, :string
    field :rarity, :string
    field :level, :integer
    field :condition, :string
    field :condition_current, :integer
    field :condition_max, :integer
    field :condition_initial, :integer
    field :is_broken, :boolean
    field :is_repairable, :boolean
    field :reparation_cost, :map
    field :quantity, :integer
    field :consume_xp_value, :integer
    field :xp_till_next_level, :integer
    field :xp_current, :integer
  end

  def build(nil), do: nil

  def build(item = %CharacterItem{}) do
    rarity = "#{item.rarity}"
    xp_current = item.xp_current
    condition_initial = item.game_item.initial_condition
    condition_current = item.current_condition
    condition_max = item.current_max_condition

    consume_xp_value = calculate_consume_xp_value(item)

    level = calculate_level_by_xp(xp_current, rarity)
    xp_till_next_level = calculate_xp_on_level(level, rarity)
    reparation_cost = calculate_reparation_costs(rarity)

    %__MODULE__{
      kind: item.game_item.purpose,
      id: item.id,
      game_item_id: item.game_item.id,
      img_url: item.game_item.image,
      rarity: rarity,
      level: level,
      condition: "#{condition_current}/#{condition_max}",
      condition_current: condition_current,
      condition_max: condition_max,
      condition_initial: condition_initial,
      is_broken: item.current_condition == 0,
      is_repairable: !(condition_current == 0 and condition_max == 1),
      reparation_cost: reparation_cost,
      quantity: 1,
      xp_till_next_level: xp_till_next_level,
      xp_current: xp_current,
      consume_xp_value: consume_xp_value
    }
  end

  import Ecto.Query
  alias Tarragon.Repo

  def generate_item(type, opts \\ %{}) do
    game_item =
      Repo.all(from gi in GameItem, where: gi.purpose == ^type, limit: 1)
      |> List.first()

    %CharacterItem{
      rarity: "common",
      game_item_id: game_item.id,
      game_item: game_item,
      current_condition: game_item.initial_condition,
      current_max_condition: game_item.initial_condition,
      xp_current: 0
    }
    |> build()
    |> Map.merge(opts)
  end

  def calculate_xp_on_level(level, rarity) do
    # 0.0037 *  level^{3} - LVL 30 - x100 multiplier
    rarity = "#{rarity}"

    xp_additional =
      case rarity do
        "common" -> sell_xp_value(rarity) * (Integer.pow(level, 3) * 0.4)
        "uncommon" -> sell_xp_value(rarity) * (Integer.pow(level, 3) * 0.4)
        "rare" -> sell_xp_value(rarity) * (Integer.pow(level, 3) * 0.4)
        "epic" -> sell_xp_value(rarity) * (Integer.pow(level, 3) * 0.4)
        "legendary" -> sell_xp_value(rarity) * (Integer.pow(level, 3) * 0.4)
      end

    xp = if level == 0, do: 0, else: xp_additional + sell_xp_value(rarity)
    round(xp)
  end

  def calculate_upgrade_stats(item, added_xp) do
    current_item_xp = item.xp_current

    # current xp 30, added xp 100
    # lvl  10 ............  11
    # xp in absolute values
    #      100 ... 130 ... 200
    # xp relative to the current level xp
    #      0 ..... 30 .... 100

    level_with_added_xp = calculate_level_by_xp(current_item_xp + added_xp, item.rarity)

    absolute_left_xp_boundary = calculate_xp_on_level(level_with_added_xp, item.rarity)
    absolute_right_xp_boundary = calculate_xp_on_level(level_with_added_xp + 1, item.rarity)

    relative_left_xp_boundary = 0
    relative_right_xp_boundary = absolute_right_xp_boundary - absolute_left_xp_boundary
    relative_current_xp = current_item_xp + added_xp - absolute_left_xp_boundary

    percentage_till_next_level = round(relative_current_xp / relative_right_xp_boundary * 100)

    %{
      absolute_xp: current_item_xp + added_xp,
      left_xp_boundary: relative_left_xp_boundary,
      right_xp_boundary: relative_right_xp_boundary,
      xp_current: relative_current_xp,
      percentage_till_next_level: percentage_till_next_level,
      current_level: level_with_added_xp
    }
  end

  def calculate_level_by_xp(xp_current, rarity) do
    max_gear_level = 30

    0..max_gear_level
    |> Enum.map(fn lvl -> {lvl, calculate_xp_on_level(lvl, rarity)} end)
    |> Enum.reverse()
    |> Enum.find({max_gear_level, 123_321}, fn {_lvl, xp_required_for_level} ->
      xp_current >= xp_required_for_level
    end)
    |> elem(0)
  end

  def calculate_consume_xp_value(item) do
    # once used - devaluates by 20%
    # when 0/1 devaluation is 33% + 20% = 55%
    rarity = "#{item.rarity}"
    initial_exp = sell_xp_value(rarity)
    xp_current = item.xp_current
    condition_initial = item.game_item.initial_condition
    condition_max = item.current_max_condition
    xp = initial_exp + xp_current
    devaluation = 0.8 * xp - xp * (1 - condition_max / condition_initial) * 0.3
    round(devaluation)
  end

  def sell_xp_value(rarity) do
    %{
      "common" => 10,
      "uncommon" => 40,
      "rare" => 1_400,
      "epic" => 9_800,
      "legendary" => 14_000
    }[rarity]
  end

  def calculate_reparation_costs(rarity) do
    case rarity do
      "common" ->
        calculate_resources_per_hour(3, [:scrap_parts, :chrono_link_time_1m])

      "uncommon" ->
        calculate_resources_per_hour(6, [:scrap_parts, :chrono_link_time_1m, :energy_cells])

      "rare" ->
        calculate_resources_per_hour(12, [
          :scrap_parts,
          :chrono_link_time_1m,
          :energy_cells,
          :uranium
        ])

      "epic" ->
        calculate_resources_per_hour(246, [
          :scrap_parts,
          :chrono_link_time_1m,
          :energy_cells,
          :uranium
        ])

      "legendary" ->
        calculate_resources_per_hour(48, [
          :scrap_parts,
          :chrono_link_time_1m,
          :energy_cells,
          :uranium
        ])
    end
  end

  def init_condition(rarity) do
    case "#{rarity}" do
      "common" -> 10
      "uncommon" -> 20
      "rare" -> 30
      "epic" -> 40
      "legendary" -> 50
    end
  end

  def rarity_drop_chance(rarity) do
    %{
      "common" => 0.8,
      "uncommon" => 0.2,
      # 1 in 25 days
      "rare" => 0.0013,
      # 1 in 50 days
      "epic" => 0.00066,
      # 1 in 100 days
      "legendary" => 0.00033
    }[rarity]
  end

  defp calculate_resources_per_hour(hours, resources) do
    per_minute = %{
      uranium: 10,
      energy_cells: 20,
      # needed for upgrading
      upgrade_chips: 0.1,
      # needed for repairing
      scrap_parts: 1,
      time_shards: 0.1,
      chrono_link_time_1m: 1,
      upgrade_booster_1m: 1,
      reparation_booster_1m: 1,
      driving_booster_1m: 1
    }

    resources = resources || Map.keys(per_minute)

    all = Enum.reduce(resources, 0, fn resource, acc -> acc + per_minute[resource] end)

    Enum.map(resources, fn resource ->
      quantity = round(per_minute[resource] / all * hours * 60) |> ceil_nearest()
      {resource, quantity}
    end)
    |> Enum.into(%{})
  end

  def ceil_nearest(num) when num > 10, do: ceil(num / 10) * 10
  def ceil_nearest(num), do: num
end
