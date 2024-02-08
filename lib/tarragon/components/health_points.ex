defmodule Tarragon.Components.HealthPoints do
  @moduledoc """
  How many health points the entity has left.
  """
  use ECSx.Component,
    value: :integer
end
