defmodule TarragonWeb.PageLive.PlayerScreen do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Battles
  alias Tarragon.Inventory
  alias Tarragon.Battles.CharacterBattleBonuses
  alias Tarragon.Accounts.GearItem
  import Tarragon.Accounts.GearItem

  def mount(_params, %{"user_id" => user_id}, socket) do
    user_character = Accounts.impl().get_character_by_user_id!(user_id)
    user_character_bonuses = Battles.impl().build_character_bonuses(user_character.id)

    all_items = Inventory.impl().get_user_character_items(user_character.id)

    backpack = all_items.backpack
    head_gear = all_items.head_gear
    chest_gear = all_items.chest_gear
    primary_weapon = all_items.primary_weapon
    foot_gear = all_items.foot_gear

    equipped_items = %{
      :head_gear => all_items.head_gear,
      :chest_gear => all_items.chest_gear,
      :primary_weapon => all_items.primary_weapon,
      :foot_gear => all_items.foot_gear
    }

    equipped_items =
      if head_gear, do: Map.put(equipped_items, head_gear.id, :head_gear), else: equipped_items

    equipped_items =
      if chest_gear, do: Map.put(equipped_items, chest_gear.id, :chest_gear), else: equipped_items

    equipped_items =
      if primary_weapon,
        do: Map.put(equipped_items, primary_weapon.id, :primary_weapon),
        else: equipped_items

    equipped_items =
      if foot_gear, do: Map.put(equipped_items, foot_gear.id, :foot_gear), else: equipped_items

    socket =
      socket
      |> assign(:user_character, user_character)
      |> assign(:user_character_bonuses, user_character_bonuses)
      |> assign(:equipped_items, equipped_items)
      |> assign(:all_backpack_items, backpack)
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

  def handle_event("equipping_item_initialize", %{"slot_kind" => slot_kind_binary}, socket) do
    slot_kind = String.to_atom(slot_kind_binary)
    items = Enum.filter(socket.assigns.all_backpack_items, fn i -> i.kind == slot_kind end)
    items = sort_items(items)

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :equipping_item)
      |> assign(:target_id, slot_kind)
      |> assign(:requires_confirmation, false)

    {:noreply, socket}
  end

  def handle_event("replacing_item_initialize", %{"item_id" => id}, socket) do
    kind = socket.assigns.equipped_items[id]
    items = Enum.filter(socket.assigns.all_backpack_items, fn i -> i.kind == kind end)
    items = sort_items(items)

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :replacing_item)
      |> assign(:target_id, id)
      |> assign(:requires_confirmation, false)

    {:noreply, socket}
  end

  def handle_event("upgrading_item_initialize", %{"item_id" => id}, socket) do
    kind = socket.assigns.equipped_items[id]
    items = Enum.filter(socket.assigns.all_backpack_items, fn i -> i.kind == kind end)
    items = sort_items(items)
    target_item = socket.assigns.equipped_items[kind]

    %{
      right_xp_boundary: right_xp_boundary,
      xp_current: xp_current,
      percentage_till_next_level: percentage_till_next_level,
      current_level: current_level
    } = GearItem.calculate_upgrade_stats(target_item, 0)

    socket =
      socket
      |> assign(:preloaded_items, items)
      |> assign(:action, :upgrading_item)
      |> assign(:target_id, id)
      |> assign(:target_item, target_item)
      |> assign(:requires_confirmation, true)
      |> assign(:confirmation_button_text, "Confirm upgrade")
      |> assign(:xp_with_selected, xp_current)
      |> assign(:lvl_with_xp_selected, current_level)
      |> assign(:xp_till_next_level, right_xp_boundary)
      |> assign(:percentage_till_next_level, percentage_till_next_level)

    {:noreply, socket}
  end

  def handle_event("upgrading_item_finalize", _, socket) do
    user_character = socket.assigns.user_character
    equipped_items = socket.assigns[:equipped_items]
    target_item_kind = equipped_items[socket.assigns.target_id]
    target_item = equipped_items[target_item_kind]
    selected_items = socket.assigns[:selected_items]

    xp_selected = Enum.map(selected_items, fn {_id, i} -> i.selected_xp end) |> Enum.sum()

    xp_total = target_item.xp_current + xp_selected
    lvl_with_xp_selected = GearItem.calculate_level_by_xp(xp_total, target_item.rarity)

    target_item = %{target_item | level: lvl_with_xp_selected, xp_current: xp_total}
    equipped_items = Map.put(equipped_items, target_item_kind, target_item)

    selected_items_ids = Enum.map(selected_items, fn {id, _i} -> id end)
    Inventory.impl().upgrade_item_with_items(target_item.id, selected_items_ids, xp_selected)

    all_items = Inventory.impl().get_user_character_items(user_character.id)
    backpack = all_items.backpack

    socket =
      socket
      |> assign(:equipped_items, equipped_items)
      |> assign(:all_backpack_items, backpack)

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
    user_character = socket.assigns.user_character
    item_to_equip = Enum.find(items, &(&1.id == id))

    item_to_equip = %{item_to_equip | quantity: 1}

    equipped_items =
      Map.merge(equipped_items, %{
        item_to_equip.kind => item_to_equip,
        item_to_equip.id => item_to_equip.kind
      })

    Inventory.impl().equip_item(user_character.id, item_to_equip.id)

    all_items = Inventory.impl().get_user_character_items(user_character.id)

    socket =
      socket
      |> assign(:equipped_items, equipped_items)
      |> assign(:all_backpack_items, all_items.backpack)

    {:noreply, socket}
  end

  def handle_event("selecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["replacing_item"] do
    items = socket.assigns.preloaded_items
    equipped_items = socket.assigns.equipped_items
    user_character = socket.assigns.user_character
    item_to_equip = Enum.find(items, &(&1.id == id))
    item_to_equip = %{item_to_equip | quantity: 1}

    item_to_remove = Enum.find(items, &(&1.kind == item_to_equip.kind))

    equipped_items =
      equipped_items
      |> Map.drop([item_to_remove.id, item_to_remove.kind])
      |> Map.merge(%{item_to_equip.kind => item_to_equip, item_to_equip.id => item_to_equip.kind})

    Inventory.impl().equip_item(user_character.id, item_to_equip.id)

    all_items = Inventory.impl().get_user_character_items(user_character.id)

    socket =
      socket
      |> assign(:equipped_items, equipped_items)
      |> assign(:all_backpack_items, all_items.backpack)

    {:noreply, socket}
  end

  def handle_event("selecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["upgrading_item"] do
    items = socket.assigns.preloaded_items

    selected_item_full = Enum.find(items, &(&1.id == id))
    max_quantity = selected_item_full.quantity || 0

    selected_items = socket.assigns[:selected_items]

    selected_items =
      cond do
        selected_items[id] && selected_items[id].quantity < max_quantity ->
          quantity = selected_items[id].quantity + 1

          %{
            selected_items
            | id => %{
                quantity: quantity,
                selected_xp: selected_items[id].selected_xp * quantity
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

    %{
      right_xp_boundary: right_xp_boundary,
      xp_current: xp_current,
      percentage_till_next_level: percentage_till_next_level,
      current_level: current_level
    } = GearItem.calculate_upgrade_stats(target_item, xp_selected)

    socket =
      socket
      |> assign(:selected_items, selected_items)
      |> assign(:xp_with_selected, xp_current)
      |> assign(:lvl_with_xp_selected, current_level)
      |> assign(:xp_till_next_level, right_xp_boundary)
      |> assign(:percentage_till_next_level, percentage_till_next_level)

    {:noreply, socket}
  end

  def handle_event("deselecting_item", %{"item_id" => id, "action" => action}, socket)
      when action in ["upgrading_item"] do
    target_item = socket.assigns.target_item
    selected_items = Map.drop(socket.assigns[:selected_items], [id])

    xp_selected =
      Enum.map(selected_items, fn {_id, i} -> i.selected_xp * i.quantity end) |> Enum.sum()

    %{
      right_xp_boundary: right_xp_boundary,
      xp_current: xp_current,
      percentage_till_next_level: percentage_till_next_level,
      current_level: current_level
    } = GearItem.calculate_upgrade_stats(target_item, xp_selected)

    socket =
      socket
      |> assign(:selected_items, selected_items)
      |> assign(:xp_with_selected, xp_current)
      |> assign(:lvl_with_xp_selected, current_level)
      |> assign(:xp_till_next_level, right_xp_boundary)
      |> assign(:percentage_till_next_level, percentage_till_next_level)

    {:noreply, socket}
  end

  defp sort_items(gear_items) do
    rarity_index = %{
      "common" => 1,
      "uncommon" => 2,
      "rare" => 3,
      "epic" => 4,
      "legendary" => 5
    }

    Enum.sort_by(gear_items, fn i ->
      rarity_index["#{i.rarity}"]
    end)
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
end
