defmodule Tarragon.Ecspanse.Demo.Components.HealthRegenTimer do
  @moduledoc """
  restore 1 point of health every 3 seconds
  """
  alias Tarragon.Ecspanse.Demo.Events

  use Ecspanse.Template.Component.Timer,
    state: [duration: 3000, time: 3000, event: Events.HealthRegenTimerElapsed, mode: :repeat]
end
