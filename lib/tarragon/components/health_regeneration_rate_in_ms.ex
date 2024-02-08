defmodule Tarragon.Components.HealthRegenerationRateInMs do
  @moduledoc """
  The number of milliseconds to wait before recovering a health point
  """
  use ECSx.Component,
    value: :integer
end
