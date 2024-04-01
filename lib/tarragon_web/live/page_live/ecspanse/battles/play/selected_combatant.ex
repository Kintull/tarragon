defmodule TarragonWeb.PageLive.Ecspanse.Battles.Play.SelectedCombatant do
  @moduledoc false
  alias Tarragon.Ecspanse.Battles.Api
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div>Name: <%= @combatant.brand.name %></div>

      <div>Profession: <%= @combatant.profession.name %></div>

      <div>Health: <%= @combatant.health.current %></div>

      <div>Action Points: <%= @combatant.action_points.current %></div>

      <div>Position: <%= @combatant.position.x %></div>

      <div class="underline underline-offset-2">Available Actions</div>

      <div class="grid grid-cols-2 gap-2 pt-2">
        <div
          :for={action <- @combatant.available_actions}
          class={[
            "p-2 bg-slate-300 rounded-full",
            (@combatant.action_points.current < action.action.action_point_cost ||
               !@combatant.combatant.waiting_for_intentions) &&
              "border-2 border-red-500"
          ]}
          phx-click="schedule-action"
          phx-target={@myself}
          phx-value-action-entity-id={action.entity.id}
        >
          <.action_tag_content action={action.action} />
        </div>

        <div :if={!Enum.any?(@combatant.available_actions)}>-- none --</div>
      </div>

      <button
        :if={@combatant.combatant.waiting_for_intentions}
        phx-click="lock_intentions"
        phx-value-combatant_entity_id={@combatant.entity.id}
        phx-target={@myself}
        class="m-2 border-2 border-green-700 hover:border-green-900
        bg-green-700/25
        py-2 px-4 rounded-lg"
        title="The decision phase can end when all combatants lock their actions"
      >
        🔒 Lock Actions 🛈
      </button>

      <div class="underline underline-offset-2">Scheduled Actions</div>

      <div class="grid grid-cols-2 gap-2 pt-2">
        <div
          :for={action <- @combatant.scheduled_actions}
          class={[
            "p-2 bg-slate-300 rounded-full",
            !@combatant.combatant.waiting_for_intentions &&
              "border-2 border-red-500"
          ]}
          phx-click="cancel-scheduled-action"
          phx-target={@myself}
          phx-value-action-entity-id={action.entity.id}
        >
          <.action_tag_content action={action.action} />
        </div>

        <div :if={!Enum.any?(@combatant.scheduled_actions)}>-- none --</div>
      </div>
    </div>
    """
  end

  attr :action, :any, required: true

  def action_tag_content(assigns) do
    ~H"""
    <%= @action.icon %> <%= @action.name %> <%= String.duplicate("$", @action.action_point_cost) %>
    """
  end

  def handle_event(
        "cancel-scheduled-action",
        %{"action-entity-id" => scheduled_action_entity_id},
        socket
      ) do
    Api.cancel_scheduled_action(scheduled_action_entity_id)
    {:noreply, socket}
  end

  def handle_event(
        "lock_intentions",
        %{"combatant_entity_id" => combatant_entity_id},
        socket
      ) do
    Api.lock_intentions(combatant_entity_id)
    {:noreply, socket}
  end

  def handle_event(
        "schedule-action",
        %{"action-entity-id" => available_action_entity_id},
        socket
      ) do
    Api.schedule_available_action(available_action_entity_id)
    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    IO.puts("unhandled_event in #{__MODULE__}: #{inspect({event, params}, pretty: true)}")
    # IO.inspect({event, params}, label: "unhandled_event in #{__MODULE__}")
    {:noreply, socket}
  end
end
