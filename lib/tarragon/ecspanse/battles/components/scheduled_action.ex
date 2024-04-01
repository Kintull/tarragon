defmodule Tarragon.Ecspanse.Battles.Components.ScheduledAction do
  @moduledoc """
  An action the combatant has chosen to execute

  This is essentilly a tag to be able to identify scheduled actions.
  """
  use Ecspanse.Component,
    state: [],
    tags: [:scheduled_action]
end
