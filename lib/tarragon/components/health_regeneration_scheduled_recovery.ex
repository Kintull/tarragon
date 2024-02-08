defmodule Tarragon.Components.HealthRegenerationScheduledRecovery do
  @moduledoc """
  The entity recovers a health point at this time
  """
  use ECSx.Component,
    value: :datetime
end
