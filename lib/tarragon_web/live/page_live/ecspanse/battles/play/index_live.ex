defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.IndexLive do
  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.Projections

  use TarragonWeb, :live_view

  def mount(%{"battle_entity_id" => battle_entity_id}, _session, socket) do
    if Api.battle_exists?(battle_entity_id) do
      battle = Api.list_battle(battle_entity_id)

      selected_combatant = hd(hd(battle.teams).combatants)

      socket =
        socket
        |> assign(
          battle: battle,
          selected_combatant: selected_combatant,
          selected_combatant_id: selected_combatant.entity.id
        )

      if connected?(socket),
        do: Projections.Battle.start!(%{entity_id: battle_entity_id, client_pid: self()})

      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: ~p"/ecspanse/battles/dump/index")}
    end
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
