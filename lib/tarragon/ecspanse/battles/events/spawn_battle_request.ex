defmodule Tarragon.Ecspanse.Battles.Events.SpawnBattleRequest do
  @moduledoc """
  A request from an external system to spawn a battle
  """
  use Ecspanse.Event,
    fields: [
      :lobby_game
    ]
end
