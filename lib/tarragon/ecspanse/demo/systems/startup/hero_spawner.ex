defmodule Tarragon.Ecspanse.Demo.Systems.Startup.HeroSpawner do
  alias Tarragon.Ecspanse.Demo.Events.SpawnHeroRequest
  use Ecspanse.System

  def run(_frame) do
    Enum.each(1..5, fn _num ->
      Ecspanse.event(SpawnHeroRequest)
    end)
  end
end
