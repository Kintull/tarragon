defmodule Tarragon.Components.HealthIncrementPoints do
  @moduledoc """
  A request to adjust the health points by this amount
  """
  use ECSx.Component,
    value: :integer
end
