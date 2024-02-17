defmodule Tarragon.Ecspanse.Demo.Events.HealthRegenTimerElapsed do
  @moduledoc """
  This event will be automatically triggered when the HealthRegenTimer component duration reaches 0.
  """
  use Ecspanse.Template.Event.Timer
end
