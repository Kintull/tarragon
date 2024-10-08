defmodule TarragonWeb.PageLive.DebugEcs do
  use TarragonWeb, :live_view

  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.Projections

  @impl true
  def mount(_params, _session, socket) do
    participant = Tarragon.Repo.all(Tarragon.Battles.Participant)
    |> Enum.filter(&(&1.is_bot == false))
    |> Enum.sort_by(&(&1.id), :desc)
    |> List.first()

    character_id = participant.user_character_id
    {:ok, combatant_entity} = Api.find_combatant_entity_by_user_character_id(character_id)
    {:ok, combatant} = Api.find_combatant_by_user_character_id(character_id)

    {:ok, team_entity} = Lookup.fetch_parent(combatant_entity, Tarragon.Ecspanse.Battles.Components.Team)
    {:ok, battle_entity} = Lookup.fetch_parent(team_entity, Tarragon.Ecspanse.Battles.Components.Battle)

    battle = Tarragon.Ecspanse.Battles.Projections.Battle.project_battle(battle_entity)

    if connected?(socket),
       do: Projections.Battle.start!(%{entity_id: battle_entity.id, client_pid: self()})


   fps = Ecspanse.Resource.debug()

    socket =
      socket
      |> assign(character_id: character_id)
      |> assign(player_combatant: combatant)
      |> assign(battle: battle)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
      module={TarragonWeb.PageLive.Ecspanse.Battles.Play.PlayerCombatants}
      battle={@battle}
      combatant={@player_combatant}
      id={"board_player_combatant_#{@player_combatant.entity.id}"}
      />
    </div>

    """
    # per system we need to know how much time it take to run a single cycle
  end

  @impl true
  def handle_info({:projection_updated, %{result: battle}}, socket) do
    player_combatant = find_player_combatant(battle, socket.assigns.character_id)

    socket
    |> assign(
         battle: battle,
         player_combatant: player_combatant
       )
    |> noreply()
  end

  defp find_player_combatant(battle, user_id) do
    Enum.find_value(battle.teams, fn team ->
      Enum.find(team.combatants, &(&1.combatant.user_id == user_id))
    end)
  end

end
