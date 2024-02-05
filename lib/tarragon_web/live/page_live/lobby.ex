defmodule TarragonWeb.PageLive.Lobby do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Battles

  @impl true
  def mount(_params, %{"user_id" => user_id}, %{assigns: assigns} = socket) do
    character = Accounts.impl().get_character_by_user_id!(user_id)
    participant = assigns[:participant] || get_active_participant(character)

    socket = assign(socket, character: character)
    socket = assign(socket, counter_sec: 0)

    socket =
      case participant do
        %{battle_room_id: battle_room_id} when battle_room_id != nil ->
          push_redirect(socket, to: ~p"/battle_screen")

        nil ->
          assign(socket, %{participant: nil})

        participant ->
          assign(socket, %{participant: participant})
      end

    {:ok, socket, layout: false}
  end

  def mount(_params, _session, socket) do
    socket = put_flash(socket, :error, "Please sign in")
    {:ok, push_redirect(socket, to: ~p"/"), layout: false}
  end

  @impl true
  def handle_event("search_for_battles", _, %{assigns: %{character: character}} = socket) do
    participant =
      case socket.assigns.participant do
        nil ->
          Battles.impl().create_participant(%{user_character_id: character.id})

        participant ->
          participant
      end

    Phoenix.PubSub.subscribe(Tarragon.PubSub, "awaiting_participant:#{participant.id}")
    Process.send_after(self(), :tick_timer, 1000)
    {:noreply, socket |> assign(%{participant: participant})}
  end

  def handle_event(
        "stop_searching_for_battles",
        _,
        %{assigns: %{participant: participant}} = socket
      ) do
    {:ok, _} = Battles.impl().delete_participant(participant)
    Phoenix.PubSub.unsubscribe(Tarragon.PubSub, "awaiting_participant:#{participant.id}")
    {:noreply, socket |> assign(%{participant: nil})}
  end

  @impl true
  def handle_info("battle_room_assigned", %{assigns: assigns} = socket) do
    participant = get_active_participant(assigns.character)
    Phoenix.PubSub.unsubscribe(Tarragon.PubSub, "awaiting_participant:#{participant.id}")

    {:noreply,
     socket |> assign(%{participant: participant}) |> push_redirect(to: ~p"/battle_screen")}
  end

  def handle_info(:tick_timer, %{assigns: assigns} = socket) do
    socket =
      if assigns.participant != nil do
        Process.send_after(self(), :tick_timer, 1000)
        assign(socket, counter_sec: assigns.counter_sec + 1)
      else
        assign(socket, counter_sec: 0)
      end

    {:noreply, socket}
  end

  defp get_active_participant(character) do
    case Battles.impl().get_active_participant(character) do
      %{} = participant ->
        participant

      _ ->
        nil
    end
  end
end
