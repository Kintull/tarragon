defmodule Tarragon.Components.HealthMaxPoints do
  @moduledoc """
  The maximum number of health points an entity can have
  """
  use ECSx.Component,
    value: :integer
end
