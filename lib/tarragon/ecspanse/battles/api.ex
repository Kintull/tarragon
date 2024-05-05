defmodule Tarragon.Ecspanse.Battles.Api do
  @moduledoc """
  Methods to be used by systems outside of the ecspanse battle framework.
  """
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Projections

  def spawn_battle() do
    Ecspanse.event({Events.SpawnBattleRequest, [lobby_game: LobbyGame.new()]})
  end

  def spawn_battle(%LobbyGame{} = lobby_game) do
    Ecspanse.event({Events.SpawnBattleRequest, [lobby_game: lobby_game]})
  end

  def battle_exists?(battle_entity_id) do
    with {:ok, entity} <- Ecspanse.Entity.fetch(battle_entity_id),
         {:ok, _battle} <- Components.Battle.fetch(entity) do
      true
    else
      _ -> false
    end
  end

  @spec cancel_scheduled_action(Ecspanse.Entity.id()) :: :ok
  def cancel_scheduled_action(scheduled_action_entity_id) do
    Ecspanse.event(
      {Events.CancelScheduledAction, [scheduled_action_entity_id: scheduled_action_entity_id]}
    )
  end

  def find_battle_by_game(game_id) do
    case Components.Battle.list()
         |> Enum.find(&(&1.game_id == game_id)) do
      nil ->
        {:error, :not_found}

      battle_component ->
        {:ok,
         Projections.Battle.project_battle(Ecspanse.Query.get_component_entity(battle_component))}
    end
  end

  @spec list_battles() :: list(struct())
  @doc """
  returns a list of entities for battles
  """
  def list_battles() do
    Projections.Battle.project_battles()
  end

  @spec list_battle(String.t()) :: struct() | {:error, :not_found}
  def list_battle(battle_entity_id) do
    Projections.Battle.project_battle(battle_entity_id)
  end

  @spec lock_intentions(Ecspanse.Entity.id()) :: :ok
  def lock_intentions(combatant_entity_id) do
    Ecspanse.event({Events.LockIntentions, [combatant_entity_id: combatant_entity_id]})
  end

  @spec schedule_available_action(Ecspanse.Entity.id()) :: :ok
  def schedule_available_action(available_action_entity_id) do
    Ecspanse.event(
      {Events.ScheduleAvailableAction, [available_action_entity_id: available_action_entity_id]}
    )
  end
end
