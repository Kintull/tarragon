defmodule Tarragon.Ecspanse.Lobby.LobbyGame do
  @moduledoc false
  alias Tarragon.Ecspanse.GameParameters

  @enforce_keys [:game_parameters]

  use TypedStruct

  typedstruct do
    field :id, integer, default: System.monotonic_time()
    field :game_parameters, GameParameters.t()
    field :player_combatants, PlayerCombatant.t()
  end

  typedstruct module: PlayerCombatant do
    field :character_id, integer()
    field :profession, atom()
    field :team, atom()
  end

  def new(game_parameters \\ GameParameters.new()) do
    struct!(__MODULE__,
      id: game_parameters.id,
      game_parameters: game_parameters
    )
  end

  def assign_player_combatant(%__MODULE__{} = lobby_game, team, profession, character_id) do
    player_combatants =
      [
        %PlayerCombatant{
          team: team,
          profession: profession,
          character_id: character_id
        }
        | lobby_game.player_combatants
      ]

    Map.put(lobby_game, :player_combatants, player_combatants)
  end

  def clear_player_combatant(%__MODULE__{} = lobby_game, user_id) do
    player_combatants =
      Enum.filter(lobby_game.player_combatants, fn combatant ->
        combatant.character_id != user_id
      end)

    Map.put(lobby_game, :player_combatants, player_combatants)
  end

  def get_combatant_key(%__MODULE__{} = lobby_game, character_id) do
    player_combatants = lobby_game.player_combatants

    Enum.find(player_combatants, fn combatant ->
      combatant.character_id == character_id
    end)
  end
end
