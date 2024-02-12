defmodule Tarragon.Ecspanse.Manager do
  @moduledoc """
  The main module used to configure and interact with Ecspanse.
  """
  alias Tarragon.Ecspanse.Systems
  use Ecspanse

  @impl Ecspanse
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
    |> Ecspanse.add_frame_start_system(Ecspanse.System.TrackFPS)
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
    |> Ecspanse.add_frame_end_system(Ecspanse.System.Timer)
  end
end
