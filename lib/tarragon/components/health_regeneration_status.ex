defmodule Tarragon.Components.HealthRegenerationStatus do
  @moduledoc """
  The status of the health.
  """

  use ECSx.Component,
    value: :atom

  @idle :idle
  @regenerating :regenerating

  def idle, do: @idle
  def regenerating, do: @regenerating

  defguard is_idle(value) when value == @idle
  defguard is_regenerating(value) when value == @regenerating
end
