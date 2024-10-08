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

  def find_combatant_by_user_character_id(user_character_id) do
    case Components.Combatant.list()
         |> Enum.find(&(&1.user_id == user_character_id)) do
      nil ->
        {:error, :not_found}

      combatant_component ->
        {:ok,
         Projections.Combatant.project_combatant(
           Ecspanse.Query.get_component_entity(combatant_component)
         )}
    end
  end

  def find_combatant_entity_by_user_character_id(user_character_id) do
    case Components.Combatant.list()
         |> Enum.find(&(&1.user_id == user_character_id)) do
      nil ->
        {:error, :not_found}

      combatant_component ->
        {:ok, Ecspanse.Query.get_component_entity(combatant_component)}
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

  @spec update_attack_target(Ecspanse.Entity.id(), Ecspanse.Entity.id()) :: :ok
  def update_attack_target(player_combatant_entity_id, selected_combatant_entity_id) do
    IO.inspect("<<<<<<<<<<update_attack_target>>>>>")
    Ecspanse.event(
      {Events.SelectAttackTarget, [selected_combatant_entity_id: selected_combatant_entity_id, player_combatant_entity_id: player_combatant_entity_id]}
    )
  end

  @spec schedule_available_action(Ecspanse.Entity.id()) :: :ok
  def schedule_available_action(available_action_entity_id) do
    Ecspanse.event(
      {Events.ScheduleAvailableAction, [available_action_entity_id: available_action_entity_id]}
    )
  end

  @spec cancel_scheduled_action(Ecspanse.Entity.id()) :: :ok
  def cancel_scheduled_action(action_entity_id) do
    Ecspanse.event(
      {Events.CancelScheduledAction, [action_entity_id: action_entity_id]}
    )
  end

  @spec update_move_direction(Ecspanse.Entity.id(), integer, integer, integer) :: :ok
  def update_move_direction(combatant_entity_id, x, y, z) do
    Ecspanse.event(
      {Events.SelectMoveTile, [combatant_entity_id: combatant_entity_id, x: x, y: y, z: z]}
    )
  end
end
