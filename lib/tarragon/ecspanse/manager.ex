defmodule Tarragon.Ecspanse.Manager do
  @moduledoc """
  The main module used to configure and interact with Ecspanse.
  """
  use Ecspanse

  @impl Ecspanse
  def setup(data) do
    data
    #
    # system startup
    #
    #
    # frame start
    #
    |> Ecspanse.add_frame_start_system(Ecspanse.System.TrackFPS)

    #
    # every frame
    #
    #
    # frame end
    #
    |> Ecspanse.add_frame_end_system(Ecspanse.System.Timer)
    # |> Tarragon.Ecspanse.Demo.DemoManager.setup()
    |> Tarragon.Ecspanse.Battles.BattlesManager.setup()
  end
end
