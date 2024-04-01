defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.IndexLive do
  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.Projections

  use TarragonWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        scan_battles(socket)
      else
        assign(socket, battles: [])
      end

    {:ok, socket}
  end

  defp scan_battles(socket) do
    known_battles = Map.get(socket.assigns, :battles, [])

    new_battles =
      Api.list_battles()
      |> Enum.reject(fn battle ->
        Enum.any?(known_battles, fn known -> known.entity.id == battle.entity.id end)
      end)

    Enum.each(new_battles, fn battle ->
      Projections.Battle.start!(%{entity_id: battle.entity.id, client_pid: self()})
    end)

    battles =
      Enum.concat(new_battles, Map.get(socket.assigns, :battles, []))
      |> Enum.sort_by(& &1.battle.name)

    assign(socket,
      battles: battles
    )
  end

  def handle_event("spawn_battle", _params, socket) do
    Api.spawn_battle()
    :timer.send_after(200, self(), :scan_battles)
    {:noreply, socket}
  end

  def handle_info({:projection_updated, %{result: battle}}, socket) do
    updated_battles =
      Map.get(socket.assigns, :battles, [])
      |> Enum.reject(&(&1.entity.id == battle.entity.id))
      |> Enum.concat([battle])
      |> Enum.sort_by(& &1.battle.name)

    socket = assign(socket, :battles, updated_battles)

    {:noreply, socket}
  end

  def handle_info(:scan_battles, socket) do
    socket = scan_battles(socket)
    {:noreply, socket}
  end
end
