defmodule Tarragon.Ecspanse.Battles.Components.Actions.Template do
  @moduledoc """
  the template for any form of action
  """

  use Ecspanse.Template.Component,
    state: [:name, :action_group, icon: "a", action_point_cost: 1],
    tags: [:action]

  @impl true
  def validate(state) do
    with :ok <- validate_name(state[:name]) do
      validate_action_point_cost(state[:action_point_cost], state[:name])
    end
  end

  defp validate_action_point_cost(action_point_cost, _name)
       when is_integer(action_point_cost) and action_point_cost >= 0,
       do: :ok

  defp validate_action_point_cost(action_point_cost, name),
    do:
      {:error,
       "Action point cost must be a positive integer.  Received #{inspect(action_point_cost)} for #{name}"}

  defp validate_name("" = name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(name) when is_nil(name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(_), do: :ok
end
