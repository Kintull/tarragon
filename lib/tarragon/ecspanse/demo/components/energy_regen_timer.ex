defmodule Tarragon.Ecspanse.Demo.Components.EnergyRegenTimer do
  @moduledoc """
  restore 1 point of energy every 3 seconds
  """
  alias Tarragon.Ecspanse.Demo.Events

  use Ecspanse.Template.Component.Timer,
    state: [duration: 3000, time: 3000, event: Events.EnergyRegenTimerElapsed, mode: :repeat]
end
