defmodule TarragonWeb.FaceComponents do
  @moduledoc """
    Components that the user sees when she opens on the main game screen
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import TarragonWeb.Gettext

  import TarragonWeb.CoreComponents
  embed_templates "face_components/*"

  attr :bg_color, :string, default: "bg-transparent"
  attr :class, :string, default: nil
  slot :inner_block, required: true
  def action_badge(assigns)

  def experience_badge(assigns)

  def chrono_link_timer(assigns)

  def battle_badge(assigns)

  attr :class, :string, default: nil
  attr :bg_color, :string, default: "bg-red-500"
  attr :reversed, :boolean, default: false
  attr :percentage, :integer, default: 50
  attr :max, :integer, default: 100
  attr :current, :integer, default: 50
  attr :img_url, :string, default: nil
  def progress_bar(assigns)

  attr :class, :string, default: nil
  attr :reversed, :boolean, default: false
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
  def equipment_item(assigns)

  @style """
   .blue-game-button {
          background-color: #7accdc;
          border: 2px;
          border-style: solid;
          border-color: #000;
          border-radius: 12px;
          color: #fff;
          cursor: pointer;
          display: inline-block;
          outline: 0;
          padding: 16px 21px;
          position: relative;
          text-align: center;
          text-decoration: none;
          transition: all .3s;
          user-select: none;
          -webkit-user-select: none;
          touch-action: manipulation;
      }

      .blue-game-button:before {
           background-color: initial;
           background-image: linear-gradient(#ffffff 0, rgba(122, 204, 220, 0) 120%);
           border-radius: 8px;
           content: "";
           height: 50%;
           top: 4%;
           left: 4%;
           opacity: .7;
           position: absolute;
           transition: all .3s;
           width: 92%;
       }
"""
end
