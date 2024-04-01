defmodule Tarragon.Ecspanse.Demo.DemoManager do
  @moduledoc """
  Adds the demo systems to the expanse manager.  That is, if you want the demo system to be active,
  call setup from the ecspanse manager.
  """

  alias Tarragon.Ecspanse.Demo.Systems

  def setup(data) do
    data
    #
    # system startup
    #
    |> Ecspanse.add_startup_system(Systems.Startup.HeroSpawner)
    |> Ecspanse.add_startup_system(Systems.Startup.MarketSpawner)
    #
    # frame start
    #
    |> Ecspanse.add_frame_start_system(Systems.FrameStart.HeroSpawner)
    |> Ecspanse.add_frame_start_system(Systems.FrameStart.MarketRestocker)
    #
    # every frame
    #
    |> Ecspanse.add_system(Systems.EnergyRegenerator)
    |> Ecspanse.add_system(Systems.EnergyRegenTimerManager)
    |> Ecspanse.add_system(Systems.HealthRegenerator)
    |> Ecspanse.add_system(Systems.HealthRegenTimerManager)
    |> Ecspanse.add_system(Systems.MaybeFindMoney)
    |> Ecspanse.add_system(Systems.PositionChangeRequestProcessor,
      run_after: [Systems.EnergyRegenerator]
    )
    #
    # frame end
    #
    |> Ecspanse.add_frame_end_system(Systems.FrameEnd.MarketPurchaseManager)
  end
end
