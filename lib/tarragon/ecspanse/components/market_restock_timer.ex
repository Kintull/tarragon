defmodule Tarragon.Ecspanse.Components.MarketRestockTimer do
  @moduledoc """
  replenish market items timer
  """
  alias Tarragon.Ecspanse.Events

  use Ecspanse.Template.Component.Timer,
    state: [
      duration: :timer.seconds(10),
      time: :timer.seconds(10),
      event: Events.MarketRestockTimerElapsed,
      mode: :repeat
    ]
end
