defmodule TarragonWeb.PageLive.PlayerScreen do
  use TarragonWeb, :live_view

  def mount(_params, %{}, socket) do
    equipped_items = %{
      generate_item(:head_gear).id => :head_gear,
      generate_item(:chest_gear).id => :chest_gear,
      generate_item(:primary_weapon).id => :primary_weapon,
      generate_item(:knee_gear).id => :knee_gear,
      generate_item(:foot_gear).id => :foot_gear,
      :head_gear => generate_item(:head_gear),
      :chest_gear => generate_item(:chest_gear),
      :primary_weapon => generate_item(:primary_weapon),
      :knee_gear => generate_item(:knee_gear),
      :foot_gear => generate_item(:foot_gear)
    }

    socket =
      socket
      |> assign(:equipped_items, equipped_items)
      |> assign(:preloaded_items, [])
      |> assign(:action, nil)
      |> assign(:target_id, nil)
      |> assign(:selected_items, %{})
      |> assign(:requires_confirmation, false)
      |> assign(:confirmation_button_text, nil)
      |> assign(:xp_with_selected, nil)
      |> assign(:lvl_with_xp_selected, nil)
      |> assign(:xp_till_next_level, nil)

    {:ok, socket, layout: false}
  end

  def handle_event("recycle_item", %{"id" => id}, socket) do
    equipped_items =
      Map.drop(socket.assigns.equipped_items, [id, socket.assigns.equipped_items[id]])

    socket =
      socket
      |> assign(:equipped_items, equipped_items)

    {:noreply, socket}
  end

  def handle_event("equipping_item_initialize", %{"slot_id" => slot_id_binary}, socket) do
    slot_id = String.to_atom(slot_id_binary)

    items = [
      generate_item(socket.assigns.equipped_items[slot_id], %{
        id: 101,
        quantity: 3,
        condition: "10/10",
        is_broken: false,
        is_repairable: true,
        rarity: "common"
      }),
      generate_item(socket.assigns.equipped_items[slot_id], %{
        id: 100,
        quantity: 3,
        condition: "40/40",
        is_broken: false,
        is_repairable: true,
        rarity: "rare"
      })
    ]

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :equipping_item)
      |> assign(:target_id, slot_id)
      |> assign(:requires_confirmation, false)

    {:noreply, socket}
  end

  def handle_event("replacing_item_initialize", %{"item_id" => id}, socket) do
    items = [
      generate_item(socket.assigns.equipped_items[id], %{
        id: 101,
        quantity: 3,
        condition: "10/10",
        is_broken: false,
        is_repairable: true,
        rarity: "common"
      }),
      generate_item(socket.assigns.equipped_items[id], %{
        id: 100,
        quantity: 3,
        condition: "20/20",
        is_broken: false,
        is_repairable: true,
        rarity: "uncommon"
      })
    ]

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :replacing_item)
      |> assign(:target_id, id)
      |> assign(:requires_confirmation, false)

    {:noreply, socket}
  end

  def handle_event("upgrading_item_initialize", %{"item_id" => id}, socket) do
    kind = socket.assigns.equipped_items[id] |> IO.inspect()
    target_item = socket.assigns.equipped_items[kind] |> IO.inspect()

    items = [
      generate_item(kind),
      generate_item(kind, %{id: 100}),
      generate_item(kind, %{
        id: 101,
        quantity: 3,
        condition: "10/10",
        is_broken: false,
        is_repairable: true,
        rarity: "common"
      })
    ]

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :upgrading_item)
      |> assign(:target_id, id)
      |> assign(:target_item, target_item)
      |> assign(:requires_confirmation, true)
      |> assign(:confirmation_button_text, "Confirm upgrade")
      |> assign(:xp_with_selected, target_item.xp_current)
      |> assign(:lvl_with_xp_selected, target_item.level)
      |> assign(
        :xp_till_next_level,
        calculate_xp_on_level(target_item.level + 1, target_item.rarity)
      )

    calculate_xp_on_level(target_item.level + 1, target_item.rarity)

    {:noreply, socket}
  end

  def handle_event("upgrading_item_finalize", _, socket) do
    equipped_items = socket.assigns[:equipped_items]
    target_item_kind = equipped_items[socket.assigns.target_id]
    target_item = equipped_items[target_item_kind]
    selected_items = socket.assigns[:selected_items]

    xp_selected =
      Enum.map(selected_items, fn {_id, i} -> i.selected_xp * i.quantity end) |> Enum.sum()

    xp_total = target_item.xp_current + xp_selected
    lvl_with_xp_selected = calculate_level_by_xp(xp_total, target_item.rarity)

    target_item = %{target_item | level: lvl_with_xp_selected, xp_current: xp_total}
    equipped_items = Map.put(equipped_items, target_item_kind, target_item)

    socket =
      socket
      |> assign(:equipped_items, equipped_items)

    {:noreply, socket}
  end

  def handle_event("repairing_item_initialize", %{"item_id" => id}, socket) do
    items = [
      generate_item(:scrap_parts)
    ]

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :repairing_item)
      |> assign(:target_id, id)
      |> assign(:requires_confirmation, true)
      |> assign(:confirmation_button_text, "Confirm repair")

    {:noreply, socket}
  end

  def handle_event("repairing_item_finalize", _, socket) do
    equipped_items = socket.assigns[:equipped_items]
    target_item_kind = equipped_items[socket.assigns.target_id]
    target_item = equipped_items[target_item_kind]
    selected_items = socket.assigns[:selected_items]

    n_selected = Enum.reduce(selected_items, 0, fn {_, i}, acc -> acc + i.quantity end)

    [min, max] = String.split(target_item.condition, "/")

    min = Enum.min([String.to_integer(min) + n_selected, String.to_integer(max)])

    target_item = %{target_item | condition: "#{min}/#{max}", is_broken: false}

    equipped_items = Map.put(equipped_items, target_item_kind, target_item)

    socket =
      socket
      |> assign(:equipped_items, equipped_items)

    {:noreply, socket}
  end

  def handle_event("reset_action", _, socket) do
    socket =
      socket
      |> assign(:action, nil)
      |> assign(:target_id, nil)
      |> assign(:target_item, nil)
      |> assign(:preloaded_items, [])
      |> assign(:selected_items, %{})
      |> assign(:requires_confirmation, false)
      |> assign(:confirmation_button_text, nil)
      |> assign(:xp_with_selected, nil)
      |> assign(:lvl_with_xp_selected, nil)
      |> assign(:xp_till_next_level, nil)

    {:noreply, socket}
  end

  def handle_event("selecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["equipping_item"] do
    items = socket.assigns.preloaded_items
    equipped_items = socket.assigns.equipped_items
    item_to_equip = Enum.find(items, &(&1.id == id))

    item_to_equip = %{item_to_equip | quantity: 1}

    equipped_items =
      Map.merge(equipped_items, %{
        item_to_equip.kind => item_to_equip,
        item_to_equip.id => item_to_equip.kind
      })

    socket =
      socket
      |> assign(:equipped_items, equipped_items)

    {:noreply, socket}
  end

  def handle_event("selecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["replacing_item"] do
    items = socket.assigns.preloaded_items
    equipped_items = socket.assigns.equipped_items
    item_to_equip = Enum.find(items, &(&1.id == id))
    item_to_equip = %{item_to_equip | quantity: 1}

    item_to_remove = Enum.find(items, &(&1.kind == item_to_equip.kind))

    equipped_items =
      equipped_items
      |> Map.drop([item_to_remove.id, item_to_remove.kind])
      |> Map.merge(%{item_to_equip.kind => item_to_equip, item_to_equip.id => item_to_equip.kind})

    socket =
      socket
      |> assign(:equipped_items, equipped_items)

    {:noreply, socket}
  end

  def handle_event("selecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["upgrading_item", "repairing_item"] do
    items = socket.assigns.preloaded_items

    selected_item_full = Enum.find(items, &(&1.id == id))
    max_quantity = selected_item_full[:quantity] || 0

    selected_items = socket.assigns[:selected_items]

    selected_items =
      cond do
        selected_items[id] && selected_items[id].quantity < max_quantity ->
          %{
            selected_items
            | id => %{
                quantity: selected_items[id].quantity + 1,
                selected_xp: selected_items[id].selected_xp
              }
          }

        selected_items[id] == nil ->
          Map.merge(
            selected_items,
            %{id => %{quantity: 1, selected_xp: selected_item_full.consume_xp_value}}
          )

        true ->
          selected_items
      end

    target_item = socket.assigns.target_item

    xp_selected =
      Enum.map(selected_items, fn {_id, i} -> i.selected_xp * i.quantity end) |> Enum.sum()

    {target_item.xp_current, xp_selected}
    xp_selected_total = target_item.xp_current + xp_selected
    lvl_with_xp_selected = calculate_level_by_xp(xp_selected_total, target_item.rarity)
    xp_next_level = calculate_xp_on_level(lvl_with_xp_selected, target_item.rarity)

    socket =
      socket
      |> assign(:selected_items, selected_items)
      |> assign(:xp_with_selected, xp_selected_total)
      |> assign(:lvl_with_xp_selected, lvl_with_xp_selected)
      |> assign(:xp_till_next_level, xp_next_level)

    {:noreply, socket}
  end

  def handle_event("deselecting_item", %{"item_id" => id}, socket) do
    selected_items = Map.drop(socket.assigns[:selected_items], [id])
    socket = assign(socket, :selected_items, selected_items)
    {:noreply, socket}
  end

  defp generate_item(kind, opts \\ %{}) do
    id = opts[:id]
    quantity = opts[:quantity] || 1
    rarity = opts[:rarity] || "common"
    level = opts[:level] || 0
    condition_current = opts[:condition_current] || 10
    condition_max = opts[:condition_max] || 10

    base =
      case kind do
        :head_gear ->
          %{
            kind: :head_gear,
            id: id || 1,
            img_url: "/images/helmet.webp",
            rarity: rarity || "rare",
            level: level
          }

        :chest_gear ->
          %{
            kind: :chest_gear,
            id: id || 2,
            img_url: "/images/chest-plate-transparent.webp",
            rarity: rarity || "uncommon",
            level: level
          }

        :primary_weapon ->
          %{
            kind: :primary_weapon,
            id: id || 3,
            img_url: "/images/bow.webp",
            rarity: rarity || "common",
            level: level
          }

        :knee_gear ->
          %{
            kind: :knee_gear,
            id: id || 46,
            img_url: "/images/knee-pads-transparent.webp",
            rarity: rarity || "epic",
            level: level
          }

        :foot_gear ->
          %{
            kind: :foot_gear,
            id: id || 5,
            img_url: "/images/boot-transparent.webp",
            rarity: rarity || "legendary",
            level: level
          }

        :scrap_parts ->
          %{
            kind: :scrap_parts,
            id: id || 7,
            img_url: "/images/repair-pieces.png",
            rarity: rarity || "uncommon",
            level: level
          }
      end

    init_condition = init_condition(rarity)
    xp_current = 0
    condition_initial = init_condition(rarity)
    condition_current = condition_current || init_condition
    condition_max = condition_max || init_condition

    consume_xp_value =
      calculate_consume_xp_value(
        sell_xp_value(rarity),
        xp_current,
        condition_max,
        condition_initial
      )

    level = calculate_level_by_xp(xp_current, rarity)
    xp_till_next_level = calculate_xp_on_level(level, rarity)
    reparation_cost = calculate_reparation_costs(rarity)

    Map.merge(
      base,
      %{
        level: level,
        condition: "#{condition_current}/#{condition_max}",
        condition_current: condition_current,
        condition_max: condition_max,
        condition_initial: condition_initial,
        is_broken: condition_current == 0,
        is_repairable: !(condition_current == 0 and condition_max == 1),
        reparation_requirements: reparation_cost,
        quantity: quantity,
        consume_xp_value: consume_xp_value,
        xp_till_next_level: xp_till_next_level,
        xp_current: xp_current
      }
    )
  end

  def calculate_xp_on_level(level, rarity) do
    # 0.0037 *  level^{3} - LVL 30 - x100 multiplier
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

  def calculate_level_by_xp(xp, rarity) do
    0..30
    |> Enum.map(fn lvl -> {lvl, calculate_xp_on_level(lvl, rarity)} end)
    |> Enum.find(fn {_lvl, xp_on_level} -> xp_on_level >= xp end)
    |> elem(0)
  end

  def calculate_consume_xp_value(initial_exp, xp_current, condition_max, condition_initial) do
    # once used - devaluates by 20%
    # when 0/1 devaluation is 33% + 20% = 55%
    xp = initial_exp + xp_current
    devaluation = 0.8 * xp - xp * (1 - condition_max / condition_initial) * 0.3
    round(devaluation)
  end

  defmodule Resources do
    use Ecto.Schema

    embedded_schema do
      field :time_shards, :integer, default: 0
      field :time_shards_100, :integer, default: 0
      field :time_shards_10k, :integer, default: 0

      field :scrap_parts, :integer, default: 0
      field :scrap_parts_100, :integer, default: 0
      field :scrap_parts_10k, :integer, default: 0

      field :energy_cells, :integer, default: 0
      field :energy_cells_100, :integer, default: 0
      field :energy_cells_10k, :integer, default: 0

      field :uranium, :integer, default: 0
      field :uranium_100, :integer, default: 0
      field :uranium_10k, :integer, default: 0

      field :chrono_link_time_minute, :integer, default: 0
      field :chrono_link_time_minute_100, :integer, default: 0
      field :chrono_link_time_minute_10k, :integer, default: 0

      field :time_boost_1m, :integer, default: 0
      field :time_boost_1h, :integer, default: 0
      field :time_boost_3h, :integer, default: 0
      field :time_boost_8h, :integer, default: 0
      field :time_boost_1d, :integer, default: 0

      field :driving_boost, :integer, default: 0
    end
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

  def sell_xp_value(rarity) do
    %{
      "common" => 10,
      "uncommon" => 40,
      "rare" => 1_400,
      "epic" => 9_800,
      "legendary" => 14_000
    }[rarity]
  end

  defp init_condition(rarity) do
    case rarity do
      "common" -> 10
      "uncommon" -> 20
      "rare" -> 30
      "epic" -> 40
      "legendary" -> 50
    end
  end
end
