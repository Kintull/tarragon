defmodule Tarragon.Ecspanse.Lobby.CombatantKey do
  defstruct team: nil, profession: nil

  @type t :: %__MODULE__{
          team: atom(),
          profession: atom()
        }
end

defmodule Tarragon.Ecspanse.Lobby.PlayerAssignment do
  alias Tarragon.Ecspanse.Lobby.CombatantKey
  defstruct combatant_key: nil, user_id: nil

  @type t :: %__MODULE__{
          combatant_key: CombatantKey.t(),
          user_id: any()
        }
end

defmodule PlayerCombatants do
  alias Tarragon.Ecspanse.Lobby.PlayerAssignment
  alias Tarragon.Ecspanse.Lobby.CombatantKey

  defstruct assignments_list: []

  @type t :: %__MODULE__{
          assignments_list: list(PlayerAssignment.t())
        }

  # def clear_assignment(%__MODULE__{} = player_combatants, team, profession),
  #   do: clear_assignment(player_combatants, %CombatantKey{team: team, profession: profession})

  # def clear_assignment(%__MODULE__{} = player_combatants, %CombatantKey{} = combatant_key) do
  #   case Enum.find(player_combatants.assignments_list, &(&1.combatant_key == combatant_key)) do
  #     nil ->
  #       player_combatants

  #     assignment ->
  #       Map.put(
  #         player_combatants,
  #         :assignments_list,
  #         List.delete(player_combatants.assignments_list, assignment)
  #       )
  #   end
  # end

  def clear_assignment(%__MODULE__{} = player_combatants, user_id) do
    case Enum.find(player_combatants.assignments_list, &(&1.user_id == user_id)) do
      nil ->
        player_combatants

      assignment ->
        Map.put(
          player_combatants,
          :assignments_list,
          List.delete(player_combatants.assignments_list, assignment)
        )
    end
  end

  def assign(%__MODULE__{} = player_combatants, team, profession, user_id),
    do: assign(player_combatants, %CombatantKey{team: team, profession: profession}, user_id)

  def assign(%__MODULE__{} = player_combatants, %CombatantKey{} = combatant_key, user_id) do
    player_combatants = clear_assignment(player_combatants, combatant_key)

    assignments_list = [
      %PlayerAssignment{combatant_key: combatant_key, user_id: user_id}
      | player_combatants.assignments_list
    ]

    Map.put(player_combatants, :assignments_list, assignments_list)
  end

  def get_combatant_key(%__MODULE__{} = player_combatants, user_id) do
    case Enum.find(player_combatants.assignments_list, &(&1.user_id == user_id)) do
      nil -> nil
      assignment -> assignment.combatant_key
    end
  end

  def get_user_id(%__MODULE__{} = player_combatants, %CombatantKey{} = combatant_key) do
    case Enum.find(player_combatants.assignments_list, &(&1.combatant_key == combatant_key)) do
      nil -> nil
      assignment -> assignment.user_id
    end
  end
end

defmodule Tarragon.Ecspanse.Lobby.LobbyGame do
  alias Tarragon.Ecspanse.Lobby.GameParameters

  @enforce_keys [:game_parameters]

  defstruct id: System.monotonic_time(),
            game_parameters: nil,
            player_combatants: %PlayerCombatants{}

  @type t :: %__MODULE__{
          id: integer(),
          game_parameters: GameParameters.t(),
          player_combatants: PlayerCombatants.t()
        }

  def new(), do: new(GameParameters.new())

  def new(game_parameters) do
    struct!(__MODULE__,
      id: game_parameters.id,
      game_parameters: game_parameters
    )
  end

  def assign_player_combatant(%__MODULE__{} = lobby_game, team, profession, user_id) do
    player_combatants =
      PlayerCombatants.assign(lobby_game.player_combatants, team, profession, user_id)

    Map.put(lobby_game, :player_combatants, player_combatants)
  end

  def clear_player_combatant(%__MODULE__{} = lobby_game, user_id) do
    player_combatants =
      PlayerCombatants.clear_assignment(lobby_game.player_combatants, user_id)

    Map.put(lobby_game, :player_combatants, player_combatants)
  end

  def get_combatant_key(%__MODULE__{} = lobby_game, user_id) do
    PlayerCombatants.get_combatant_key(lobby_game.player_combatants, user_id)
  end
end
