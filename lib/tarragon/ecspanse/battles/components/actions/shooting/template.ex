defmodule Tarragon.Ecspanse.Battles.Components.Actions.Shooting.Template do
  @moduledoc """
  the template for any form of movement
  """

  use Ecspanse.Template.Component,
    state: [
      :target_entity_id,
      :name,
      icon: "s",
      number_of_shots: 1,
      action_point_cost: 2,
      precision_modifier: 1.00,
      damage_modifier: 1.00,
      action_group: :attack
    ],
    tags: [:action, :shooting]

  @impl true
  def validate(state) do
    validate_number_of_shots(state[:number_of_shots])
    validate_action_point_cost(state[:action_point_cost])
    validate_precision_modifier(state[:precision_modifier])
  end

  defp validate_number_of_shots(number_of_shots)
       when is_integer(number_of_shots) and number_of_shots >= 0,
       do: :ok

  defp validate_number_of_shots(number_of_shots),
    do: {:error, "#{inspect(number_of_shots)} must be a non-negative integer"}

  defp validate_action_point_cost(action_point_cost)
       when is_integer(action_point_cost) and action_point_cost >= 0,
       do: :ok

  defp validate_action_point_cost(action_point_cost),
    do: {:error, "#{inspect(action_point_cost)} must be a non-negative integer"}

  defp validate_precision_modifier(precision_modifier)
       when is_number(precision_modifier) and precision_modifier >= 0,
       do: :ok

  defp validate_precision_modifier(precision_modifier),
    do: {:error, "#{inspect(precision_modifier)} must be a non-negative number"}
end
