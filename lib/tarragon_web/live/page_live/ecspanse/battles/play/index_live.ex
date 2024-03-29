defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.IndexLive do
  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.Projections

  use TarragonWeb, :live_view

  def mount(_params, _session, socket) do
    socket |> assign(:battle_loaded, false) |> ok()
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params do
        %{"game_id" => game_id} ->
          load_game(socket, game_id)

        %{"battle_id" => battle_entity_id} ->
          load_battle(socket, battle_entity_id)

        _ ->
          IO.inspect(params, label: "params")
          socket |> push_navigate(to: ~p"/ecspanse/battles/dump")
      end

    noreply(socket)
  end

  def load_game(socket, game_id) when is_binary(game_id),
    do: load_game(socket, String.to_integer(game_id))

  def load_game(socket, game_id) do
    with {:ok, battle} <- Api.find_battle_by_game(game_id) do
      assign_battle(socket, battle)
    else
      {:error, :not_found} ->
        push_navigate(socket, to: ~p"/ecspanse/battles/dump")
    end
  end

  def load_battle(socket, battle_entity_id) do
    case Api.list_battle(battle_entity_id) do
      {:error, :not_found} ->
        push_navigate(socket, to: ~p"/ecspanse/battles/dump")

      battle ->
        assign_battle(socket, battle)
    end
  end

  defp assign_battle(socket, battle) do
    selected_combatant = hd(hd(battle.teams).combatants)

    socket =
      socket
      |> assign(
        battle: battle,
        selected_combatant: selected_combatant,
        selected_combatant_id: selected_combatant.entity.id,
        battle_loaded: true
      )

    if connected?(socket),
      do: Projections.Battle.start!(%{entity_id: battle.entity.id, client_pid: self()})

    socket
  end

  defp find_combatant(battle, combatant_entity_id) when is_nil(combatant_entity_id),
    do: hd(hd(battle.teams).combatants)

  defp find_combatant(battle, combatant_entity_id) do
    battle.teams
    |> Enum.map(& &1.combatants)
    |> List.flatten()
    |> Enum.find(fn combatant -> combatant.entity.id == combatant_entity_id end)
  end

  def handle_event("select_combatant", %{"combatant_entity_id" => combatant_entity_id}, socket) do
    selected_combatant = find_combatant(socket.assigns.battle, combatant_entity_id)

    socket =
      socket
      |> assign(
        selected_combatant: selected_combatant,
        selected_combatant_id: combatant_entity_id
      )

    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: "unhandled_event")
    {:noreply, socket}
  end

  def handle_info({:projection_updated, %{result: battle}}, socket) do
    selected_combatant = find_combatant(battle, socket.assigns.selected_combatant_id)

    socket = assign(socket, battle: battle, selected_combatant: selected_combatant)

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "unhandled_info")
    {:noreply, socket}
  end
end
