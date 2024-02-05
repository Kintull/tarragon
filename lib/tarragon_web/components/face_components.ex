defmodule TarragonWeb.FaceComponents do
  @moduledoc """
    Components that the user sees when she opens on the main game screen
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import TarragonWeb.CoreComponents
  embed_templates "face_components/*"

  attr :bg_color, :string, default: "bg-transparent"
  attr :class, :string, default: "min-h-[40px] min-w-[40px]"
  slot :inner_block, required: true
  def action_badge(assigns)

  def experience_badge(assigns)

  def chrono_link_timer(assigns)

  def battle_badge(assigns)

  attr :requires_confirmation, :boolean, default: false
  attr :confirmation_button_text, :string, default: nil
  # "upgrading_item" | "repairing_item" | "replacing_item" | "equipping_item"
  attr :action, :string, default: nil
  attr :modal_id, :string, default: nil
  attr :title_text, :string, default: ""
  slot :inner_block
  def equipment_modal(assigns)

  attr :class, :string, default: nil
  attr :bg_color, :string, default: "bg-red-500"
  attr :reversed, :boolean, default: false
  attr :collapsable, :boolean, default: true
  attr :percentage, :integer, default: 50
  attr :max, :integer, default: 100
  attr :current, :integer, default: 50
  attr :img_url, :string, default: nil

  def progress_bar(assigns)

  attr :class, :string, default: nil
  attr :reversed, :boolean, default: false
  attr :user_character, Tarragon.Accounts.UserCharacter
  def health_bar(assigns)

  attr :class, :string, default: nil
  attr :reversed, :boolean, default: true
  def drone_bar(assigns)

  attr :class, :string, default: nil
  def return_badge(assigns)

  attr :class, :string, default: nil
  attr :img_url, :string, required: true
  attr :rarity, :string, required: true
  attr :quantity, :integer, default: 1
  attr :level, :integer, default: 1
  attr :condition, :string, default: nil
  attr :is_broken, :boolean, default: false
  attr :is_repairable, :boolean, default: true
  attr :is_selected, :boolean, default: false
  def equipment_item(assigns)

  attr :player_name, :string, default: "UserName123123123"
  attr :class, :string, default: nil
  attr :hg_rarity, :string, default: "uncommon"
  attr :cg_rarity, :string, default: "rare"
  attr :pw_rarity, :string, default: "epic"
  attr :fg_rarity, :string, default: "legendary"
  attr :atk_value, :integer, default: 10
  attr :def_value, :integer, default: 20
  attr :range_value, :integer, default: 30
  attr :distance_to_value, :integer, default: 40
  attr :max_hp, :integer, default: 100
  attr :current_hp, :integer, default: 50
  def battle_player_component(assigns)

  attr :class, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :attack, :string, default: nil
  def battle_attack_component(assigns)

  attr :class, :string, default: nil
  attr :move, :string, default: nil
  def battle_move_component(assigns)

  attr :class, :string, default: nil
  attr :log_entries, :list, default: []
  attr :current_character_id, :integer, default: nil
  attr :characters, :list, default: []
  attr :ally_character_ids, :list, default: []
  def battle_log_component(assigns)

  attr :state, :string, default: "idle"
  attr :class, :string, default: nil
  attr :submitted_players_cnt, :integer, default: 0
  attr :total_players_cnt, :integer, default: 6
  attr :seconds_left, :integer, default: 59
  attr :disabled, :boolean, default: false
  attr :waiting, :boolean, default: false
  def battle_confirm_component(assigns)

  attr :class, :string, default: nil
  attr :modal_id, :string
  attr :items, :list, default: []
  attr :inactive_items, :list, default: []
  attr :selected_items, :map, default: %{}
  attr :action, :string, default: nil
  attr :requires_confirmation, :boolean, default: false
  def gear_container(assigns)
end
