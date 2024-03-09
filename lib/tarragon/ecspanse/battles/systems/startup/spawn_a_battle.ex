defmodule Tarragon.Ecspanse.Battles.Systems.Startup.SpawnABattle do
  alias Tarragon.Ecspanse.Battles.Events

  use Ecspanse.System

  def run(_frame) do
    Ecspanse.event({Events.SpawnBattleRequest, []})
  end
end
