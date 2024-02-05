defmodule TarragonWeb.PageLive.BackpackScreen do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Inventory

  def mount(_params, %{"user_id" => user_id}, socket) do
    user_character = Accounts.impl().get_character_by_user_id!(user_id)
    preloaded_items = Inventory.impl().get_user_character_items(user_character.id).backpack

    socket =
      socket
      |> assign(:user_character, user_character)
      |> assign(:preloaded_items, preloaded_items)

    {:ok, socket, layout: false}
  end
end
