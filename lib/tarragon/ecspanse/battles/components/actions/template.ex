defmodule Tarragon.Ecspanse.Battles.Components.Actions.Template do
  @moduledoc """
  the template for any form of movement
  """

  use Ecspanse.Template.Component,
    state: [:name, icon: "m", action_point_cost: 1],
    tags: [:action]

  @impl true
  def validate(state) do
    validate_action_point_cost(state[:action_point_cost])
  end

  defp validate_action_point_cost(action_point_cost)
       when is_integer(action_point_cost) and action_point_cost >= 0,
       do: :ok

  defp validate_action_point_cost(action_point_cost),
    do: {:error, "#{inspect(action_point_cost)} must be a non-negative integer"}
end
