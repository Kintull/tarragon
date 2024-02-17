defmodule Tarragon.Ecspanse.Demo.Events.EnergyRegenTimerElapsed do
  @moduledoc """
  This event will be automatically triggered when the EnergyRegenTimer component duration reaches 0.
  """
  use Ecspanse.Template.Event.Timer
end
