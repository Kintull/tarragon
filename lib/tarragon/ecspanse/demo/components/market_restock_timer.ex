defmodule Tarragon.Ecspanse.Demo.Components.MarketRestockTimer do
  @moduledoc """
  replenish market items timer
  """
  alias Tarragon.Ecspanse.Demo.Events

  use Ecspanse.Template.Component.Timer,
    state: [
      duration: :timer.seconds(10),
      time: :timer.seconds(10),
      event: Events.MarketRestockTimerElapsed,
      mode: :repeat
    ]
end
