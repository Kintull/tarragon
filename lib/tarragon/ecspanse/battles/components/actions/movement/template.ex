defmodule Tarragon.Ecspanse.Battles.Components.Actions.Movement.Template do
  @moduledoc """
  the template for any form of movement
  """
  use Ecspanse.Template.Component,
    # use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [steps: 1, action_group: :movement],
    tags: [:action, :movement]

  @impl true
  def validate(state) do
    validate_steps(state[:steps])
    validate_action_point_cost(state[:action_point_cost])
  end

  defp validate_steps(steps) when is_integer(steps) and steps >= 0, do: :ok
  defp validate_steps(steps), do: {:error, "#{inspect(steps)} must be a non-negative integer"}

  defp validate_action_point_cost(action_point_cost)
       when is_integer(action_point_cost) and action_point_cost >= 0,
       do: :ok

  defp validate_action_point_cost(action_point_cost),
    do: {:error, "#{inspect(action_point_cost)} must be a non-negative integer"}
end
